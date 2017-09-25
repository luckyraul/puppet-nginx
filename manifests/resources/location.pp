# define: nginx::resource::location
define nginx::resources::location (
  $file,
  $domain,
  $location          = undef,
  $config            = {},
  $locations         = [],
  $extra_cfg         = undef,
  $internal          = false,
  $http_auth         = false,
  $http_auth_file    = undef,
  $http_auth_var     = undef,
  $http_auth_allow   = undef,
  $http_auth_deny    = undef,
  $http_auth_satisfy = undef,
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
