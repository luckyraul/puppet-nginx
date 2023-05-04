# == Class: nginx::dhparam
#
class nginx::dhparam (
  $key_size = 2048,
  $location = '/etc/nginx/ssl/dhparam.pem',
  $config_location = '/etc/nginx/conf.d/dhparam.conf'
) {
  exec { 'generate dh param':
    command => "/usr/bin/openssl dhparam -out ${location} ${key_size}",
    creates => $location,
  }
  file { $config_location:
    content => "ssl_dhparam ${location};",
    owner   => 'root',
    group   => 'root',
    require => Exec['generate dh param'],
  }
}
