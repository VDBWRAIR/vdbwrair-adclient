class adclient::smartcard::config inherits adclient::smartcard {
    file { "/etc/sysconfig/authconfig":
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('adclient/authconfig.erb'),
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

    # PKI Directory to do our work in
    $pki_dir = '/etc/pki/CA/certs'
    # Only the path of the zip file from the url(last thing after last /)
    $cert_zip = split($adclient::smartcard::cert_url, '/')[-1]
    #notify{"Certificates Zip file: ${cert_zip}":}
    # The dir that gets unpacked is same as zip file but without .zip
    $unpack_dir = regsubst($cert_zip, "^(.*)\.zip$", "\1");
    #notify{"Unpacked certs directory: ${unpack_dir}":}

    file { $adclient::smartcard::nssdb_path:
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 'u+rwX,go+rX',
        recurse => true
    }

    file { $pki_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
    }

    Exec {
        cwd     => $pki_dir,
        path    => '/bin:/usr/bin',
    }

    # Download zip
    exec { "wget ${adclient::smartcard::cert_url}":
        alias   => 'download_cert',
        creates => "${pki_dir}/${cert_zip}",
        require => File[$pki_dir]
    }

    # Unpack zip
    exec { "unzip ${cert_zip}":
        alias   => 'unpack_cert',
        creates => "${pki_dir}/${unpack_dir}",
        require => Exec['download_cert']
    }

    # Convert to pem file
    exec { "openssl pkcs7 -in ${unpack_dir}/${unpack_dir}.pem.p7b -print_certs -out certs.pem":
        alias   => "convert_cert",
        creates => "${pki_dir}/certs.pem",
        require => Exec['unpack_cert']
    }

    file { "${pki_dir}/certs.pem":
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Exec['convert_cert']
    }

    # Import into nssdb
    importcert {"${pki_dir}/certs.pem":
        ensure  => present,
        require => Exec['convert_cert'],
        alias   => 'importcert'
    }

    # Pull AD cert chain
    # User has to manually get these
    file {"${pki_dir}/adcerts.pem":
        owner   => root,
        group   => root,
        mode    => '0644',
        ensure  => present,
        source  => $adclient::smartcard::adcert_source,
        require => Importcert['importcert']
    }

    file {"/etc/pam.d/gdm-smartcard":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template("${module_name}/gdm-smartcard.erb")
    }
    file {"/etc/pam.d/smartcard-auth":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template("${module_name}/smartcard-auth.erb")
    }
}
