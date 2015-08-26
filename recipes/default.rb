#
# Cookbook Name:: mod_security
# Recipe:: default
#
# Copyright 2011, HoneyApps Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if not platform_family?('windows')
  include_recipe 'apache2'
end

if node[:mod_security][:install_base] then
  include_recipe 'mod_security::install_base'
end

if node[:mod_security][:install_crs] then
  include_recipe 'mod_security::install_owasp_core_rule_set'
end

if node[:mod_security][:install_custom] then
  include_recipe 'mod_security::install_custom_rule_set'
end

if platform_family?('windows')
  execute 'iisreset' do
  action :nothing
  end
end

