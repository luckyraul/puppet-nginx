# == Class: nginx::params
class nginx::params {
  $ensure = present
  $service_ensure = 'running'
  $service_restart = '/etc/init.d/nginx reload' # systemctl reload nginx.service
  $service_enable = true
  $daemon_user = 'www-data'
  $daemon_mode = 'on'
  $daemon_pid = '/var/run/nginx.pid'
  $default_directories = ['/etc/nginx/sites-enabled','/etc/nginx/conf.d','/etc/nginx/sites-available','/etc/nginx/ssl','/etc/nginx/geoip','/etc/nginx/includes','/etc/nginx/htpasswd']

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
  $gzip_comp_level = 1
  $gzip_types = ['text/plain','text/css','application/json','application/javascript','application/x-javascript','text/xml','application/xml','application/rss+xml','text/javascript','image/svg+xml','application/vnd.ms-fontobject','application/x-font-ttf','font/opentype','image/x-icon']

  #proxy
  $proxy_cache_path = undef
  $proxy_cache_use_stale = 'off'
  $proxy_cache_revalidate = 'off'
  $proxy_cache_min_uses = 1
  $proxy_cache_lock = 'off'
  $proxy_http_version = '1.1'
  $proxy_cache_key = '$scheme$proxy_host$request_uri'
  $proxy_buffers = '32 4k'
  $proxy_buffer_size = '8k'

  $proxy_set_header = [
    'Host $host',
    'X-Real-IP $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
    'X-Forwarded-Proto $scheme',
    'Connection ""',
  ]

  case $facts['os']['name'] {
    'Debian': {
      case $facts['os']['distro']['codename'] {
        'bookworm','trixie': {
          $additional = ['libnginx-mod-http-brotli-filter','libnginx-mod-http-brotli-static']
          $package_name = 'nginx-extras'
          $brotli = true
        }
        'stretch', 'buster', 'bullseye': {
          $additional = []
          $package_name = 'nginx-extras'
          $brotli = false
        }
        default: {
          fail("Unsupported release: ${facts['os']['distro']['codename']}")
        }
      }
    }
    'Ubuntu': {
      case $facts['os']['distro']['codename'] {
        'noble': {
          $additional = ['libnginx-mod-http-brotli-filter','libnginx-mod-http-brotli-static']
          $package_name = 'nginx-extras'
          $brotli = true
        }
        'focal','jammy': {
          $additional = []
          $package_name = 'nginx-extras'
          $brotli = false
        }
        default: {
          fail("Unsupported release: ${facts['os']['distro']['codename']}")
        }
      }
    }
    default: {
      fail("Unsupported os: ${facts['os']['name']}")
    }
  }
}
