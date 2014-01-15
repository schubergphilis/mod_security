# install package common to package and source install
case node[:platform_family]
when "rhel","fedora","suse"
  packages = %w[apr apr-util pcre curl]
when "ubuntu","debian"
  packages = %w[libapr1 libaprutil1 libpcre3 libxml2 libcurl3]
when "arch"
  packages = %w[apr apr-util pcre libxml2 lib32-curl]
end
packages.each {|p| package p}

# FIXME: ignoring lua for right now
# make optional in the future

if node[:mod_security][:from_source]
  # COMPILE FROM SOURCE

  #install required libs

  case node['platform_family']
  when "arch"
    # OH NOES
  when "rhel","fedora","suse"
    package "httpd-devel"
    if node['platform_version'].to_f < 6.0
      package 'curl-devel'
    else
      package 'libcurl-devel'
      package 'openssl-devel'
      package 'zlib-devel'
    end
  when "debian"
    apache_development_package =  if %w( worker threaded ).include? node['mod_security']['apache_mpm']
                                    'apache2-threaded-dev'
                                  else
                                    'apache2-prefork-dev'
                                  end
    %W( #{apache_development_package} libxml2-dev libcurl4-openssl-dev ).each do |pkg|
      package pkg
    end
  end

  directory "#{node[:mod_security][:dir]}/source" do
    recursive true
  end

  # Download and compile mod_security from source

  source_code_tar_file = "#{node[:mod_security][:dir]}/source/#{node[:mod_security][:source_file]}"
  remote_file source_code_tar_file do
    action :create_if_missing
    source node[:mod_security][:source_dl_url]
    mode "0644"
    checksum node[:mod_security][:source_checksum] # Not a checksum check for security. Will be unused with create_if_missing.
    backup false
    notifies :create, "ruby_block[validate_tarball_checksum]", :immediately
  end

  ruby_block "validate_tarball_checksum" do
    action :nothing
    block do
      require 'digest'
      checksum = Digest::SHA256.file("#{source_code_tar_file}").hexdigest
      if checksum != node[:mod_security][:source_checksum]
        raise "Downloaded Tarball Checksum #{checksum} does not match known checksum #{node[:mod_security][:source_checksum]}"
      end
    end
    notifies :run, "execute[unpack_mod_security_source_tarball]", :immediately
  end

  execute "unpack_mod_security_source_tarball" do
    command "tar -xvzf #{node[:mod_security][:source_file]}"
    action :nothing
    cwd "#{node[:mod_security][:dir]}/source"
    notifies :run, "execute[configure_mod_security]", :immediately
  end

  execute "configure_mod_security" do
    command "./configure"
    cwd "#{node[:mod_security][:dir]}/source/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
    notifies :run, "execute[make_mod_security]", :immediately
  end

  execute "make_mod_security" do
    command "make clean && make && make mlogc"
    cwd "#{node[:mod_security][:dir]}/source/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
    notifies :run, "execute[install_mod_security]", :immediately
  end

  execute "install_mod_security" do
    command "make install"
    cwd "#{node[:mod_security][:dir]}/source/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
  end

  # setup apache module loading
  apache_module "unique_id"
  # we have to manage our own loading
  template "#{node[:apache][:dir]}/mods-available/mod-security.load" do
    source "mods/mod-security.load.erb"
    owner node[:apache][:user]
    group node[:apache][:group]
    mode 0644
    #backup false
    notifies :restart, resources(:service => "apache2"), :delayed
  end

  template "#{node[:apache][:dir]}/mods-available/mod-security.conf" do
    source "mods/mod-security.conf.erb"
    owner node[:apache][:user]
    group node[:apache][:group]
    mode 0644
    #backup false
    notifies :restart, resources(:service => "apache2"), :delayed
  end

  apache_module "mod-security" do
    conf true
  end

  # FIXME: Should probably not just link this and include it in the cookbook
  # or otherwise not depend on the source dir always being there
  link "#{node[:mod_security][:dir]}/unicode.mapping" do
      to "#{node[:mod_security][:dir]}/source/modsecurity-apache_#{node[:mod_security][:source_version]}/unicode.mapping"
      action :create
      notifies :restart, resources(:service => "apache2"), :delayed
  end

else
  # INSTALL FROM PACKAGE
  case node[:platform_family]
  when "rhel","fedora","suse"
    package "mod_security"
  when "debian"
    package "libapache-mod-security"
  when "arch"
    package "modsecurity-apache"
  end
end

directory "#{node[:mod_security][:rules]}" do
  recursive true
end

template "modsecurity.conf" do
  path "#{node[:mod_security][:base_config]}"
  source "modsecurity.conf.erb"
  owner node[:apache][:user]
  group node[:apache][:group]
  mode 0644
  backup false
  notifies :restart, resources(:service => "apache2")
end
