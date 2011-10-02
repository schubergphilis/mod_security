maintainer        "HoneyApps Inc."
maintainer_email  "jro@honeyapps.com"
license           "Apache 2.0"
description       "Installs mod_security for Apache2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.2"

depends "apache2"
depends "build-essential"

#%w{ redhat centos ubuntu debian }.each do |os|
%w{ ubuntu debian }.each do |os|
  supports os
end

# notes
# requires
# mod_uniqueid 
# - installed on ubuntu, but not activated
# libapr and libapr-util
# libpcre
# libxml2

# liblua v5.1.x
# This library is optional and only needed if you will be using the new Lua engine - http://www.lua.org/download.html

# libcurl v7.15.1 or higher
# If you will be using the ModSecurity Log Collector (mlogc) to send audit logs to a central repository, then you will also need the curl library.
