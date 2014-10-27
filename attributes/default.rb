
# set root directory.
case node[:platform_family]
when 'rhel', 'arch'
  default[:mod_security][:dir]                 = '/etc/httpd/mod_security'
else
  default[:mod_security][:dir]                 = '/etc/apache2/mod_security'
end

# Apache MPM in use
default[:mod_security][:apache_mpm]  = 'prefork'

# mod_security locations
default[:mod_security][:from_source]           = true
default[:mod_security][:source_version]        = '2.7.7'
default[:mod_security][:source_file]           = "modsecurity-apache_#{node[:mod_security][:source_version]}.tar.gz"
default[:mod_security][:source_checksum]       = '11e05cfa6b363c2844c6412a40ff16f0021e302152b38870fd1f2f44b204379b'
default[:mod_security][:source_dl_server]      = 'https://github.com/SpiderLabs/ModSecurity/releases/download'
default[:mod_security][:source_dl_url]         = "#{node[:mod_security][:source_dl_server]}/v#{node[:mod_security][:source_version]}/#{node[:mod_security][:source_file]}"
default[:mod_security][:source_module_name]    = 'mod_security2.so'
default[:mod_security][:source_module_path]    = '/usr/local/modsecurity/lib' #FIXME: Pass to ./configure script
default[:mod_security][:source_module_identifier] = 'security2_module'
default[:mod_security][:rules]                 = "#{node[:mod_security][:dir]}/rules"

# core rule set config
default[:mod_security][:crs][:bundled]         = false
default[:mod_security][:crs][:version]         = '2.2.8'
default[:mod_security][:crs][:root_dir]        = "#{node[:mod_security][:dir]}/crs"
default[:mod_security][:crs][:rules_root_dir]  = "#{node[:mod_security][:crs][:root_dir]}/rules"
default[:mod_security][:crs][:activated_rules] = "#{node[:mod_security][:crs][:rules_root_dir]}/activated_rules"

# core rule set download config
if ( not node[:mod_security][:crs][:bundled] )
  default[:mod_security][:crs][:file_url]        = "#{node[:mod_security][:crs][:version]}.tar.gz"
  default[:mod_security][:crs][:file_name]       = "owasp-modsecurity-crs-#{node[:mod_security][:crs][:file_url]}"
  if node[:mod_security][:crs][:version] == "2.2.8"
    default[:mod_security][:crs][:checksum]        = '183c6a912b142ca226c9401b281d5a763378efe993572e0a3e93b550161e404f'
  elsif node[:mod_security][:crs][:version] == "2.2.9"
    default[:mod_security][:crs][:checksum]        = '203669540abf864d40e892acf2ea02ec4ab47f9769747d28d79b6c2a501e3dfc'
#  elsif node[:mod_security][:crs][:version] == "3.0.0"
#    default[:mod_security][:crs][:checksum]        = '47172ab598ecff73129aa80e457863c70fa7f719d5e812d5db0416c4aab32349'
  end
  default[:mod_security][:crs][:dl_server]       = 'https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/'
  default[:mod_security][:crs][:dl_url]          = "#{node[:mod_security][:crs][:dl_server]}#{node[:mod_security][:crs][:file_url]}"
end

# custom rule set config
default[:mod_security][:custom][:root_dir]        = "#{node[:mod_security][:dir]}/rules"

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
default[:mod_security][:tmp_dir]                      = '/tmp/'
default[:mod_security][:data_dir]                     = '/tmp/' # Persistent data

# audit log attributes
default[:mod_security][:audit_engine]                 = 'RelevantOnly'
default[:mod_security][:audit_log_relevant_status]    = '"^(?:5|4(?!04))"' # string within a string
default[:mod_security][:audit_log_parts]              = 'ABIJDEFHZ'
default[:mod_security][:audit_log_type]               = 'Serial'
default[:mod_security][:audit_log]                    = '/var/log/modsec_audit.log'
# FIXME: add support concurrent audit logging

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
default[:mod_security][:crs][:rules][:optional][:modsecurity_crs_40_experimental] = false
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
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_proxy_abuse] = false # FIXME: hardcoded data file
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_slow_dos_protection] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_25_cc_track_pan] = false
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.0_setup'] = false # LUA
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.1_request_exception'] = false # LUA?
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_2.9_honeytrap'] = false # LUA?
default[:mod_security][:crs][:rules][:experimental]['modsecurity_crs_40_appsensor_detection_point_3.0_end'] = false # LUA?
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_40_http_parameter_pollution] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_41_advanced_filters] = false # LUA?
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_42_csp_enforcement] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_45_char_anomaly] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_55_response_profiling] = false # LUA?
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_56_pvs_checks] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_61_ip_forensics] = false # Unknown action? dependency


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
