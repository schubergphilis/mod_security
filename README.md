Description
===========

Ever wanted a little guardian angel to protect your chef deployed
servers from the bad guys?  Like a bad-ass Jiminy Cricket on your
shoulder?  

This package is to make deployment and testing of mod_security easier
with chef.  Right now it centers entirely around the OWASP Core Rule
Sets of mod_security rules.  In future, it will allow you to manage/deploy
custom rule/rulesets of your own.

There are 2 main use cases right now:

## Install on a real production server

* Adjust the attributes to your liking and install the default
  recipe.  
  
## Find out what ModSecurity could do for your site in less than
   15-minutes.
   
* Setup a base chef recipe for a server.  Ubuntu 10.04 on Rackspace
  Cloud is pretty easy (and what I've tested with)
* Set it to install the default recipe
* Create a cookbook to reverse proxy to your real server sorta like
  this:
<pre>  
mod_secure_proxy "my_site" do
  server_name "www.mysite.com"
  enable_https true # if you want to proxy https too
end
</pre>
* Set your local /etc/hosts (or equiv.) file to have that server's IP
  look like your site
* Test to your heart's content.
* Look at /var/log/modsec.log and see what you could be blocking
* Change the "DetectOnly" attribute to "On" and test some more

Requirements
============

## Cookbooks

This cookbook depends on apache2 and build-essential

## Platforms

### Supported
* Ubuntu (tested on 10.04)
* Debian
* RedHat
* CentOS (tested on 5.6)
* Fedora
* Scientific?

### Coming Soon
* Arch (anything else that apache2 supports)

Attributes
==========

Major ones will be documented soon.  For right now check the
attributes file.  A few suggestions

* Compile from source.  I normally prefer not to do this, but some
  core rules break if you don't
* The core rules are in the cookbook because old version seem to
  disappear from sourceforge, and that sucks if you're maintaining a
  large deployment.  
* Base rules should generally be safe.  the other groups much less
  so. There are some rules with inconsistently named data files that
  will need to be fixed.
  
Recipes
=======

default
-------
This installs base and the OWASP core rule set currently.

install_base
------------

install_owasp_core_rule_set
---------------------------

Changes
=======

* 0.0.5
 * add server alias support for mod_secure_proxy definition
* 0.0.3/0.0.4
 * add RedHat-based distro support
* 0.0.2 
 * upgrade to mod_security 2.6.2
 * flesh out main config options as chef attributes
* 0.0.1 First release

License and Authors
===================

Author:: Jason Rohwedder <jro@honeyapps.com>

Copyright:: 2011, HoneyApps, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


