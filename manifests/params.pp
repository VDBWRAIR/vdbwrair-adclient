class adclient::params {
    # Where to place computers in AD(What OU)
    $computerou                      = 'Computers'
    # List of active directory servers
    $smb_adservers                   = []
    # Workgroup name
    $smb_workgroup                   = 'workgroup'
    # Realm(fqdn) AD name
    $smb_realm                       = 'example.com'

    $smb_encrypt_passwords           = 'yes'
    $smb_log_level                   = 1
    $smb_syslog                      = 1
    $smb_security                    = 'ads'
    $smb_enum_users                  = 'yes'
    $smb_enum_groups                 = 'yes'
    $smb_use_default_domain          = 'yes'
    $smb_offline_logon               = 'no'
    $smb_separator                   = '+'
    $smb_template_homedir            = '/home/%D/%U'
    $smb_template_shell              = '/bin/bash'
    $smb_idmap_backend               = 'rid'
    $smb_idmap_range_start           = 10000000
    $smb_idmap_range_end             = 19999999
    $smb_kerberos_method             = 'system keytab'
    $smb_dedicated_keytab_file       = '/etc/krb5.keytab'
    $smb_idmap_uid_start             = 10000
    $smb_idmap_uid_end               = 19999
    $smb_idmap_gid_start             = 10000
    $smb_idmap_gid_end               = 19999
    $use_smartcard                   = false
    $smb_client_signing              = 'mandatory'
    $smb_guest_ok                    = 'no'

    # Do not require gui
    $non_gui_packages                = [
        'ccid',
        'coolkey',
        'esc',
        'pam',
        'pam_pkcs11',
        'opencryptoki',
        'krb5-pkinit-openssl',
        'pam_krb5',
        'python-ldap',
        'ipa-client',
        'oddjob-mkhomedir',
        'sssd',
        'ypbind',
        'certmonger',
        'hesinfo',
        'krb5-appl-clients',
        'krb5-workstation',
        'ldapjdk',
        'libsss_sudo',
        'nscd',
        'nss-pam-ldapd',
        'openldap-clients',
        'pam_ldap',
        'cifs-utils',
        'pam_pkcs11',
        'samba-winbind',
        'samba-common'
    ]
    # Require GUI
    $gui_packages = [
        'gdm-plugin-smartcard',
        'gdm',
        'plymouth-gdm-hooks',
        'gdm-libs',
        'authdialog'
    ]
}
