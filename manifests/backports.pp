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

    apt::pin { 'backports_nginx':
      ensure   => $ensure,
      packages => [$nginx::package_name,'nginx-common'],
      priority => 500,
      release  => "${::lsbdistcodename}-backports",
    } ~> Exec['apt-update']
}
