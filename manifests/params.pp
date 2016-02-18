# == Class: nginx::params
class nginx::params {
    $ensure = present
    $service_ensure = 'running'
    $service_enable = true
    case $::operatingsystem {
        'Debian': {
            case $::lsbdistcodename {
                'wheezy', 'jessie': {
                    $package_name = 'nginx-extras'
                }
                default: {
                    fail("Unsupported release: ${::lsbdistcodename}")
                }
            }
        }
        default: {
            fail("Unsupported os: ${::operatingsystem}")
        }
    }
}
