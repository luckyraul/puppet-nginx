# @summary Manage NGINX bootstrap and configuration
# @api private
class nginx::config (
  Array[String] $default_directories = $nginx::params::default_directories,
) {
  assert_private()

  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    content => template('nginx/base/config.epp'),
    notify  => [Exec['nginx_config_check'], Service['nginx']],
  }

  file { $default_directories:
    ensure  => directory,
  }

  ensure_resource('file', '/var/www', { 'ensure' => 'directory' })
}
