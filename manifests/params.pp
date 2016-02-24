# == Class: nginx::params
class nginx::params {
    $ensure = present
    $service_ensure = 'running'
    $service_enable = true
    $daemon_user = 'www-data'
    $daemon_pid = '/var/run/nginx.pid'
    $worker_connections = 1024
    $multi_accept = 'on'
    $sendfile = 'on'
    $tcp_nopush = 'on'
    $tcp_nodelay = 'on'

    $keepalive_timeout = 65
    $keepalive_requests = 100
    $reset_timedout_connection = 'on'

    $types_hash_bucket_size = '512'
    $types_hash_max_size = '2048'
    $server_names_hash_max_size = '512'
    $server_names_hash_bucket_size = '96'
    $server_tokens = 'off'


    $client_max_body_size = '256M'
    $client_body_timeout = 10

    $open_file_cache = 'max=200000 inactive=20s'
    $open_file_cache_valid = '2m'
    $open_file_cache_min_uses = 2
    $open_file_cache_errors = 'on'

    $fastcgi_read_timeout = 1200

    $access_log = '/var/log/nginx/access.log'
    $error_log = '/var/log/nginx/error.log'

    $gzip = 'on'
    $gzip_disable = 'msie6'
    $gzip_vary = 'on'
    $gzip_comp_level = 6
    $gzip_types = ['text/plain','text/css','application/json','application/javascript','application/x-javascript','text/xml','application/xml','application/rss+xml','text/javascript','image/svg+xml','application/vnd.ms-fontobject','application/x-font-ttf','font/opentype']

    case $::operatingsystem {
        'Debian': {
            case $::lsbdistcodename {
                'wheezy', 'jessie': {
                    $package_name = 'nginx-extras'
                }
                default: {
                    fail("Unsupported release: ${::lsbdistcodename}")
                }
            }
        }
        default: {
            fail("Unsupported os: ${::operatingsystem}")
        }
    }
}
