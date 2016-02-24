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
    $package_name                  = $nginx::params::package_name,
    $backports                     = true,
    $dotdeb                        = false,
    $default_server                = true,
    $daemon_user                   = $nginx::params::daemon_user,
    $daemon_pid                    = $nginx::params::daemon_pid,
    $worker_connections            = $nginx::params::worker_connections,
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
    $gzip_types                    = $nginx::params::gzip_types
    ) inherits nginx::params
{

    validate_string($ensure)

    if $backports and $dotdeb {
        fail("Can't use both dotdeb and backports repositories")
    }

    if $dotdeb {
        class { 'nginx::dotdeb': } -> Anchor['nginx::begin']
    }
    if $backports {
        class { 'nginx::backports': } -> Anchor['nginx::begin']
    }

    anchor { 'nginx::begin': } -> class { 'nginx::packages': } -> class { 'nginx::config': } -> anchor { 'nginx::end': }

}
