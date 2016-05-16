# define: nginx::resource::upstream
define nginx::resources::upstream (
    $file,
    $domain,
    $members = undef,
    $ensure = 'present',
    $context = 'http',
)
{
    if $members != undef {
        validate_array($members)
    }

    validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

    concat::fragment { "${domain}-upstreams-${name}":
        target  => $file,
        content => template('nginx/vhost/parts/upstream.erb'),
        order   => '95',
    }
}
