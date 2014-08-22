# サンプルーデータつき

include_recipe "openldap::default"

package "openldap-clients" do
  action :upgrade
end

cookbook_file "/root/passwd.ldif"

ldap = node["openldap"]

execute "slapd add passwd.ldif" do
  not_if 'ldapsearch -x -b "dc=my-domain,dc=com" dn | grep ^dn'
  rootpw = ldap["rootpw"]
  rootdn = ldap["rootdn"]
  command %Q{ldapadd -D "#{rootdn}" -w "#{rootpw}" -f /root/passwd.ldif}
end
