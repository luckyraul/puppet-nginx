# define: nginx::resource::location
define nginx::resources::location (
  $file,
  $domain,
  $location = undef,
  $config = undef,
  $extra_cfg = undef,
)
{
  validate_string($location)
  validate_hash($config)

  concat::fragment { "${domain}-locations-${name}":
      target  => $file,
      content => template('nginx/vhost/parts/location.erb'),
      order   => '70',
  }
}
