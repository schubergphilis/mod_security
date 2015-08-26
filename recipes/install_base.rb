if node[:mod_security][:install_base] then
  if platform_family?('windows')
    include_recipe 'mod_security::install_base_iis'
  else
    include_recipe 'mod_security::install_base_apache'
  end
end

