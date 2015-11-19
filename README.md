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
6. [Development - Guide for contributing to the module](#development)

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
* Creates /etc/pki/CA/certs if use_smartcard
* Manages /etc/pki/nssdb if use_smartcard
* Manages /etc/pam_pkcs11/\* if use_smartcard

### Setup Requirements **OPTIONAL**

You have to get and convert your domains certificate chain to pem format and
put that into a file named adcerts under files in this module

### Beginning with adclient

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
>>>>>>> initial
