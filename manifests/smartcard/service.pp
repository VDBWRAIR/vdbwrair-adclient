class adclient::smartcard::service inherits adclient::smartcard {
    service { "pcscd":
        ensure  => running,
        enable  => true,
    }
}
