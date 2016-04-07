# define: nginx::resource::vhost
define nginx::resources::vhost (
    $root_folder    = undef,
    $domain         = '_',
    $ensure         = 'present',
    $listen_ip      = '*',
    $listen_port    = 80,
    $domain_alias   = [],
    $ssl            = false,
    $ssl_cert       = undef,
    $ssl_key        = undef,
    $http2          = false,
    $http_auth      = false,
    $http_auth_file = '.htpasswd',
    $http_auth_url  = '/',
    $template       = undef,
    $upstreams      = [],
    $type           = undef,
)
{
    if ($ssl) {
        validate_string($ssl_cert)
        validate_string($ssl_key)
    }

    if ($http_auth) {
        validate_string($http_auth_file)
    }

    if(!$template)
    {
        validate_string($type)
    }

    $conf_file = "/etc/nginx/sites-available/${domain}"

    if($template) {
        file { $conf_file:
            ensure  => $ensure,
            content => template($template),
        }
        File[$conf_file] ~> Service['nginx']
    } else {
        if($type) {
            concat { $conf_file:
                ensure  => $ensure,
            }

            Concat[$conf_file] ~> Service['nginx']

            concat::fragment { "${domain}-server":
                target  => $conf_file,
                content => "server {\n",
                order   => '01',
            }
            concat::fragment { "${domain}-server_end":
                target  => $conf_file,
                content => "}\n",
                order   => '90',
            }
            concat::fragment { "${domain}-listen":
                target  => $conf_file,
                content => template('nginx/vhost/parts/listen.erb'),
                order   => '02',
            }
            case $type {
                'static': {
                    concat::fragment { "${domain}-body":
                        target  => $conf_file,
                        content => template('nginx/vhost/static.erb'),
                        order   => '10',
                    }
                }
                'proxy': {
                    $domain_sanit = regsubst($domain, '\.', '_', 'G')
                    $app = "proxy-${domain_sanit}"
                    concat::fragment { "${domain}-upstream":
                        target  => $conf_file,
                        content => template('nginx/vhost/parts/upstream.erb'),
                        order   => '91',
                    }
                    concat::fragment { "${domain}-body":
                        target  => $conf_file,
                        content => template('nginx/vhost/proxy.erb'),
                        order   => '19',
                    }
                }
                default: { err ( "Unknown template type: '${type}'" ) }
            }
        }
    }

    case $ensure {
        'present' : {
            exec { "enable_${domain}":
                command => "ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/",
                path    => '/bin',
                unless  => "/bin/readlink -e /etc/nginx/sites-enabled/${domain}",
            }
            Class['nginx::config'] -> Exec["enable_${domain}"] ~> Service['nginx']
        }
        'absent': {
            exec { "disable_${domain}":
                command => "rm /etc/nginx/sites-enabled/${domain}",
                path    => '/bin',
                onlyif  => "/bin/readlink -e /etc/nginx/sites-enabled/${domain}",
            }
            Class['nginx::config'] -> Exec["disable_${domain}"] ~> Service['nginx']
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }
}
