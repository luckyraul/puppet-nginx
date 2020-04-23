# == Class: nginx::config
#
class nginx::config (
    $default_server                = $nginx::default_server,
    $default_port                  = $nginx::default_port,
    $default_directories           = $nginx::params::default_directories,
    $daemon_mode                   = $nginx::daemon_mode,
    $daemon_user                   = $nginx::daemon_user,
    $daemon_pid                    = $nginx::daemon_pid,
    $worker_connections            = $nginx::worker_connections,
    $worker_rlimit_nofile          = $nginx::worker_rlimit_nofile,
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
    $gzip_types                    = $nginx::gzip_types,
    $log_format                    = $nginx::log_format,
    $proxy_cache_path              = $nginx::proxy_cache_path,
    $proxy_cache_use_stale         = $nginx::proxy_cache_use_stale,
    $proxy_cache_revalidate        = $nginx::proxy_cache_revalidate,
    $proxy_cache_min_uses          = $nginx::proxy_cache_min_uses,
    $proxy_cache_lock              = $nginx::proxy_cache_lock,
    $proxy_cache_key               = $nginx::proxy_cache_key,
    $proxy_buffers                 = $nginx::proxy_buffers,
    $proxy_buffer_size             = $nginx::proxy_buffer_size
) inherits nginx::params
{

  case $::operatingsystem {
      'Debian', 'Ubuntu': {
          case $::lsbdistcodename {
              'jessie', 'stretch', 'xenial': {
                  $tls = 'TLSv1.2'
              }
              default: {
                  $tls = 'TLSv1.2 TLSv1.3'
              }
          }
      }
      default: {
          fail("Unsupported os: ${::operatingsystem}")
      }
  }

    file { '/etc/nginx/nginx.conf':
        ensure  => present,
        content => template('nginx/base/nginx.conf.erb'),
    }

    if $default_server {
        file { '/etc/nginx/sites-available/default':
            ensure  => present,
            content => template('nginx/vhost/default.erb'),
        }

        file { '/etc/nginx/sites-enabled/default':
            ensure => 'link',
            target => '/etc/nginx/sites-available/default',
        }

        file { '/tmp/acme-challenge':
            ensure => 'directory',
        }

        File[$default_directories] -> File['/etc/nginx/sites-available/default'] -> File['/etc/nginx/sites-enabled/default']

    } else {
        file { '/etc/nginx/sites-available/default':
            ensure  => absent,
        }
        file { '/etc/nginx/sites-enabled/default':
            ensure  => absent,
        }

        file { '/tmp/acme-challenge':
            ensure => 'absent',
        }
    }

    file { '/etc/nginx/conf.d/default.conf':
        ensure  => absent,
    }

    file { $default_directories:
        ensure  => directory,
    }

    File[$default_directories] -> class { 'nginx::dhparam': }

    file { '/etc/nginx/includes/static_files':
        ensure  => present,
        require => File[$default_directories],
        content => template('nginx/includes/static.erb'),
    }

    file { '/etc/nginx/includes/ssl':
        ensure  => present,
        require => File[$default_directories],
        content => template('nginx/includes/ssl.erb'),
    }

    file { '/etc/nginx/includes/cloudflare':
        ensure  => present,
        require => File[$default_directories],
        content => template('nginx/includes/cloudflare.erb'),
    }

    file { '/etc/nginx/includes/security':
        ensure  => present,
        require => File[$default_directories],
        content => template('nginx/includes/security.erb'),
    }

    file { '/etc/nginx/includes/acme':
        ensure  => present,
        require => File[$default_directories],
        content => template('nginx/includes/acme.erb'),
    }

    ensure_resource('file', '/var/www', {'ensure' => 'directory' })
}
