# == Class: nginx::config
#
class nginx::config (
    $daemon_user                   = $nginx::daemon_user,
    $daemon_pid                    = $nginx::daemon_pid,
    $worker_connections            = $nginx::worker_connections,
    $multi_accept                  = $nginx::multi_accept,
    $sendfile                      = $nginx::sendfile,
    $tcp_nopush                    = $nginx::tcp_nopush,
    $tcp_nodelay                   = $nginx::tcp_nodelay,
    $keepalive_timeout             = $nginx::keepalive_timeout,
    $keepalive_requests            = $nginx::keepalive_requests,
    $reset_timedout_connection     = $nginx::reset_timedout_connection,
    $types_hash_bucket_size        = $nginx::types_hash_bucket_size,
    $types_hash_max_size           = $nginx::types_hash_max_size,
    $server_names_hash_max_size    = $nginx::server_names_hash_max_size,
    $server_names_hash_bucket_size = $nginx::server_names_hash_bucket_size,
    $server_tokens                 = $nginx::server_tokens,
    $client_max_body_size          = $nginx::client_max_body_size,
    $client_body_timeout           = $nginx::client_body_timeout,
    $open_file_cache               = $nginx::open_file_cache,
    $open_file_cache_valid         = $nginx::open_file_cache_valid,
    $open_file_cache_min_uses      = $nginx::open_file_cache_min_uses,
    $open_file_cache_errors        = $nginx::open_file_cache_errors,
    $fastcgi_read_timeout          = $nginx::fastcgi_read_timeout,
    $access_log                    = $nginx::access_log,
    $error_log                     = $nginx::error_log,
    $gzip                          = $nginx::gzip,
    $gzip_disable                  = $nginx::gzip_disable,
    $gzip_vary                     = $nginx::gzip_vary,
    $gzip_comp_level               = $nginx::gzip_comp_level,
    $gzip_types                    = $nginx::gzip_types
) inherits nginx::params
{


    file { '/etc/nginx/nginx.conf':
        ensure  => present,
        content => template('nginx/base/nginx.conf.erb'),
    }

    file { '/etc/nginx/sites-available':
        ensure  => directory,
    }

    file { '/etc/nginx/sites-enabled':
        ensure  => directory,
    }

    file { '/etc/nginx/ssl':
        ensure  => directory,
    }

    file { '/etc/nginx/geoip':
        ensure  => directory,
    }

    file { '/etc/nginx/includes':
        ensure  => directory,
    }

    if ! defined(File['/var/www']) {
        file {'/var/www':
            ensure => directory,
        }
    }
}
