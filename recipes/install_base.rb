%w[libapr1 libaprutil1 libpcre3 libxml2 libcurl3].each do |p|
  package p
end

# ignoring lua for right now
# make optional?

if node[:mod_security][:from_source]
  # COMPILE FROM SOURCE
  
  # install required libs
  %w[build-essential apache2-dev libxml2-dev libcurl3-dev].each do |p|
    package p
  end

  directory "#{node[:mod_security][:dir]}/source" do
    recursive true
  end

  source_code = "#{node[:mod_security][:dir]}/source/#{node[:mod_security][:source_file]}"
  remote_file source_code do
    action :create_if_missing
    source node[:mod_security][:source_dl_url]
    mode "0644"
    #checksum node[:mod_security][:source_checksum] seems to ignore? FIXME
    backup false
  end

  bash "install_mod_security" do
    action :nothing
    code <<-EOH
      cd #{node[:mod_security][:dir]}/source
      tar -zxf #{node[:mod_security][:source_file]}
      cd modsecurity-apache_#{node[:mod_security][:source_version]}
      ./configure
      make
      make mlogc
      make install
    EOH
    subscribes :run, resources(:remote_file => source_code), :immediately
  end

  template "/etc/apache2/mods-available/mod-security.load" do
    owner node[:apache][:user]
    group node[:apache][:group]
    mode 0644
    backup false
    notifies :restart, resources(:service => "apache2"), :delayed
  end

  apache_module "mod-security" 

else
  # INSTALL FROM PACKAGE
  
  package "libapache-mod-security" do
    action :install
  end
end

# installing via deb seems enable mod unique id.  
# will also need to adjust to offer from source compile.  that'll likely be the default
# from source will probably have to enable the mod_unique_id via some apache2 call.  maybe makes sense to try to enable that way no matter what?

apache_module "unique_id"
apache_module "mod-security"

directory "#{node[:mod_security][:rules]}" do
  recursive true
end

template "mod_security" do
  path "#{node[:apache][:dir]}/conf.d/mod_security"
  source "mod_security.erb"
  owner node[:apache][:user]
  group node[:apache][:group]
  mode 0644
  backup false
  notifies :restart, resources(:service => "apache2")
end


