name              "openldap"
maintainer        "Tomohiko Himura"
maintainer_email  "eiel.hal@gmail.com"
license           "MIT"
description       "Configures a server to be an OpenLDAP master"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"
recipe            "openldap", "configure server"

%w{ centos }.each do |os|
  supports os
end
