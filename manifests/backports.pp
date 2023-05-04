# == Class: nginx::backports
class nginx::backports (
  $enabled    = $nginx::backports,
) {
  if($enabled) {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  include apt
  include apt::backports

  $pin_package = [$nginx::package_name, 'nginx-common']

  apt::pin { 'backports_nginx':
    ensure   => $ensure,
    packages => $pin_package,
    priority => 500,
    release  => "${facts['os']['distro']['codename']}-backports",
  }

  Exec['apt_update'] -> Package['nginx']
}
