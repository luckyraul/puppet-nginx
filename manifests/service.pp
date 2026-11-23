# == Class: nginx::service
class nginx::service {
  assert_private()
  $service_require = Exec['nginx_config_check']

  exec { 'nginx_config_check':
    command     => $nginx::service_config_check_command,
    refreshonly => true,
    require     => Package['nginx'],
    path        => [
      '/usr/sbin',
    ],
  }

  service { 'nginx':
    ensure  => $nginx::service_ensure,
    enable  => $nginx::service_enable,
    restart => $nginx::service_restart,
    require => Exec['nginx_config_check'],
  }
}
