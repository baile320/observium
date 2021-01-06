# Class: obversium
#
# Init the database after install.
#
class observium::database_init inherits observium {
  # init the database if the user table is not present
  exec { '/opt/observium/discovery.php -u':
    unless => "/bin/mysql -u observium --password=${db_password} observium -e 'select * from users'"
  }

  exec { "/opt/observium/adduser.php admin ${admin_password} 10": 
    unless => "/bin/mysql -u observium --password=${db_password} observium -e 'select * from users WHERE username LIKE \"admin\"' | grep admin",
  }

  # add local host to database
  exec { "/opt/observium/add_device.php 127.0.0.1 ap v3 ${snmpv3_authname} ${snmpv3_authpass} ${snmpv3_cryptopass} ${snmpv3_authalgo} ${snmpv3_cryptoalgo}":
    unless => "/bin/mysql -u observium --password=changeme observium -e 'select hostname from devices WHERE hostname LIKE \"127.0.0.1\"' | grep 127.0.0.1",
  }
}
