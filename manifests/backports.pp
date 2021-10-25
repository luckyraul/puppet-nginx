# == Class: nginx::backports
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
            $pin_package = [$nginx::package_name, 'nginx-common']
        }
        'stretch': {
          $pin_package = [
            $nginx::package_name,
            'nginx-common',
            'libnginx-mod-http-auth-pam',
            'libnginx-mod-http-cache-purge',
            'libnginx-mod-http-dav-ext',
            'libnginx-mod-http-echo',
            'libnginx-mod-http-fancyindex',
            'libnginx-mod-http-geoip',
            'libnginx-mod-http-headers-more-filter',
            'libnginx-mod-http-image-filter',
            'libnginx-mod-http-ndk',
            'libnginx-mod-http-lua',
            'libnginx-mod-http-perl',
            'libnginx-mod-http-subs-filter',
            'libnginx-mod-http-uploadprogress',
            'libnginx-mod-http-upstream-fair',
            'libnginx-mod-http-xslt-filter',
            'libnginx-mod-mail',
            'libnginx-mod-nchan',
            'libnginx-mod-stream'
          ]
        }
        default: {
          $pin_package = [$nginx::package_name, 'nginx-common']
        }
    }

    apt::pin { 'backports_nginx':
      ensure   => $ensure,
      packages => $pin_package,
      priority => 500,
      release  => "${::lsbdistcodename}-backports",
    }

    Exec['apt_update'] -> Package['nginx']
}
