class adclient::smartcard (
    $use_smartcard,
    $cn_map,
    $gui_packages,
) {
    validate_hash($cn_map)
    validate_bool($use_smartcard)
    validate_array($gui_packages)
    
    class {'adclient::smartcard::install': } ->
    class {'adclient::smartcard::config': } ->
    class {'adclient::smartcard::service': }
}
