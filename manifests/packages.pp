# == Class: nginx::packages

class nginx::packages (
    $ensure       = $nginx::ensure,
    $package_name = $nginx::package_name,
)  {
    include nginx::params

    package { 'nginx':
        ensure => $ensure,
        name   => $package_name,
    }
}
