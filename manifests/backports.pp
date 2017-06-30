# == Class: nginx::dotdeb
class nginx::backports(
    $enabled    = $nginx::backports,
)
{
    if($enabled) {
        $ensure = 'present'
    } else {
        $ensure = 'absent'
    }

    include apt
    include apt::backports

    case $::lsbdistcodename {
        'jessie': {
            apt::pin { 'backports_ssl':
              ensure   => $ensure,
              packages => ['libssl1.0.0'],
              priority => 500,
              release  => "${::lsbdistcodename}-backports",
            }
        }
        default: {

        }
    }

    apt::pin { 'backports_nginx':
      ensure   => $ensure,
      packages => [$nginx::package_name,'nginx-common'],
      priority => 500,
      release  => "${::lsbdistcodename}-backports",
    }

    Exec['apt_update'] -> Package['nginx']
}
