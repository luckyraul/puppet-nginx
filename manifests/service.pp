# == Class: nginx::service
class nginx::service (
    $service_ensure   = $nginx::service_ensure,
    $service_enable   = $nginx::service_enable,
    $service_restart  = $nginx::service_restart,
)
{
    service {'nginx':
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasstatus  => true,
        hasrestart => true,
        restart    => $service_restart,
    }
}
