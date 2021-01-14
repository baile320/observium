# Class: obversium
#
# Init the observium database after install.
#
# @api private
#
class observium::database_init {
  assert_private()
  # Lookup location of mysql binary
  $mysql_location = lookup(observium::mysql_location, String)

  # init the database if the user table is not present
  exec { '/opt/observium/discovery.php -u':
    unless => "${mysql_location} -u observium --password=${observium::db_password} observium -e 'select * from users'"
  }

  exec { "/opt/observium/adduser.php admin ${observium::admin_password} 10": 
    unless => "${mysql_location} -u observium --password=${observium::db_password} observium -e 'select * from users WHERE username LIKE \"admin\"' | grep admin",
  }

  # add local host to database
  case $observium::snmpv3_authlevel {
    'noAuthNoPriv': { $v3auth = 'nanp' }
    'authNoPriv':   { $v3auth = 'anp' }
    'authPriv':     { $v3auth = 'ap' }
    default:        { $v3auth = 'any' }
  }
  exec { "/opt/observium/add_device.php 127.0.0.1 ${v3auth} v3 ${observium::snmpv3_authname} ${observium::snmpv3_authpass} ${observium::snmpv3_cryptopass} ${observium::snmpv3_authalgo} ${observium::snmpv3_cryptoalgo}":
    unless => "${mysql_location} -u observium --password=${observium::db_password} observium -e 'select hostname from devices WHERE hostname LIKE \"127.0.0.1\"' | grep 127.0.0.1",
  }

  # Perform discovery for nodes which have been added. 
  exec { '/opt/observium/discovery.php -h all':
    subscribe   => Exec["/opt/observium/add_device.php 127.0.0.1 ${v3auth} v3 ${observium::snmpv3_authname} ${observium::snmpv3_authpass} ${observium::snmpv3_cryptopass} ${observium::snmpv3_authalgo} ${observium::snmpv3_cryptoalgo}"],
    refreshonly => true,
  }

  exec { '/opt/observium/poller.php -h all':
    subscribe   => Exec["/opt/observium/add_device.php 127.0.0.1 ${v3auth} v3 ${observium::snmpv3_authname} ${observium::snmpv3_authpass} ${observium::snmpv3_cryptopass} ${observium::snmpv3_authalgo} ${observium::snmpv3_cryptoalgo}"],
    refreshonly => true,
  }
}
