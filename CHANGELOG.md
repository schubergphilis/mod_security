chef-mod_security
=================

v0.1.0
-------------------
 * Updated to mod_security 2.7.7 and OWASP CRS 2.2.8
 * Downloading source and CRS tarballs from SpiderLabs GitHub releases
 * Added SHA256 verification of downloaded source and CRS tarballs
 * Downloading tarballs to Chef file cache path instead of under the mod_security dir
 * Added integration testing using test-kitchen across multiple platforms
 * Foodcritic and Rubocop fixes

v0.0.6
-------------------
 * version bump to fix packaging issue

v0.0.5
-------------------
 * add server alias support for mod_secure_proxy definition
 * test and fix data file loading issues in main,srl, and optional rulesets
 * identify experimental rulesets that don't work in our environment yet

v0.0.4
-------------------
 * add RedHat-based distro support

v0.0.2
-------------------
 * upgrade to mod_security 2.6.2
 * flesh out main config options as chef attributes

v0.0.4
-------------------
 * First release
