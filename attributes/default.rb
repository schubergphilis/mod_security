
# set root directory.
case platform
when "redhat","centos","scientific","fedora","suse","arch"
  default[:mod_security][:dir]                 = "/etc/httpd/mod_security"
else
  default[:mod_security][:dir]                 = "/etc/apache2/mod_security"
end

# mod_security locations
default[:mod_security][:from_source]           = true
default[:mod_security][:source_version]        = "2.6.1"
default[:mod_security][:source_file]           = "modsecurity-apache_#{node[:mod_security][:source_version]}.tar.gz"
default[:mod_security][:source_checksum]       = "762d2d1fcd47dd0d348bea737a956dac" # SEEMS TO IGNORE? FIXME
default[:mod_security][:source_dl_server]      = "http://downloads.sourceforge.net/project/mod-security/modsecurity-apache/"
default[:mod_security][:source_dl_url]         = "#{node[:mod_security][:source_dl_server]}#{node[:mod_security][:source_version]}/#{node[:mod_security][:source_file]}"
default[:mod_security][:rules]                 = "#{node[:mod_security][:dir]}/rules"
# core rule set locations
default[:mod_security][:crs][:version]         = "2.2.2"
default[:mod_security][:crs][:root_dir]        = "#{node[:mod_security][:dir]}/crs"
default[:mod_security][:crs][:files]           = "#{node[:mod_security][:crs][:root_dir]}/files"
default[:mod_security][:crs][:rules_root_dir]  = "#{node[:mod_security][:crs][:root_dir]}/rules"
default[:mod_security][:crs][:activated_rules] = "#{node[:mod_security][:crs][:rules_root_dir]}/activated_rules"

##########
# RULES!
##########

# Base rules.  These should be relatively safe
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_20_protocol_violations] = true # breaks with < 2.6.x mod_sec
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_21_protocol_anomalies] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_23_request_limits] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_30_http_policy] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_35_bad_robots] = false # FIXME data file
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_40_generic_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_41_sql_injection_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_41_xss_attacks] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_42_tight_security] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_45_trojans] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_47_common_exceptions] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_49_inbound_blocking] = true
default[:mod_security][:crs][:rules][:base][:modsecurity_crs_50_outbound] = false # FIXME
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
default[:mod_security][:crs][:rules][:slr][:modsecurity_crs_46_slr_et_xss_attacks] = false # test later FIXME

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
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_proxy_abuse] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_11_slow_dos_protection] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_25_cc_track_pan] = false
default[:mod_security][:crs][:rules][:experimental]["modsecurity_crs_40_appsensor_detection_point_2.0_setup"] = false
default[:mod_security][:crs][:rules][:experimental]["modsecurity_crs_40_appsensor_detection_point_2.1_request_exception"] = false
default[:mod_security][:crs][:rules][:experimental]["modsecurity_crs_40_appsensor_detection_point_2.9_honeytrap"] = false
default[:mod_security][:crs][:rules][:experimental]["modsecurity_crs_40_appsensor_detection_point_3.0_end"] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_40_http_parameter_pollution] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_41_advanced_filters] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_42_csp_enforcement] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_45_char_anomaly] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_55_response_profiling] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_56_pvs_checks] = false
default[:mod_security][:crs][:rules][:experimental][:modsecurity_crs_61_ip_forensics] = false

