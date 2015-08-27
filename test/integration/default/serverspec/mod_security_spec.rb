require 'serverspec'

set :backend, :exec

describe 'Apache2 with mod_security' do

  it 'apache2 should be installed' do
    expect(package('apache2')).to be_installed
  end

  it 'apache2 should be running' do
    expect(service('apache2')).to be_running
  end

  it 'apache2 should be listening on port 80' do
    expect(port(80)).to be_listening
  end

  it 'apache2 should have a mod_security configuration file' do
    expect(file('/etc/apache2/mods-enabled/mod-security.conf')).to be_file
    expect(file('/etc/apache2/mods-enabled/mod-security.conf')).to contain 'Include "/etc/apache2/mod_security/*.conf"'
  end

  it 'apache2 should have a mod_security load file' do
    expect(file('/etc/apache2/mods-enabled/mod-security.load')).to be_file
    expect(file('/etc/apache2/mods-enabled/mod-security.load')).to contain 'LoadModule security2_module /usr/local/modsecurity/lib/mod_security2.so'
  end

  it 'mod_security module should exist' do
    expect(file('/usr/local/modsecurity/lib/mod_security2.so')).to be_file
  end

  it 'mod_security should be configured' do
    expect(file('/etc/apache2/mod_security/modsecurity.conf')).to be_file
    expect(file('/etc/apache2/mod_security/modsecurity.conf')).to contain 'SecRuleEngine DetectionOnly'
  end

end
