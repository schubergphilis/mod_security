# First part, installing CRS


# Do we need to do a bundled or download install?
if node[:mod_security][:crs][:bundled] 
  # Bundled install, using the templates in this cookbook

  # Make sure the directory exists to install into
  remote_directory "owasp-modsecurity-crs-#{node[:mod_security][:crs][:version]}" do
    path node[:mod_security][:crs][:rules_root_dir]
    owner "root" unless platform? 'windows'
    group "root" unless platform? 'windows'
    mode  "0755" unless platform? 'windows'
    action :create
    notifies :restart, 'service[apache2]', :delayed unless platform? 'windows'
    notifies :run, 'execute[iisreset]', :delayed if platform? 'windows'
  end

  # Install customize rule files from the templates
  node[:mod_security][:crs][:rules].each_pair do |rule_group, rules|
    rule_dir = "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules"
    
    # Make sure directory exists
    directory "#{rule_dir}" do
      owner "root" unless platform? 'windows'
      group "root" unless platform? 'windows'
      mode  "0750" unless platform? 'windows'
      action :create
      recursive true
    end

    rules.each_pair do |rule, flag|
      template "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules/#{rule}.conf" do
        source "#{node[:mod_security][:crs][:version]}/#{rule_group}_rules/#{rule}.conf.erb"
	owner "root" unless platform? 'windows'
	group "root" unless platform? 'windows'
	mode  "0644" unless platform? 'windows'
	action :create
	variables(
	  :disabled => node[:mod_security][:disabled_rules],
	  :parameters => node[:mod_security][:rule_parameters][rule_group]
	)
        notifies :restart, 'service[apache2]', :delayed unless platform? 'windows'
        notifies :run, 'execute[iisreset]', :delayed if platform? 'windows'
      end
    end
  end

else
  # DOWNLOAD install

  case node[:platform_family]
  when 'windows'
    # No action required, the OWASP CRS is included in the MSI by default
  else
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
      mode '0644' unless platform? 'windows'
      checksum node[:mod_security][:crs][:checksum][node[:mod_security][:crs][:version]] # Not a checksum check for security. Will be unused with create_if_missing.
      backup false
      not_if do
        # FIXME: Only checks for the existence of the .example file i.e. rules already in place. Doesn't check the version of the rules is as specified.
        File.exists?("#{node[:mod_security][:crs][:root_dir]}/modsecurity_crs_10_setup.conf.example")
      end
      notifies :create, 'ruby_block[validate_crs_tarball_checksum]', :immediately
    end
  end

  ruby_block 'validate_crs_tarball_checksum' do
    action :nothing
    block do
      require 'digest'
      checksum = Digest::SHA256.file(crs_tar_file).hexdigest
      if checksum != node[:mod_security][:crs][:checksum][node[:mod_security][:crs][:version]] then
        Chef::Log.fatal("Downloaded core rule set tarball checksum #{checksum} does not match known checksum #{node[:mod_security][:crs][:checksum][node[:mod_security][:crs][:version]]}")
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
end 

# The setup.conf file is always installed from a template, even if a unbundled install is performed

# install settings config
# - currently heavily tied to version of crs. be wary of updating one
# - without the other
template "#{node[:mod_security][:crs][:rules_root_dir]}/modsecurity_crs_10_setup.conf" do
  source "#{node[:mod_security][:crs][:version]}/modsecurity_crs_10_setup.conf.erb"
  mode '0644' unless platform? 'windows'
  notifies :restart, 'service[apache2]', :delayed unless platform? 'windows'
  notifies :run, 'execute[iisreset]', :delayed if platform? 'windows'
end

# Next up link the files of the rule groups we want to have turned on

node[:mod_security][:crs][:rules].each_pair do |rule_group, rules|
  rule_dir = "#{node[:mod_security][:crs][:rules_root_dir]}/#{rule_group}_rules"
  rules.each_pair do |rule, flag|
      link "#{node[:mod_security][:crs][:activated_rules]}/#{rule}.conf" do
      to "#{rule_dir}/#{rule}.conf"
      action (flag ? :create : :delete)
      notifies :restart, 'service[apache2]', :delayed unless platform? 'windows'
      notifies :run, 'execute[iisreset]', :delayed if platform? 'windows'
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
                       # The name of the conf file mathes the name of the data file, but the 
                       # starting 'crs_' is not present on the datafile name
                       ["#{rule.gsub(/crs_/, '')}.data"]
                     end
  
    data_filenames.each do |data_filename|
      link "#{node[:mod_security][:crs][:activated_rules]}/#{data_filename}" do
        to "#{rule_dir}/#{data_filename}"
        action (flag ? :create : :delete)
        only_if { File.exists?("#{rule_dir}/#{data_filename}") }
        notifies :restart, 'service[apache2]', :delayed unless platform? 'windows'
        notifies :run, 'execute[iisreset]', :delayed if platform? 'windows'
      end
    end

  end # Each pair
end # Linking
