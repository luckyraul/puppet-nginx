# == Class: nginx::params
#
# Defines default parameters for the Nginx module.
#
class nginx::params {
  $package_ensure = 'present'

  $service_ensure = 'running'
  $service_enable = true
  $service_config_check_command = 'nginx -t'
  $service_restart = 'systemctl reload nginx'
  $default_directories = [
    '/etc/nginx/sites-enabled',
    '/etc/nginx/conf.d',
    '/etc/nginx/sites-available',
    '/etc/nginx/ssl',
    '/etc/nginx/geoip',
    '/etc/nginx/includes',
    '/etc/nginx/htpasswd',
  ]

  case $facts['os']['family'] {
    'debian': {
      $additional = ['libnginx-mod-http-brotli-filter','libnginx-mod-http-brotli-static']
      $package_name = 'nginx-extras'
      $brotli = true
    }
    default: {
      fail("Unsupported os: ${facts['os']['name']}")
    }
  }
}
