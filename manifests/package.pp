# == Class: nginx::package
#
# Manages the installation and removal of the Nginx package
# and any additional packages required by the Nginx module.
#
# === Parameters
#
# [*package_ensure*]
#   Specifies the desired state of the Nginx package.
#   Valid values: 'absent', 'present', 'latest'.
#   Default: $nginx::package_ensure.
#
# [*package_name*]
#   Specifies the name of the Nginx package.
#   Default: $nginx::package_name.
#
# [*additional*]
#   Specifies a list of additional packages to manage.
#   Default: $nginx::additional_packages.
#
# === Raises
#
#   Fails if the operating system family is not supported.
#
class nginx::package (
  Enum['absent', 'present', 'latest'] $package_ensure = $nginx::package_ensure,
  String $package_name = $nginx::package_name,
  Array[String] $additional = $nginx::additional_packages,
) {
  assert_private()

  case $facts['os']['family'] {
    'RedHat', 'Debian': {
      package { 'nginx':
        ensure => $package_ensure,
        name   => $package_name,
      } -> package { $additional:
        ensure => $package_ensure,
      }
    }
    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}
