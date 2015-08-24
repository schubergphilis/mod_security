case node['platform']
when "windows" then
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
end
