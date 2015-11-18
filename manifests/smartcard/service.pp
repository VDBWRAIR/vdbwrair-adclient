class adclient::smartcard::service inherits adclient::smartcard {
    service { "pcscd":
        ensure  => running,
        enable  => true,
    }

    # This doesn't really work as gdm seems to crash
    # There is no safe way to get the smartcard thing to pop-up
    # without restarting since gdm has no restart
    service { "gdm":
        binary      => '/usr/sbin/gdm-binary',
        pattern     => 'gdm-binary',
        restart     => '/usr/bin/pkill gdm-binary',
        start       => '/usr/sbin/gdm-binary',
        provider    => 'base',
        #binary      => '/usr/libexec/gdm-simple-greeter',
        #pattern     => 'gdm-simple-greeter',
        #restart     => '/usr/bin/pkill -f gdm-simple-greeter',
        #start       => '/usr/libexec/gdm-simple-greeter'
    }
}
