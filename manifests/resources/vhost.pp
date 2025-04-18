# define: nginx::resource::vhost

# positions
#   01 - head (server)
#   02 - listen
#
#
#   50 - body directory
#   51 - body proxy
#
#   70 - locations
#
#   90 - server end
#
#   95 - upstreams
define nginx::resources::vhost (
  $root_folder                         = undef,
  $custom_name                         = undef,
  $domains                             = ['_'],
  $ensure                              = 'present',
  Variant[Array, String] $listen_ip    = '*',
  Stdlib::Port $listen_port            = 80,
  $listen_options                      = undef,

  ### IPv6
  $listen_v6                           = false,
  Variant[Array, String] $listen_v6_ip = '::',
  Stdlib::Port $listen_v6_port         = 80,
  $listen_v6_options                   = 'default ipv6only=on',

  ### SSL
  $ssl                                 = false,
  $ssl_port                            = 443,
  $ssl_only                            = false,
  $ssl_cert                            = undef,
  $ssl_key                             = undef,
  $ssl_stapling                        = false,
  $ssl_stapling_verify                 = false,
  $ssl_resolver                        = '8.8.8.8 8.8.4.4',
  $ssl_root                            = undef,
  $http2                               = true,

  ### HTTP AUTH
  $http_auth                           = undef,
  $http_auth_var                       = 'Restricted',
  $http_auth_file                      = '.htpasswd',
  $http_auth_url                       = '/',
  $http_auth_file_content              = undef,
  $http_auth_allow                     = ['127.0.0.1'],
  $http_auth_deny                      = ['all'],
  $http_auth_satisfy                   = 'any',

  ### PROXY
  $proxy                               = undef,
  $proxy_headers                       = $nginx::params::proxy_set_header,
  $proxy_http_version                  = $nginx::params::proxy_http_version,
  $proxy_read_timeout                  = undef,
  $proxy_buffering                     = undef,
  $proxy_limit_req                     = undef,
  $proxy_limit_req_burst               = undef,
  $proxy_limit_req_delay               = undef,
  $proxy_limit_req_status              = undef,
  $proxy_sub_filter                    = [],
  $proxy_sub_filter_once               = undef,
  $proxy_sub_filter_types              = undef,
  $proxy_next_upstream                 = undef,
  $proxy_hide_header                   = undef,
  $proxy_extra_cfg                     = undef,

  ### REAL IP
  $real_ip_from                        = [],
  $real_ip_header                      = undef,
  $real_ip_recursive                   = undef,

  ### RETURN
  $return                              = undef,

  ### MODSECURITY
  $modsecurity                         = undef,
  $modsecurity_rules_file              = undef,

  ### REWRITE
  $rewrite_www_to_non_www              = false,
  $rewrite_non_www_to_www              = false,
  $rewrite_to_https                    = false,

  ### ADDITIONS
  $index_files                         = [],
  $includes                            = [],
  $variables                           = {},
  $headers                             = [],
  $error_pages                         = {},
  $upstreams                           = {},
  $locations                           = {},
  $try_files                           = undef,
  $template                            = undef,
  $type                                = undef,
  $charset                             = undef,
  $autoindex                           = undef,
  $extra_cfg                           = undef,

  $external                            = false,
) {
  if($rewrite_non_www_to_www and $rewrite_www_to_non_www) {
    fail('www <-> non www loooop')
  }

  if($rewrite_to_https and $ssl_only) {
    fail('choose beetween https <-> http with https redirect')
  }

  $main_domain = $domains[0]

  if ($custom_name) {
    $conf_file_name = $custom_name
  } else {
    $conf_file_name = $main_domain
  }

  $conf_file = "/etc/nginx/sites-available/${conf_file_name}"

  if($http_auth != undef and $http_auth_file_content != undef) {
    if(is_absolute_path($http_auth_file)) {
      file { $http_auth_file:
        ensure  => $ensure,
        content => $http_auth_file_content,
      }
    } else {
      file { "/etc/nginx/${http_auth_file}":
        ensure  => $ensure,
        content => $http_auth_file_content,
      }
    }
  }

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

    if($upstreams) {
      $nginx_upstream_defaults = { 'file' => $conf_file, 'domain' => $main_domain }
      create_resources('nginx::resources::upstream', $upstreams, $nginx_upstream_defaults)
    }

    if(!$proxy and $http_auth and $http_auth_url == '/') {
      $auth_locations = {
        "${main_domain}-root"      => {
          location          => '/',
          http_auth         => true,
          http_auth_var     => $http_auth_var,
          http_auth_file    => $http_auth_file,
          http_auth_allow   => $http_auth_allow,
          http_auth_deny    => $http_auth_deny,
          http_auth_satisfy => $http_auth_satisfy,
        },
      }
    } else {
      $auth_locations = {}
    }

    if($locations) {
      $nginx_location_defaults = { 'file' => $conf_file, 'domain' => $main_domain }
      create_resources('nginx::resources::location', deep_merge($auth_locations, $locations), $nginx_location_defaults)
    }

    if($error_pages) {
      concat::fragment { "${main_domain}-error_pages":
        target  => $conf_file,
        content => template('nginx/vhost/parts/error_pages.erb'),
        order   => '49',
      }
    }

    if($root_folder) {
      concat::fragment { "${main_domain}-body":
        target  => $conf_file,
        content => template('nginx/vhost/directory.erb'),
        order   => '50',
      }
    }

    if($proxy) {
      concat::fragment { "${main_domain}-proxy":
        target  => $conf_file,
        content => template('nginx/vhost/proxy.erb'),
        order   => '51',
      }
    }

    concat::fragment { "${main_domain}-footer":
      target  => $conf_file,
      content => template('nginx/vhost/parts/footer.erb'),
      order   => '90',
    }
  }

  case $ensure {
    'present' : {
      exec { "enable_${main_domain}":
        command => "ln -s ${conf_file} /etc/nginx/sites-enabled/",
        path    => '/bin',
        unless  => "/bin/readlink -e /etc/nginx/sites-enabled/${conf_file_name}",
      }
      if(!$external) {
        Class['nginx::config'] -> Exec["enable_${main_domain}"] ~> Service['nginx']
      }
    }
    'absent': {
      exec { "disable_${main_domain}":
        command => "rm /etc/nginx/sites-enabled/${conf_file_name}",
        path    => '/bin',
        onlyif  => "/bin/readlink -e /etc/nginx/sites-enabled/${conf_file_name}",
      }
      if(!$external) {
        Class['nginx::config'] -> Exec["disable_${main_domain}"] ~> Service['nginx']
      }
    }
    default: { err ( "Unknown ensure value: '${ensure}'" ) }
  }
}
