# define: nginx::resource::vhost

# positions
#   01 - head (server)
#   02 - listen
#
#   90 - server end
define nginx::resources::vhost (
    $root_folder       = undef,
    $domains           = ['_'],
    $ensure            = 'present',
    $listen_ip         = '*',
    $listen_port       = 80,

    ### IPv6
    $listen_v6         = false,
    $listen_v6_ip      = '::',
    $listen_v6_port    = 80,
    $listen_v6_options = 'default ipv6only=on',

    ### SSL
    $ssl               = false,
    $ssl_only          = false,
    $ssl_cert          = undef,
    $ssl_key           = undef,
    $http2             = false,

    ### HTTP AUTH
    $http_auth         = false,
    $http_auth_file    = '.htpasswd',
    $http_auth_url     = '/',

    ### PROXY
    $proxy             = undef,
    $proxy_headers     = $nginx::proxy_set_header,

    ### REWRITE
    $rewrite_www_to_non_www  = false,
    $rewrite_non_www_to_www  = false,

    ### ADDITIONS
    $includes          = [],
    $upstreams         = [],
    $locations         = {},
    $template          = undef,
    $type              = undef,
)
{
    validate_array($domains)

    if !(is_array($listen_ip) or is_string($listen_ip)) {
      fail('$listen_ip must be a string or array.')
    }

    if !is_integer($listen_port) {
      fail('$listen_port must be an integer.')
    }

    validate_bool($listen_v6)
    if !(is_array($listen_v6_ip) or is_string($listen_v6_ip)) {
      fail('$listen_v6_ip must be a string or array.')
    }

    if !is_integer($listen_v6_port) {
      fail('$listen_v6_port must be an integer.')
    }

    validate_string($listen_v6_options)

    validate_bool($ssl)
    if ($ssl) {
        validate_string($ssl_cert)
        validate_string($ssl_key)
        validate_bool($ssl_only)
    }
    validate_bool($http2)

    validate_bool($rewrite_non_www_to_www)
    validate_bool($rewrite_www_to_non_www)
    if($rewrite_non_www_to_www and $rewrite_www_to_non_www)
    {
      fail('www <-> non www loooop')
    }

    validate_bool($http_auth)
    if ($http_auth) {
        validate_string($http_auth_file)
    }

    if($template)
    {
        validate_string($template)
    }

    $main_domain = $domains[0]
    $conf_file = "/etc/nginx/sites-available/${main_domain}"

    if($template) {
        file { $conf_file:
            ensure  => $ensure,
            content => template($template),
        }
        File[$conf_file] ~> Service['nginx']
    } else {

        concat { $conf_file:
            ensure  => $ensure,
        }

        Concat[$conf_file] ~> Service['nginx']

        concat::fragment { "${main_domain}-head":
            target  => $conf_file,
            content => template('nginx/vhost/parts/head.erb'),
            order   => '01',
        }

        if($proxy){
          concat::fragment { "${main_domain}-body":
              target  => $conf_file,
              content => template('nginx/vhost/proxy.erb'),
              order   => '50',
          }
        }
        concat::fragment { "${main_domain}-footer":
            target  => $conf_file,
            content => template('nginx/vhost/parts/footer.erb'),
            order   => '99',
        }
    }


    case $ensure {
        'present' : {
            exec { "enable_${main_domain}":
                command => "ln -s /etc/nginx/sites-available/${main_domain} /etc/nginx/sites-enabled/",
                path    => '/bin',
                unless  => "/bin/readlink -e /etc/nginx/sites-enabled/${main_domain}",
            }
            Class['nginx::config'] -> Exec["enable_${main_domain}"] ~> Service['nginx']
        }
        'absent': {
            exec { "disable_${main_domain}":
                command => "rm /etc/nginx/sites-enabled/${main_domain}",
                path    => '/bin',
                onlyif  => "/bin/readlink -e /etc/nginx/sites-enabled/${main_domain}",
            }
            Class['nginx::config'] -> Exec["disable_${main_domain}"] ~> Service['nginx']
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }
}
