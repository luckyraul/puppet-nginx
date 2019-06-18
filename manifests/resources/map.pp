# define: nginx::resource::map
define nginx::resources::map (
    $key,
    $var,
    $mappings,
    $ensure = 'present',
    $default = undef,
    $hostnames = undef,
)
{
    $ensure_real = $ensure ? {
      'absent' => absent,
      default  => 'file',
    }

    file { "/etc/nginx/conf.d/${name}-map.conf":
        ensure  => $ensure_real,
        owner   => 'root',
        mode    => '0644',
        content => template('nginx/includes/map.erb'),
    }
}
