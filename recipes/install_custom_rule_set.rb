# Install custom rule files
node[:mod_security][:custom][:rules].each do |set, lines|
  template "#{node[:mod_security][:custom][:root_dir]}/#{set}.conf" do
    source "custom_file.erb"
    owner  "root"
    group  "root"
    mode   00644
    notifies :reload, "service[apache2]", :delayed
    variables(:lines => lines)
  end
end

# Install custom data files
node[:mod_security][:custom][:datafiles].each do |set, lines|
  template "#{node[:mod_security][:custom][:root_dir]}/#{set}.data" do
    source "custom_file.erb"
    owner  "root"
    group  "root"
    mode   00644
    notifies :reload, "service[apache2]", :delayed
    variables(:lines => lines)
  end
end
