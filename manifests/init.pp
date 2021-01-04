# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include observium
class observium {

# Check what OS we are on
if $facts['os']['family'] == 'RedHat' {
  include observium::yum
}

# install required packages
$required_packages = lookup('observium::required_packages', Array)
package { $required_packages:
  ensure => 'latest',
}

}
