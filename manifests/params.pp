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
        #'plymouth-gdm-hooks',
        #'gdm-libs',
    ]

    # Smartcard settings
    $use_smartcard                   = false
    # Should be 'CN' => 'samaccountname'
    $cn_map                          = { }
    # Path to nssdb
    $nssdb_path                      = '/etc/pki/nssdb'
    # URL to zip file of certs
    $cert_url                        = 'http://iasecontent.disa.mil/pki-pke/Certificates_PKCS7_v4.1_DoD.zip'
    # This has to be able to match your principal name on your cert that
    # matches in Active Directory
    $pkinit_cert_match               = '<SAN>^[0-9]{10}@mil$'
    # This is the path to the adcert.pem file that contains all cert chains
    # leading from smartcard to AD
    $adcert_source                     = 'puppet:///modules/adclient/adcerts.pem',
}
