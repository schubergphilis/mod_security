name              'mod_security'
maintainer        'HoneyApps Inc.'
maintainer_email  'jro@honeyapps.com'
license           'Apache 2.0'
description       'Installs and configures mod_security for Apache2 or IIS'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '0.2.3'

depends 'apache2'
depends 'build-essential'
depends 'apt'
depends 'yum'
depends 'windows'

%w{ redhat centos scientific fedora ubuntu debian windows}.each do |os|
  supports os
end
