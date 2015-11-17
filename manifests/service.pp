class adclient::service inherits adclient {
    if !empty($::ad_info) and !empty($::ad_computer) {
        $service_ensure = 'running'
        $service_enable = true
    } else {
        $service_ensure = 'stopped'
        $service_enable = false
    }
    service { "winbind":
        ensure => $service_ensure,
        enable => $service_enable
    }
}
