# install package common to package and source install
case node[:platform_family]
when 'rhel', 'fedora', 'suse'
  packages = %w[apr apr-util pcre-devel libxml2-devel curl-devel]
when 'debian'
  packages = %w[libapr1 libaprutil1 libpcre3 libxml2 libcurl3]
when 'arch'
  packages = %w[apr apr-util pcre libxml2 lib32-curl]
when 'freebsd'
  packages = %w[apr pcre-8.33 libxml2 curl]
else
  Chef::Log.fatal("Unsupported platform: #{node[:platform_family]}.")
  fail 'mod_security cookbook does not support this platform'
end
packages.each { |p| package p }

# FIXME: ignoring lua for right now
# make optional in the future

directory node[:mod_security][:dir] do
  recursive true
end


if node[:mod_security][:from_source]
  # COMPILE FROM SOURCE

  # install required libs

  case node[:platform_family]
  when 'arch'
    # OH NOES
  when 'rhel', 'fedora', 'suse'
    package 'httpd-devel'
    if node[:platform_version].to_f < 6.0
      package 'curl-devel'
    else
      package 'libcurl-devel'
      package 'openssl-devel'
      package 'zlib-devel'
    end
  when 'debian'
    apache_development_package =  if %w( worker threaded ).include? node[:mod_security][:apache_mpm]
                                    'apache2-threaded-dev'
                                  else
                                    'apache2-prefork-dev'
                                  end
    %W( #{apache_development_package} libxml2-dev libcurl4-openssl-dev ).each do |pkg|
      package pkg
    end
  end


  # Download and compile mod_security from source

  source_code_tar_file = "#{Chef::Config[:file_cache_path]}/#{node[:mod_security][:source_file]}"
  remote_file source_code_tar_file do
    action :create
    source node[:mod_security][:source_dl_url]
    mode '0644'
    checksum node[:mod_security][:source_checksum] # Not a checksum check for security. Will be unused with create_if_missing.
    backup false
    not_if do
      # FIXME: Only checks for the existence of the module file. Doesn't check the version of the module is as specified.
      File.exists?("#{node[:mod_security][:source_module_path]}/#{node[:mod_security][:source_module_name]}")
    end
    notifies :create, 'ruby_block[validate_tarball_checksum]', :immediately
  end

  ruby_block 'validate_tarball_checksum' do
    action :nothing
    block do
      require 'digest'
      checksum = Digest::SHA256.file(source_code_tar_file).hexdigest
      if checksum != node[:mod_security][:source_checksum]
        Chef::Log.fatal("Downloaded source tarball checksum #{checksum} does not match known checksum #{node[:mod_security][:source_checksum]}")
        fail 'Downloaded source tarball did not match known checksum'
      end
    end
    notifies :run, 'execute[unpack_mod_security_source_tarball]', :immediately
  end

  execute 'unpack_mod_security_source_tarball' do
    command "tar -xvzf #{node[:mod_security][:source_file]}"
    action :nothing
    cwd Chef::Config[:file_cache_path]
    notifies :run, 'execute[configure_mod_security]', :immediately
  end

  execute 'configure_mod_security' do
    command './configure'
    cwd "#{Chef::Config[:file_cache_path]}/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
    notifies :run, 'execute[make_mod_security]', :immediately
  end

  execute 'make_mod_security' do
    command 'make clean && make && make mlogc'
    cwd "#{Chef::Config[:file_cache_path]}/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
    notifies :run, 'execute[install_mod_security]', :immediately
  end

  execute 'install_mod_security' do
    command 'make install'
    cwd "#{Chef::Config[:file_cache_path]}/modsecurity-apache_#{node[:mod_security][:source_version]}"
    action :nothing
  end

  libdir="#{node[:mod_security][:source_module_path]}"

else

  # INSTALL FROM PACKAGE
  case node[:platform]
  when 'amazon'
    package 'mod24_security'
  when 'redhat', 'centos', 'fedora', 'suse'
    package 'mod_security'
  when 'debian'
    package 'libapache-mod-security'
  when 'ubuntu'
    package 'libapache2-modsecurity'
    package 'modsecurity-crs'
  when 'arch'
    package 'modsecurity-apache'
  end

  # Both node attributes are used in the wild. libexec_dir seems to be the newer convention
  libdir="#{node['apache']['libexec_dir']}"
  libdir="#{node['apache']['libexecdir']}" if libdir.nil? || libdir.empty?

end


# setup apache module loading
apache_module 'unique_id'

template "#{node[:apache][:dir]}/mods-available/mod-security.load" do
  source 'mods/mod-security.load.erb'
  owner 'root'
  group 'root'
  mode 0644
  # backup false
  variables(
    :libdir => libdir
   )
  notifies :restart, 'service[apache2]', :delayed
end

template "#{node[:apache][:dir]}/mods-available/mod-security.conf" do
  source 'mods/mod-security.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  # backup false
  notifies :restart, 'service[apache2]', :delayed
end

apache_module 'mod-security' do
  conf true
  # The following attributes are only used by the apache2 cookbook on rhel, fedora, arch, suse and freebsd
  # as it only drop off a .load file for those platforms
  identifier node[:mod_security][:source_module_identifier]
  module_path "#{libdir}/#{node[:mod_security][:source_module_name]}"
end

cookbook_file "unicode.mapping" do
  path "#{node[:mod_security][:dir]}/unicode.mapping"
  action :create
  notifies :restart, 'service[apache2]', :delayed
end

directory node[:mod_security][:rules] do
  recursive true
end

template 'modsecurity.conf' do
  path node[:mod_security][:base_config]
  source 'modsecurity.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  backup false
  notifies :restart, 'service[apache2]'
end

# Restore SE linux context audit log
execute "Restore SE Linux context audit log" do
  command "chcon -t #{node[:mod_security][:audit_context]} '#{node[:mod_security][:audit_log]}'"
  only_if { File.exist?('/selinux/status') && File.exist?("#{node[:mod_security][:audit_log]}") }
end
