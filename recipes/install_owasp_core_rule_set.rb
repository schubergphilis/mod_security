
package 'tar' do
  action :install
end

directory node[:mod_security][:crs][:rules_root_dir] do
  recursive true
end

# download and install Core Rule Set
crs_tar_file = "#{Chef::Config[:file_cache_path]}/#{node[:mod_security][:crs][:file_name]}"
remote_file crs_tar_file do
  action :create
  source node[:mod_security][:crs][:dl_url]
  mode '0644'
  checksum node[:mod_security][:crs][:checksum] # Not a checksum check for security. Will be unused with create_if_missing.
  backup false
  not_if do
    # FIXME: Only checks for the existence of the .example file i.e. rules already in place. Doesn't check the version of the rules is as specified.
    File.exists?("#{node[:mod_security][:crs][:root_dir]}/modsecurity_crs_10_setup.conf.example")
  end
  notifies :create, 'ruby_block[validate_crs_tarball_checksum]', :immediately
end

ruby_block 'validate_crs_tarball_checksum' do
  action :nothing
  block do
    require 'digest'
    checksum = Digest::SHA256.file(crs_tar_file).hexdigest
    if checksum != node[:mod_security][:crs][:checksum]
      Chef::Log.fatal("Downloaded core rule set tarball checksum #{checksum} does not match known checksum #{node[:mod_security][:crs][:checksum]}")
      fail 'Downloaded core rule set tarball did not match known checksum'
    end
  end
  notifies :run, 'execute[untar_core_rule_set]', :immediately
end

# untar core rule set if crs_tar_file is updated
execute 'untar_core_rule_set' do
  command "tar -xzf #{crs_tar_file} -C #{node[:mod_security][:crs][:rules_root_dir]} --strip 1"
  action :nothing
end

# install settings config
# - currently heavily tied to version of crs. be wary of updating one
# - without the other
template "#{node[:mod_security][:crs][:rules_root_dir]}/modsecurity_crs_10_setup.conf" do
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
end

node[:mod_security][:crs][:rules].each_pair do |rule_group, rules|
  rule_dir = "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules"
  rules.each_pair do |rule, flag|
    link "#{node[:mod_security][:crs][:activated_rules]}/#{rule}.conf" do
      to "#{rule_dir}/#{rule}.conf"
      action (flag ? :create : :delete)
      notifies :restart, 'service[apache2]', :delayed
    end

    # deal with data_files
    data_filenames = case rule
                     when 'modsecurity_crs_35_bad_robots'
                       ['modsecurity_35_scanners.data', 'modsecurity_35_bad_robots.data']
                     when 'modsecurity_crs_50_outbound'
                       ['modsecurity_50_outbound_malware.data', 'modsecurity_50_outbound.data']
                     when 'modsecurity_crs_46_slr_et_joomla_attacks'
                       ['modsecurity_46_slr_et_joomla.data']
                     when 'modsecurity_crs_46_slr_et_lfi_attacks'
                       ['modsecurity_46_slr_et_lfi.data']
                     when 'modsecurity_crs_46_slr_et_phpbb_attacks'
                       ['modsecurity_46_slr_et_phpbb.data']
                     when 'modsecurity_crs_46_slr_et_rfi_attacks'
                       ['modsecurity_46_slr_et_rfi.data']
                     when 'modsecurity_crs_46_slr_et_wordpress_attacks'
                       ['modsecurity_46_slr_et_wordpress.data']
                     when 'modsecurity_crs_46_slr_et_xss_attacks'
                       ['modsecurity_46_slr_et_xss.data']
                     when 'modsecurity_crs_46_slr_et_sqli_attacks'
                       ['modsecurity_46_slr_et_sqli.data']
                     else
                       # why does the crs disappear from the data filenames? why!?
                       ["#{rule.gsub(/crs_/, '')}.data"]
                     end

    data_filenames.each do |data_filename|
      link "#{node[:mod_security][:crs][:activated_rules]}/#{data_filename}" do
        to "#{rule_dir}/#{data_filename}"
        action (flag ? :create : :delete)
        only_if "test -e #{rule_dir}/#{data_filename}"
        notifies :restart, 'service[apache2]', :delayed
      end
    end
  end
end
