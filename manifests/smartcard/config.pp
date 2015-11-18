class adclient::smartcard::config inherits adclient::smartcard {
    file { "/etc/sysconfig/authconfig":
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('adclient/authconfig.erb'),
        notify  => Service['gdm']
    }

    file { "/etc/pam_pkcs11/pam_pkcs11.conf":
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('adclient/pam_pkcs11.conf.erb')
    }

    file { "/etc/pam_pkcs11/pkcs11_eventmgr.conf":
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('adclient/pkcs11_eventmgr.conf.erb')
    }

    file { "/etc/pam_pkcs11/cn_map":
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('adclient/cn_map.erb')
    }

    if $adclient::smartcard::use_smartcard {
        exec { "enable_init_5":
            command => '/bin/sed -i "s/id:3/id:5/" /etc/inittab && /sbin/init 5',
            unless  => '/bin/grep -q "id:5" /etc/inittab'
        }
    }
}
