# == Class: nginx
#
# Manages the Nginx web server package and service.
#
# === Parameters
#
# [*package_ensure*]
#   Specifies the desired package state.
#   Valid values: 'absent', 'present', 'latest'.
#   Default: 'present'.
#
# [*package_name*]
#   Name of the Nginx package to install.
#
# [*additional_packages*]
#   Additional packages required by Nginx.
#
# [*service_ensure*]
#   Specifies the desired service state.
#   Default: 'running'.
#
# [*service_enable*]
#   Whether the Nginx service should start at boot.
#   Default: true.
#
# [*service_config_check_command*]
#   Command used to validate the Nginx configuration.
#
# [*service_restart*]
#   Command used to reload the Nginx service.
#   Default: 'systemctl reload nginx'.
#
class nginx (
  Enum['absent', 'present', 'latest'] $package_ensure = $nginx::params::package_ensure,
  String $package_name = $nginx::params::package_name,
  Array[String] $additional_packages = $nginx::params::additional,
  Stdlib::Ensure::Service $service_ensure = $nginx::params::service_ensure,
  Boolean $service_enable = $nginx::params::service_enable,
  String $service_config_check_command = $nginx::params::service_config_check_command,
  String $service_restart = $nginx::params::service_restart,
  Boolean $default_server = true,
  Integer $default_port = 80,
) inherits nginx::params {
  contain 'nginx::package'
  contain 'nginx::config'
  contain 'nginx::service'
}
