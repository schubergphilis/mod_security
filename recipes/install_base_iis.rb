windows_package node['vcredist_x64']['package_name'] do
  source node['vcredist_x64']['url']
  checksum node['vcredist_x64']['checksum']
  options "/q"
  installer_type :custom
  action :install
end

windows_package node['mod_security']['package_name'] do
  source node['mod_security']['url']
  checksum node['mod_security']['checksum']
  installer_type :msi
  options "/quiet /qn /passive"
  action :install
end

directory node[:mod_security][:audit_dir] do
  recursive true
end

template "#{node[:mod_security][:dir]}/modsecurity_iis.conf" do
  source "modsecurity_iis.conf.erb"
  notifies :run, 'execute[iisreset]', :delayed
end

template "#{node[:mod_security][:dir]}/modsecurity.conf" do
  source "modsecurity.conf.erb"
  notifies :run, 'execute[iisreset]', :delayed
end

# remove the default installed modsecurity_crs_10_setup.conf file
file "#{node[:mod_security][:dir]}/modsecurity_crs_10_setup.conf" do
  action :delete
  only_if {File.exists?("#{node[:mod_security][:dir]}/modsecurity_crs_10_setup.conf")}
end

cookbook_file "unicode.mapping" do
  path "#{node[:mod_security][:dir]}/unicode.mapping"
  action :create
  notifies :run, 'execute[iisreset]', :delayed
end

