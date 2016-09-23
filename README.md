# Description

Ever wanted a little guardian angel to protect your chef deployed
servers from the bad guys?  Like a bad-ass Jiminy Cricket on your
shoulder?

This package is to make deployment and testing of mod_security easier
with Chef. Right now it centers entirely around the OWASP Core Rule
Sets of mod_security rules. In future, it will allow you to manage/deploy
custom rule/rulesets of your own.

There are 2 main use cases right now:

## Install on a real production server

* Adjust the attributes to your liking and install the default
  recipe.

## Find out what ModSecurity could do for your site in less than 15-minutes.

* Setup a base chef recipe for a server.
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

# Requirements

## Cookbooks

This cookbook depends on apache2 and build-essential or IIS for Windows

## Platforms

### Supported
* Windows (tested on 2008R2 and 2012R2)
* Ubuntu (tested on 12.04 and 13.04)
* Debian (tested on 6.0.8 and 7.2.0)
* RedHat (untested)
* CentOS (tested on 6.5)
* Fedora (untested)
* FreeBSD (untested)
* Amazon Linux (tested on 20160701)

### Coming Soon
* Arch (anything else that apache2 supports)

# Attributes

Major ones will be documented soon.  For right now check the
attributes file.  A few suggestions

* Compile from source.  I normally prefer not to do this, but some
  core rules break if you don't
* crs->bundled determines if the bundled version of the crs should be used or 
  if the core rules are downloaded from the SpiderLabs GitHub releases.
* Base rules should generally be safe, the other groups much less
  so. There are some rules with inconsistently named data files that are
  fixed by this cookbook.
* custom->rules allows you to install your own custom rules
* custom->datafiles allows you to install your own data files to be used in 
  pmFromFile directives

Recipes
=======

default
-------
This installs base, the OWASP core rule set and your own custom rules, adjust
mod_security.install_base,mod_security.install_crs and mod_security.install_custom
to alter this behavior

install_base_apache
-------------------
Installs mod_security for Apache (!Windows)

install_base_iis
----------------
Installs mod_security for IIS (Windows)

install_owasp_core_rule_set
---------------------------
Install the bundled / chef template managed OWASP CRS

install_custom_rule_set
-----------------------
Reads custom->rules and custom->datafiles properties and creates .conf and .data 
files based on their contents in mod_security/rules which is included by the default
mod_security.conf file

License and Authors
===================

Author:: Jason Rohwedder <jro@honeyapps.com>
Author:: Frank Breedijk <fbreedijk@schubergphilis.com>
Author:: Gavin Reynolds <g.reynolds@src.gla.ac.uk>
Author:: Matthijs Wijers <mwijers@schubergphilis.com>
Author:: Steven Geerts <sgeerts@schubergphilis.com>

Copyright:: 2016, HoneyApps, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


