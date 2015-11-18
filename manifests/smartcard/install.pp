class adclient::smartcard::install inherits adclient::smartcard {
    if $use_smartcard {
        ensure_packages($adclient::smartcard::gui_packages)
    } else {
        ensure_packages($adclient::smartcard::gui_packages, {'ensure' => 'absent'})
    }
}
