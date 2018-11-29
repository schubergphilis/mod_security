# frozen_string_literal: true

if node[:mod_security][:install_base]
  if platform_family?('windows')
    include_recipe 'mod_security::install_base_iis'
  else
    include_recipe 'mod_security::install_base_apache'
  end
end
