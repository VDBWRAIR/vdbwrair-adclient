# vdbwrair-adclient
Puppet adclient configuration

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with adclient](#setup)
    * [What adclient affects](#what-adclient-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with adclient](#beginning-with-adclient)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [License](#licese)

## Overview

Configures Active Directory authentication as well as smartcard authentication

## Module Description

This module integrates a Linux machine into an Active Directory environment.
It is only tested with the ARMY setup at this time so probably needs a more general
workover at some point.

You can also enable smartcard authentication by setting use_smartcard => true which
will then setup the kerberos file to utilize pkinit.

Using smartcard authentication requires that you retrieve the certificate chain
for your domain and place it into files/adcerts.pem. It has to be a pem formatted
file. You can get this file via any Windows workstation that is already configured
through the certificate store(you will need to convert those certs to pem format)

## Setup

### What adclient affects

* Manages /etc/krb5.conf
* Manages /etc/samba/smb.conf
* Manages /etc/pam.d/system-auth{,-ac}
* Manages /etc/pam.d/password-auth{,-ac}
* Manages /etc/pam.d/smartcard-auth
* Manages /etc/pam.d/gdm-smartcard
* Creates /etc/pki/CA/certs if use_smartcard
* Manages /etc/pki/nssdb if use_smartcard
* Manages /etc/pam_pkcs11/\* if use_smartcard

### Setup Requirements

You have to get and convert your domains certificate chain to pem format and
put that into a file named adcerts under files in this module

At this time, ntp is not included as a requirement, but it is required in order
for kerberos to work properly

### Beginning with adclient

Export all intermediate certs that are needed for your AD Environment and convert
them to .pem format.
Save this file as adcerts.pem in the files directory of this module.

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

### Simple adclient configuration

```puppet
class profile::adclient inherits profile {
    include adclient
    include ntp
}
```

### If you also do smartcard auth through gdm

```puppet
class profile::adclient::gui inherits profile {
    class {'adclient':
        use_smartcard => true
    }
    include ntp
}
```

## Reference

Classes:

    * adclient
    * adclient::smartcard

Types:

    * importcert

Facts:

    * ad_info
    * ad_computer


### Class: adclient

Performs the base configuration to enable joining to Active Directory.

Params:

Check out params.pp for details of each parameter

Configures the following files:

* /etc/krb5.conf
* /etc/samba/smb.conf

Manages the following files:

While not ideal, the files are managed statically

* /etc/pam.d/system-auth
* /etc/pam.d/password-auth
* /etc/pam.d/smartcard-auth
* /etc/pam.d/gdm-smartcard

Manages the following services:

* winbind

Installs the following packages:

`adclient::param::non_gui_packages`

### Class: adclient::smartcard

This class adds smartcard support to GDM
At this time this is a bit clunky as it looks to download a zip file
that contains a pkcs7 file of certificates as this is tailored to the DoD
environment. Likely will move to just having user add pem file to files
directory in module in the future.

This class should not be instantiated directly, but instead use_smartcard
should be passed to adclient with the value of true.

Params:

* use_smartcard
  `true|false` to enable smartcard or disable it
* cn_map
  Hash of cn_map mappings for the pam_pkcs11 module.
  Example:
    LAST.FIRST.I.EPID -> first.last
  This will vary based on your environment
* gui_packages
  List of packages that are required for smartcard to work with GDM
* nssdb_path
  This value is set in `/etc/pam_pkcs11/pam_pkcs11.conf`

    Default: `/etc/pki/nssdb`. 
  
* cert_url
  This is the url to the pkcs11 zip file that will be downloaded, unpacked,
  converted to pem(`/etc/pki/CA/certs/certs.pem`) and then split and imported
  into `nssdb_path`

    Default: 'http://iasecontent.disa.mil/pki-pke/Certificates_PKCS7_v4.1_DoD.zip'

Configures the following files:

* /etc/pam_pkcs11/cn_map
* /etc/pam_pkcs11/pam_pkcs11.conf
* /etc/pam_pkcs11/pkcs11_eventmgr.conf
* /etc/sysconfig/authconfig

Manages the following files:

* /etc/pki/CA/certs/adcerts.pem
  **NOTE** You have to put this file in files directory as it cannot be
  automatically generated.

### Type: importcert

This type is a workaround that allows you to easily import a pem file into
a certutil database. It works by splitting up the pem file on blank lines
and importing each certificate using the Subject CN as the name.

* cert
  Path to the pem file to split and import
* nssdb
  Path to the nssdb to import into
* certdir
  Path to store split up cert files

### Fact: ad_info

Sets up a hash of information returned from the command
`net ads info`

Example output from command:

```
LDAP server: xxx.xxx.xxx.xxx
LDAP server name: adserver.example.com
Realm: EXAMPLE.COM
Bind Path: dc=EXAMPLE,dc=COM
LDAP port: 389
Server time: Fri, 06 Nov 2015 13:38:21 EST
KDC server: xxx.xxx.xxx.xxx
Server time offset: 0
```

The hash's keys are simple what is on the left of the `:` and the values are
what comes on the right of the `:`

### Fact: ad_computer

Sets up a hash of information returned from the command
`net ads status`

Example output from command:

```
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
objectClass: computer
cn: COMPUTERNAME
distinguishedName: CN=COMPUTERNAME,OU=Computers,DC=example,DC=com
...
dNSHostName: computername.example.com
servicePrincipalName: HOST/computername.example.com
servicePrincipalName: HOST/COMPUTERNAME
objectCategory: CN=Computer,CN=Schema,CN=Configuration,DC=example,DC=com
isCriticalSystemObject: FALSE
dSCorePropagationData: 20150903132955.0Z
dSCorePropagationData: 20150709195313.0Z
dSCorePropagationData: 20150709152536.0Z
dSCorePropagationData: 16010101181633.0Z
lastLogonTimestamp: 130910616618057213
```

The hash's keys are simple what is on the left of the `:` and the values are
what comes on the right of the `:`

## Limitations

This module is quite specific to RHEL/CENTOS
It is also mostly specific to the DoD community, specifically the AMED branch
of the US Army.
It would be great to make it more general, but the process is so complicated as
it is, that making it general is out of scope at this time.

# License

Copyright (C) 2015 Cherokee Nation Technology Solutions, LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
