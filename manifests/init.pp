# Class: adclient
# ===========================
#
# Full description of class adclient here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# * `ad_info`
#   This is a custom fact that contains the output from net ads info
#   split by lines. Each key is the part before the : and the value is what comes
#   after the colon. See lib/facts/ad_info.rb for more details
#   If this is not set, the computer is not joined to ad
#
# * `ad_computer`
#   Same concept as ad_info, but output from net ads status -P
#   
# Examples
# --------
#
# @example
#    class { 'adclient':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Tyghe Vallard <vallardt@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2015 Cherokee Nation Business, LLC
#
class adclient(
    $non_gui_packages          = $adclient::params::non_gui_packages,
    $gui_packages              = $adclient::params::gui_packages,
    $computerou                = $adclient::params::computerou,
    $smb_workgroup             = $adclient::params::smb_workgroup,
    $smb_realm                 = $adclient::params::smb_realm,
    $smb_encrypt_passwords     = $adclient::params::smb_encrypt_passwords,
    $smb_log_level             = $adclient::params::smb_log_level,
    $smb_syslog                = $adclient::params::smb_syslog,
    $smb_security              = $adclient::params::smb_security,
    $smb_enum_users            = $adclient::params::smb_enum_users,
    $smb_enum_groups           = $adclient::params::smb_enum_groups,
    $smb_use_default_domain    = $adclient::params::smb_use_default_domain,
    $smb_offline_logon         = $adclient::params::smb_offline_logon,
    $smb_separator             = $adclient::params::smb_separator,
    $smb_template_homedir      = $adclient::params::smb_template_homedir,
    $smb_template_shell        = $adclient::params::smb_template_shell,
    $smb_idmap_backend         = $adclient::params::smb_idmap_backend,
    $smb_idmap_range_start     = $adclient::params::smb_idmap_range_start,
    $smb_idmap_range_end       = $adclient::params::smb_idmap_range_end,
    $smb_adservers             = $adclient::params::smb_adservers,
    $smb_kerberos_method       = $adclient::params::smb_kerberos_method,
    $smb_dedicated_keytab_file = $adclient::params::smb_dedicated_keytab_file,
    $smb_idmap_uid_start       = $adclient::params::smb_idmap_uid_start,
    $smb_idmap_uid_end         = $adclient::params::smb_idmap_uid_end,
    $smb_idmap_gid_start       = $adclient::params::smb_idmap_gid_start,
    $smb_idmap_gid_end         = $adclient::params::smb_idmap_gid_end,
    $smb_client_signing        = $adclient::params::smb_client_signing,
    $smb_guest_ok              = $adclient::params::smb_guest_ok,
    $use_smartcard             = $adclient::params::use_smartcard,
    $cn_map                    = $adclient::params::cn_map,
    $nssdb_path                = $adclient::params::nssdb_path,
    $cert_url                  = $adclient::params::cert_url,
    $adcert_source               = $adclient::params::adcert_source
) inherits adclient::params {
    include stdlib

    validate_string($computerou)
    validate_array($non_gui_packages)
    validate_array($gui_packages)
    validate_string($smb_workgroup)
    validate_string($smb_realm)
    validate_re($smb_encrypt_passwords, 'yes|no')
    validate_integer($smb_log_level, 10)
    validate_integer($smb_syslog)
    validate_re($smb_security, '^ads$')
    validate_re($smb_enum_users, 'yes|no')
    validate_re($smb_enum_groups, 'yes|no')
    validate_re($smb_use_default_domain, 'yes|no')
    validate_re($smb_offline_logon, 'yes|no')
    validate_re($smb_separator, '^\S$')
    validate_string($smb_template_homedir)
    validate_string($smb_template_shell)
    validate_re($smb_idmap_backend, '^rid$')
    validate_integer($smb_idmap_range_start)
    validate_integer($smb_idmap_range_end)
    validate_array($smb_adservers)
    validate_re($smb_kerberos_method, '^system keytab$')
    validate_string($smb_dedicated_keytab_file)
    validate_integer($smb_idmap_uid_start)
    validate_integer($smb_idmap_uid_end)
    validate_integer($smb_idmap_gid_start)
    validate_integer($smb_idmap_gid_end)
    validate_re($smb_client_signing, 'auto|mandatory|disabled')
    validate_re($smb_guest_ok, 'yes|no')

    anchor { 'module::begin': } ->
        class{ 'adclient::install': } ->
        class{ 'adclient::config': } ->
        class{ 'adclient::service': } ->
        class{ 'adclient::smartcard':
            use_smartcard => $use_smartcard,
            gui_packages  => $gui_packages,
            cn_map        => $cn_map,
            nssdb_path    => $nssdb_path,
            cert_url      => $cert_url,
            adcert_source   => $adcert_source,
        } ->
    anchor { 'module::end': }
}
