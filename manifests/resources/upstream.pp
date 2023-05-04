# define: nginx::resource::upstream
define nginx::resources::upstream (
  $file,
  $domain,
  $members    = undef,
  $ensure     = 'present',
  $context    = 'http',
  $ip_hash    = false,
  $least_conn = false,
) {
  concat::fragment { "${domain}-upstreams-${name}":
    target  => $file,
    content => template('nginx/vhost/parts/upstream.erb'),
    order   => '95',
  }
}
