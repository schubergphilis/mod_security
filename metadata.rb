name              "mod_security"
maintainer        "HoneyApps Inc."
maintainer_email  "jro@honeyapps.com"
license           "Apache 2.0"
description       "Installs mod_security for Apache2"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.6"

depends "apache2"
depends "build-essential"

#%w{ redhat centos ubuntu debian }.each do |os|
%w{ redhat centos scientific fedora ubuntu debian }.each do |os|
  supports os
end
