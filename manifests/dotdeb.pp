# == Class: nginx::dotdeb
class nginx::dotdeb(
    $location = 'http://packages.dotdeb.org',
    $repos    = 'all',
    $key      = {
        'id'     => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
        'source' => 'http://www.dotdeb.org/dotdeb.gpg',
    },
)
{
    include apt
    create_resources(::apt::key, { 'nginx::dotdeb' => {
        key => $key['id'], key_source => $key['source'],
    }})

    ::apt::source { "dotdeb_nginx_${::lsbdistcodename}":
        location    => $location,
        release     => $::lsbdistcodename,
        repos       => $repos,
        include_src => false,
        require     => Apt::Key['nginx::dotdeb'],
    }
}
