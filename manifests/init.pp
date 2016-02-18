# == Class: nginx
# === Parameters
#
# [*ensure*]
#   Specify which version of Nginx packages to install, defaults to 'present'.
#   Please note that 'absent' to remove packages is not supported!
#
# [*official_repo*]
#   Include official repository to install recent Nginx
#
# [*dotdeb*]
#   Include dotdeb repository to install recent Nginx addons
#
class nginx (
    $ensure         = $nginx::params::ensure,
    $service_ensure = $nginx::params::service_ensure,
    $service_enable = $nginx::params::service_enable,
    $package_name   = $nginx::params::package_name,
    $backports      = true,
    $dotdeb         = false,
    ) inherits nginx::params {

    validate_string($ensure)

    if $backports and $dotdeb {
        fail("Can't use both dotdeb and backports repositories")
    }

    if $dotdeb {
        class { 'nginx::dotdeb': } -> Anchor['nginx::begin']
    }
    if $backports
        class { 'nginx::backports': } -> Anchor['nginx::begin']
    }

    anchor { 'nginx::begin': } -> class { 'nginx::packages': } -> anchor { 'nginx::end': }

}
