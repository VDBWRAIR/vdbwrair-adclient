class adclient::smartcard (
    $use_smartcard,
    $cn_map,
    $gui_packages,
    $nssdb_path,
    $cert_url,
    $adcert_source,
) {
    validate_hash($cn_map)
    validate_bool($use_smartcard)
    validate_array($gui_packages)
    validate_absolute_path($nssdb_path)
    validate_string($cert_url)
    validate_string($adcert_source)
    
    class {'adclient::smartcard::install': } ->
    class {'adclient::smartcard::config': } ->
    class {'adclient::smartcard::service': }
}
