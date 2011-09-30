#
# Cookbook Name:: mod_security
# Definition:: mod_secure_proxy
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

define :mod_secure_proxy, :enable => true do

  include_recipe "apache2"
  include_recipe "apache2::mod_proxy"
  include_recipe "apache2::mod_proxy_http"
  include_recipe "apache2::mod_proxy_connect"

  my_params = params
  
  web_app params[:name] do
    template "mod_secure_proxy.conf.erb"
    server_name my_params[:server_name]    
  end
  
end
