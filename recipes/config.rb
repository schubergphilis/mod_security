  # Customize rule files
  node[:mod_security][:crs][:rules].each_pair do |rule_group, rules|
    rule_dir = "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules"
    rules.each_pair do |rule, flag|
      template "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules/#{rule}.conf" do
        source "/#{rule_group}_rules/#{rule}.conf.erb"
	action :create
	variables(
	  :disabled => node[:mod_security][:disabled_rules],
	  :parameters => node[:mod_security][:rule_parameters][rule_group],
	)
      end
    end
  end

# directory node[:mod_security][:crs][:rules_root_dir] do
#  recursive true
# end

template "#{node[:mod_security][:dir]}/modsecurity_crs_10_setup.conf" do
 source "modsecurity_crs_10_setup.conf.erb"
end

template "#{node[:mod_security][:dir]}/modsecurity.conf" do
 source "modsecurity.conf.erb"
end

node[:mod_security][:crs][:rules].each_pair do |rule_group, rules|
  rule_dir = "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules"
  rules.each_pair do |rule, flag|
	    link "#{node[:mod_security][:crs][:rules_root_dir]}/activated_rules/#{rule}.conf" do
		to "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules/#{rule}.conf"
#	action :create
	action (flag ? :create : :delete)
	end
  end
end
