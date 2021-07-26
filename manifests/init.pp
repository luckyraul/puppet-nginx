# == Class: nginx
# === Parameters
#
# [*ensure*]
#   Specify which version of Nginx packages to install, defaults to 'present'.
#   Please note that 'absent' to remove packages is not supported!
#
# [*official_repo*]
#   Include official repository to install recent Nginx
#
# [*dotdeb*]
#   Include dotdeb repository to install recent Nginx addons
#
class nginx (
    $ensure                        = $nginx::params::ensure,
    $service_ensure                = $nginx::params::service_ensure,
    $service_enable                = $nginx::params::service_enable,
    $service_restart               = $nginx::params::service_restart,
    $package_name                  = $nginx::params::package_name,
    $backports                     = false,
    $dotdeb                        = false,
    $default_server                = true,
    $default_port                  = 80,
    $daemon_mode                   = $nginx::params::daemon_mode,
    $daemon_user                   = $nginx::params::daemon_user,
    $daemon_pid                    = $nginx::params::daemon_pid,
    $worker_connections            = $nginx::params::worker_connections,
    $worker_rlimit_nofile          = undef,
    $multi_accept                  = $nginx::params::multi_accept,
    $sendfile                      = $nginx::params::sendfile,
    $tcp_nopush                    = $nginx::params::tcp_nopush,
    $tcp_nodelay                   = $nginx::params::tcp_nodelay,
    $keepalive_timeout             = $nginx::params::keepalive_timeout,
    $keepalive_requests            = $nginx::params::keepalive_requests,
    $reset_timedout_connection     = $nginx::params::reset_timedout_connection,
    $types_hash_bucket_size        = $nginx::params::types_hash_bucket_size,
    $types_hash_max_size           = $nginx::params::types_hash_max_size,
    $server_names_hash_max_size    = $nginx::params::server_names_hash_max_size,
    $server_names_hash_bucket_size = $nginx::params::server_names_hash_bucket_size,
    $server_tokens                 = $nginx::params::server_tokens,
    $client_max_body_size          = $nginx::params::client_max_body_size,
    $client_body_timeout           = $nginx::params::client_body_timeout,
    $open_file_cache               = $nginx::params::open_file_cache,
    $open_file_cache_valid         = $nginx::params::open_file_cache_valid,
    $open_file_cache_min_uses      = $nginx::params::open_file_cache_min_uses,
    $open_file_cache_errors        = $nginx::params::open_file_cache_errors,
    $fastcgi_read_timeout          = $nginx::params::fastcgi_read_timeout,
    $access_log                    = $nginx::params::access_log,
    $error_log                     = $nginx::params::error_log,
    $gzip                          = $nginx::params::gzip,
    $gzip_disable                  = $nginx::params::gzip_disable,
    $gzip_vary                     = $nginx::params::gzip_vary,
    $gzip_comp_level               = $nginx::params::gzip_comp_level,
    $gzip_types                    = $nginx::params::gzip_types,
    $log_format                    = {},

    ### PROXY
    $proxy_cache_path              = $nginx::params::proxy_cache_path,
    $proxy_cache_use_stale         = $nginx::params::proxy_cache_use_stale,
    $proxy_cache_revalidate        = $nginx::params::proxy_cache_revalidate,
    $proxy_cache_min_uses          = $nginx::params::proxy_cache_min_uses,
    $proxy_cache_lock              = $nginx::params::proxy_cache_lock,
    $proxy_cache_key               = $nginx::params::proxy_cache_key,
    $proxy_buffers                 = $nginx::params::proxy_buffers,
    $proxy_buffer_size             = $nginx::params::proxy_buffer_size,

    ### HIERA ###
    $nginx_vhosts                  = {},
    $nginx_vhosts_defaults         = {require => Class['nginx::config']},
    $nginx_maps                    = {},
    $nginx_limit_zones             = {},

    #### Docker
    $docker                        = false,
    $docker_combo                  = false,

    ) inherits nginx::params
{
    if $backports and $dotdeb {
        fail("Can't use both dotdeb and backports repositories")
    }

    if $dotdeb {
        class { 'nginx::dotdeb': } -> Anchor['nginx::begin']
    }
    if $backports and ($::operatingsystem == 'Debian') {
        class { 'nginx::backports': } -> Anchor['nginx::begin']
    }

    class { 'nginx::packages': } -> class { 'nginx::config': } ~> class { 'nginx::service': }

    create_resources('nginx::resources::map', $nginx_maps, {require => Class['nginx::config'], notify  => Class['nginx::service']})
    create_resources('nginx::resources::limit_zone', $nginx_limit_zones, {require => Class['nginx::config'], notify  => Class['nginx::service']})
    create_resources('nginx::resources::vhost', $nginx_vhosts, $nginx_vhosts_defaults)

    anchor { 'nginx::begin':
        before => Class['nginx::packages'],
        notify => Class['nginx::service'],
    }

    anchor { 'nginx::end':
        require => Class['nginx::service'],
    }

    if $docker {
        file {'/entrypoint.sh':
            owner   => root,
            group   => root,
            mode    => '0755',
            content => template('nginx/docker/entrypoint.sh.erb'),
        }
    }

    if $docker or $docker_combo {
        file {$access_log:
          ensure  => 'link',
          target  => '/dev/stdout',
          require => Class['nginx::packages'],
        }

        file {$error_log:
          ensure  => 'link',
          target  => '/dev/stderr',
          require => Class['nginx::packages'],
        }
    }
}
