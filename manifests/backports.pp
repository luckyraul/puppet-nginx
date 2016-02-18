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

    include apt::backports

    apt::pin { 'backports_nginx':
      ensure   => $ensure,
      packages => $nginx::package_name,
      priority => 500,
      release  => 'main',
    }
}
