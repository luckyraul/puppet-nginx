# == Class: nginx::packages

class nginx::packages (
  $ensure       = $nginx::ensure,
  $package_name = $nginx::package_name,
  $additional   = $nginx::additional_packages,
)  inherits nginx::params {
  package { 'nginx':
    ensure => $ensure,
    name   => $package_name,
  } -> package { $additional:
    ensure => $ensure,
  }
}
