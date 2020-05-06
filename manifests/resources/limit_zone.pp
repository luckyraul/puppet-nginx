# define: nginx::resources::limit_zone
define nginx::resources::limit_zone (
    $key,
    $type,
    $size,
    $rate = undef,
    $ensure = 'present',
)
{
    # validate_string($key)
    # validate_string($type)
    # validate_string($size)
    if ($rate != undef) {
      # validate_string($rate)
      $rate_real = " rate=${rate}"
    } else {
      $rate_real = ''
    }

    $ensure_real = $ensure ? {
      'absent' => absent,
      default  => 'file',
    }

    file { "/etc/nginx/conf.d/${name}-limit_${type}_zone.conf":
        ensure  => $ensure_real,
        owner   => 'root',
        mode    => '0644',
        content => "limit_${type}_zone ${key} zone=${name}:${size}${rate_real};",
    }
}
