class adclient::config inherits adclient {
    # Script to join machine to domain
    file { "/root/joindomain.sh":
        owner   => root,
        group   => root,
        mode    => '0700',
        content => template('adclient/joindomain.sh.erb')
    }

    # Configure machine to ensure time set at startup
    file_line { "machine_ad_time":
        path    => "/etc/rc.local",
        line    => "net time set -S ${smb_adservers[0]}",
        match   => "net time set -S"
    }

    # Only if ad_info and ad_computer set(meaning joined to domain)
    if !empty($::ad_info) and !empty($::ad_computer) {
        $line_ensure = 'present'
        $nss_line = 'files winbind'

        # Configure machine to ensure kerberos machine ticket at startup
        file_line { "machine_kerberos_ticket":
            ensure => $line_ensure,
            path   => "/etc/rc.local",
            line   => "net ads kerberos kinit -P",
            match_for_absence => true
        }

        # Schedule cron to renew machine kerb ticket
        cron { 'machine_kerberos_ticket_renew':
            ensure      => present,
            command     => '/usr/bin/net ads kerberos kinit -P',
            hour        => '*/2',
            minute      => absent,
            month       => absent,
            monthday    => absent,
            weekday     => absent
        }
        
        # Init kerberos ticket now if it isn't already
        exec { '/usr/bin/net ads kerberos kinit -P':
            unless => '/usr/bin/klist'
        }
    } else {
        $line_ensure = 'absent'
        $nss_line = 'files'
    }

    file_line { 'nsswitch_passwd':
        path   => '/etc/nsswitch.conf',
        line   => "passwd: ${nss_line}",
        match  => '^passwd:',
    }

    file_line { 'nsswitch_shadow':
        ensure => $line_ensure,
        path   => '/etc/nsswitch.conf',
        line   => "shadow: ${nss_line}",
        match  => '^shadow:',
    }

    file_line { 'nsswitch_group':
        ensure => $line_ensure,
        path   => '/etc/nsswitch.conf',
        line   => "group: ${nss_line}",
        match  => '^group:',
    }

    # Configuration for winbind
    file { "/etc/samba/smb.conf":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('adclient/smb.conf.erb'),
        notify  => Service['winbind']
    }

    # Create smb_template_homedir up to the last component 
    $workgroup = split($::domain, '\.')[0].upcase
    $homedir_path = regsubst(
                regsubst($smb_template_homedir, '%D', $workgroup),
                '%U', ''
    )
    exec {"create_$homedir_path":
        command     => "/bin/mkdir -p ${homedir_path}",
        unless      => "/usr/bin/test -d ${homedir_path}",
        umask       => "0066",
    }

    if $::provision_homedir {
        file {"/usr/local/bin/restoreconhome.sh":
            ensure      => present,
            owner       => root,
            group       => root,
            mode        => '0755',
            content     => template('adclient/restoreconhome.sh.erb')
        }
    }

    # Configuration for kerberos
    file { "/etc/krb5.conf":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('adclient/krb5.conf.erb'),
    }

    file { '/etc/pam.d/system-auth-local':
        owner => root,
        group => root,
        mode => '0644',
        content => template("${module_name}/system-auth-local")
    }

    file { '/etc/pam.d/system-auth':
        ensure => link,
        target => '/etc/pam.d/system-auth-local'
    }

    file { '/etc/pam.d/password-auth-local':
        owner => root,
        group => root,
        mode => '0644',
        content => template("${module_name}/password-auth-local")
    }

    file { '/etc/pam.d/password-auth':
        ensure => link,
        target => '/etc/pam.d/password-auth-local'
    }
    
    file { "/etc/init.d/winbind":
        owner   => root,
        group   => root,
        mode    => '0755',
        content => template("${module_name}/winbind.erb"),
        notify  => Service['winbind']
    }
}
