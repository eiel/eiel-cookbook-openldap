package 'openldap-servers' do
  action :upgrade
end

service 'rsyslog' do
  supports restrat: true, status: true
  action [:enable, :start]
end

service 'slapd' do
  supports restrat: true, status: true
  action [:enable, :start]
end

file "/etc/rsyslog.d/slapd.conf" do
  content "local4.* /var/log/slapd"
  notifies :restart, "service[rsyslog]"
end

slapd_dir = "/etc/openldap/slapd.d"

directory slapd_dir do
  owner "ldap"
  group "ldap"
end

template "/etc/openldap/slapd.conf" do
  owner "ldap"
  group "ldap"
  mode "0660"
  ldap = node["openldap"]
  rootpw = ldap["rootpw"]
  helper(:sha_hash) { |pw| `slappasswd -s #{rootpw}` }
  notifies :run, "execute[rm -rf slapd.d]", :immediately
end

execute "rm -rf slapd.d" do
  command "rm -rf #{slapd_dir}/*"
  action :nothing
  notifies :run, "execute[create files slapd.d]", :immediately
end

execute "create files slapd.d" do
  command "slaptest -f /etc/openldap/slapd.conf -F #{slapd_dir}"
  user "ldap"
  group "ldap"
  action :nothing
  notifies :restart, "service[slapd]", :immediately
end

# execute "copy DB_CONFIG" do
#   command "cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG"
# end

execute "create cert" do
  not_if "certutil -d /etc/openldap/certs/ -L | grep 'OpenLDAP Server'"
  command "hostname localhost.localdomain; /usr/libexec/openldap/generate-server-cert.sh"
end

bash "Setting LDAPS" do
  not_if 'grep "^[^#]*LAPD_LDAPS=yes" /etc/sysconfig/ldap'
  code <<-EOC
    sed -ie "s/^[^#]*SLAPD_LDAPS=no/SLAPD_LDAPS=yes/" /etc/sysconfig/ldap
  EOC
  notifies :restart, "service[slapd]"
end

execute "create ldap db" do
  not_if { File.exists?("/var/lib/ldap/id2entry.bdb" ) }
  command "slapadd -l /etc/openldap/schema/core.ldif || echo"
  user "ldap"
  group "ldap"
end
