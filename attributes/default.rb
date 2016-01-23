
# set root directory.
case node[:platform_family]
when 'rhel', 'arch'
  default[:mod_security][:dir]                 = '/etc/httpd/mod_security'
when 'windows'
  default[:mod_security][:dir]                 = 'C:\Program Files\ModSecurity IIS'
else
  default[:mod_security][:dir]                 = '/etc/apache2/mod_security'
end

# Apache MPM in use
default[:mod_security][:apache_mpm]  = 'prefork'

default['mod_security']['package_name'] = 'ModSecurity IIS'
default['mod_security']['url']          = 'https://www.modsecurity.org/tarball/2.9.0/ModSecurityIIS_2.9.0-64b.msi'
default['mod_security']['checksum']     = 'cda1abf2c2e6f58b4dd33f4a16ab84c8b861663957dbdc2cf8ad7a4df1ad6645'

default['vcredist_x64']['package_name'] = 'Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501'
default['vcredist_x64']['url']			= 'http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe'
default['vcredist_x64']['checksum']		= 'e554425243e3e8ca1cd5fe550db41e6fa58a007c74fad400274b128452f38fb8'

# define what default actions should be; install mod_security and manage rulesets
default[:mod_security][:install_base] = true		# Install the mod_security code
default[:mod_security][:install_crs] = true		# Install the OWASP core rule set
default[:mod_security][:install_custom] = true		# Install custom rule files

# mod_security locations
default[:mod_security][:from_source] = false
default[:mod_security][:source_version] = '2.2.7'
default[:mod_security][:source_file] = "modsecurity-apache_#{node[:mod_security][:source_version]}.tar.gz"
default[:mod_security][:source_checksum] = '11e05cfa6b363c2844c6412a40ff16f0021e302152b38870fd1f2f44b204379b'
default[:mod_security][:source_dl_server] = 'https://github.com/SpiderLabs/ModSecurity/releases/download'
default[:mod_security][:source_dl_url] = "#{node[:mod_security][:source_dl_server]}/v#{node[:mod_security][:source_version]}/#{node[:mod_security][:source_file]}"
default[:mod_security][:source_module_name] = 'mod_security2.so'
default[:mod_security][:source_module_path] = '/usr/local/modsecurity/lib' #FIXME: Pass to ./configure script
default[:mod_security][:source_module_identifier] = 'security2_module'
default[:mod_security][:rules] = "#{node[:mod_security][:dir]}/owasp_crs"

# core rule set config
default[:mod_security][:crs][:bundled] = true
default[:mod_security][:crs][:version] = '2.2.9'	# Default to the latest version supported by this cookbook

case node[:platform_family]
when 'windows'
  default[:mod_security][:crs][:root_dir] = "#{node[:mod_security][:dir]}"
  default[:mod_security][:crs][:rules_root_dir] = "#{node[:mod_security][:crs][:root_dir]}/owasp_crs"
else
  default[:mod_security][:crs][:root_dir] = "#{node[:mod_security][:dir]}/crs"
  default[:mod_security][:crs][:rules_root_dir] = "#{node[:mod_security][:crs][:root_dir]}/rules"
end

default[:mod_security][:crs][:activated_rules] = "#{node[:mod_security][:crs][:rules_root_dir]}/activated_rules"
  
# core rule set download config
default[:mod_security][:crs][:file_url] = "#{node[:mod_security][:crs][:version]}.tar.gz"
default[:mod_security][:crs][:file_name] = "owasp-modsecurity-crs-#{node[:mod_security][:crs][:file_url]}"
default[:mod_security][:crs][:checksum]["2.2.8"] = '183c6a912b142ca226c9401b281d5a763378efe993572e0a3e93b550161e404f'
default[:mod_security][:crs][:checksum]["2.2.9"] = '203669540abf864d40e892acf2ea02ec4ab47f9769747d28d79b6c2a501e3dfc'
default[:mod_security][:crs][:checksum]["3.0.0"] = '47172ab598ecff73129aa80e457863c70fa7f719d5e812d5db0416c4aab32349'
default[:mod_security][:crs][:dl_server] = 'https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/'
default[:mod_security][:crs][:dl_url] = "#{node[:mod_security][:crs][:dl_server]}#{node[:mod_security][:crs][:file_url]}"

# custom rule set config
default[:mod_security][:custom][:root_dir] = "#{node[:mod_security][:dir]}/owasp_crs"

##########
# Base Configuration
##########
default[:mod_security][:base_config]                  = "#{node[:mod_security][:dir]}/modsecurity.conf"
default[:mod_security][:rule_engine]                  = 'DetectionOnly'
# "On" to actively block

default[:mod_security][:request_body_access]          = 'On'
# allow mod_security to access request bodies
default[:mod_security][:request_body_limit]           = '13107200'
default[:mod_security][:request_body_no_files_limit]  = '131072'
default[:mod_security][:request_body_in_memory_limit] = '131072'
default[:mod_security][:request_body_limit_action]    = 'Reject'
default[:mod_security][:pcre_match_limit]             = '1000'
default[:mod_security][:pcre_match_limit_recursion]   = '1000'

default[:mod_security][:response_body_access]         = 'On'
# allow mod_security to access response bodies
default[:mod_security][:response_body_mime_type]      = 'text/plain text/html text/xml'
default[:mod_security][:response_body_limit]          = '524288'
default[:mod_security][:response_body_limit_action]   = 'ProcessPartial'

# best to set these to a more private directory for long term use
case node[:platform]
when 'windows'
 default[:mod_security][:tmp_dir]                      = 'C:\\Windows\\Temp'
 default[:mod_security][:data_dir]                     = 'C:\\Windows\\Temp' # Persistent data
else
 default[:mod_security][:tmp_dir]                      = '/tmp/'
 default[:mod_security][:data_dir]                     = '/tmp/' # Persistent data
end

# audit log attributes
default[:mod_security][:audit_engine]                 = 'RelevantOnly'
default[:mod_security][:audit_log_relevant_status]    = '"^(?:5|4(?!04))"' # string within a string
default[:mod_security][:audit_log_parts]              = 'ABIJDEFHZ'
default[:mod_security][:audit_log_type]               = 'Serial'
# FIXME: add support concurrent audit logging
case node[:platform]
when 'windows'
 default[:mod_security][:audit_dir]                    = 'c:\\logfiles\\modsecurity'
 default[:mod_security][:audit_log]                    = "#{node[:mod_security][:audit_dir]}\\modsec_audit.log"
else
 default[:mod_security][:audit_dir]                    = '/var/log'
 default[:mod_security][:audit_log]                    = "#{node[:mod_security][:audit_dir]}/modsec_audit.log"
 default[:mod_security][:audit_context]                = "httpd_log_t"
end


# misc attributes
# url-encoding seperator.
default[:mod_security][:argument_separator]           = '&'
# there are multiple cookie format versions?
default[:mod_security][:cookie_format]                = '0'

##########
# OWASP Core Rule Set - RULES!
##########

# Base rules.  These should be relatively safe
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_20_protocol_violations] = true # breaks with < 2.6.x mod_sec
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_21_protocol_anomalies] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_23_request_limits] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_30_http_policy] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_35_bad_robots] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_40_generic_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_41_sql_injection_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_41_xss_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_42_tight_security] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_45_trojans] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_47_common_exceptions] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_49_inbound_blocking] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_50_outbound] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_59_outbound_blocking] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_60_correlation] = true

# SpiderLabs Research (SLR) rules for known vulnerabilties. This
# includes both converted web rules from Emerging Threats (ET) and
# from SLR Team.
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_joomla_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_lfi_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_phpbb_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_rfi_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_sqli_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_wordpress_attacks] = false
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_xss_attacks] = false

# Optional rules.
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_10_ignore_static] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_11_avs_traffic] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_13_xml_enabler] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_16_authentication_tracking] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_16_session_hijacking] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_16_username_tracking] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_25_cc_known] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_42_comment_spam] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_43_csrf_protection] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_46_av_scanning] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_47_skip_outbound_checks] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_49_header_tagging] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_55_application_defects] = false
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_55_marketing] = false

# Experimental rules.  There be monstars here! Maybe.
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_brute_force] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_dos_protection] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_proxy_abuse] = false 
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_slow_dos_protection] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_16_scanner_integration] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_25_cc_track_pan] = false
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.0_setup'] = false 
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.1_request_exception'] = false 
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.9_honeytrap'] = false 
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_3.0_end'] = false 
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_40_http_parameter_pollution] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_42_csp_enforcement] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_46_scanner_integration] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_48_bayes_analysis] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_55_response_profiling] = false 
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_56_pvi_checks] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_61_ip_forensics] = false 

###
# Per rule settings
#
# These settings allow you to turn individual rules off or set rule specific parameters
#
###

default[:mod_security][:disabled_rules] = [ 
	"960014", # base/modsecurity_crs_20_protocol_violations, rule is disabled by default
	"960913", # base/modsecurity_crs_21_protocol_anomalies, rule is disabled by default
	"950103_weaker", # base/modsecurity_crs_42_tight_security, rule is disabled by default
	"981033", # optional/modsecurity_crs_11_avs_traffic, rule is disabled by default
	"981034", # optional/modsecurity_crs_11_avs_traffic, rule is disabled by default
	"981035", # optional/modsecurity_crs_11_avs_traffic, rule is disabled by default
	"981075", # optional/modsecurity_crs_16_username_tracking, rule is disabled by default
	"981076", # optional/modsecurity_crs_16_username_tracking, rule is disabled by default
	"981077", # optional/modsecurity_crs_16_username_tracking, rule is disabled by default
	"920013", # optional/modsecurity_crs_25_cc_known, rule is disabled by default
	"920014", # optional/modsecurity_crs_25_cc_known, rule is disabled by default
	"900030", # experimental/modsecurity_crs_16_scanner_integration, rule is disabled by default
	"900031", # experimental/modsecurity_crs_16_scanner_integration, rule is disabled by default
	"981083", # experimental/modsecurity_crs_40_appsensor_detection_point_2.0_setup.conf, rule is disabled by default
	"981084", # experimental/modsecurity_crs_40_appsensor_detection_point_2.0_setup.conf, rule is disabled by default
]
default[:mod_security][:rule_parameters][:optional]['981033'] = '192.168.1.' # Example AVS
default[:mod_security][:rule_parameters][:optional]['981034'] = '192.168.1.101' # Example AVS
default[:mod_security][:rule_parameters][:optional]['981035'] = '192.168.1.101' # Example AVS
default[:mod_security][:rule_parameters][:optional]['981075'] = '^/(?:(admin|account\/login\.jsp$))' # Example location match for username monitoring
default[:mod_security][:rule_parameters][:optional]['950115'] = '/bin/runAV' # Example virus scanning command
default[:mod_security][:rule_parameters][:experimental]['981050'] = '/usr/local/apache/conf/modsec/GeoLiteCity.dat' # Example GeoLookupDB
default[:mod_security][:rule_parameters][:experimental]['981198'] = '/usr/local/apache/conf/modsec_current/base_rules/osvdb.lua' # OSVB integration lua script
default[:mod_security][:rule_parameters][:experimental]['900030'] = '192.168.168.128' # Archni IP
default[:mod_security][:rule_parameters][:experimental]['900031'] = '/etc/apache2/modsecurity-crs/lua/arachni_integration.lua' # Archni lua script
default[:mod_security][:rule_parameters][:experimental]['900036'] = '/usr/local/apache/conf/crs/lua/gather_ip_data.lua' # IP data lua script
default[:mod_security][:rule_parameters][:experimental]['900039'] = '/usr/local/apache/conf/modsec_current/base_rules/GeoLiteCity.dat' # Example GeoLookupDB
default[:mod_security][:rule_parameters][:experimental]['SecReadStateLimit'] = 100 # SecReadStateLimit
default[:mod_security][:rule_parameters][:experimental]['RequestReadTimeoutBody'] = 30 # Request Read Timeout on body
default[:mod_security][:rule_parameters][:experimental]['981086'] = '/opt/modsecurity/etc/crs/lua/appsensor_request_exception_enforce.lua' # AppSensor lua script
default[:mod_security][:rule_parameters][:experimental]['981102'] = '/opt/modsecurity/etc/crs/lua/appsensor_request_exception_profile.lua' # AppSensor lua script
default[:mod_security][:rule_parameters][:experimental]['981187'] = 'profile_page_scripts.lua' # Profile page lua script

##########
# Custom Rule Set - RULES!
##########

default[:mod_security][:custom][:rules][:example] = [ 
	"# This is an example custom rule file",
	"# Chef managed file, manual updates will be lost"
]

##########
# Custom Rule Set - DATA FILES!
##########

default[:mod_security][:custom][:datafiles][:example] = [ 
	"# This is an example custom data file",
	"# Chef managed file, manual updates will be lost"
]
