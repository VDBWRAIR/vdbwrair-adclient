=begin
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
objectClass: computer
cn: COMPUTERNAME
distinguishedName: CN=COMPUTERNAME,OU=Computers,DC=example,DC=com
instanceType: 4
whenCreated: 20150513165943.0Z
whenChanged: 20151103220101.0Z
uSNCreated: 55362365
uSNChanged: 84082183
name: COMPUTERNAME
objectGUID: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
userAccountControl: 69632
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
lastLogon: 130913115565062048
localPolicyFlags: 0
pwdLastSet: 130760099839863155
primaryGroupID: 515
objectSid: S-1-1-11-111111111-111111111-111111111-1111111
accountExpires: 9223372036854775807
logonCount: 1270
sAMAccountName: COMPUTERNAME$
sAMAccountType: 805306369
operatingSystem: Red Hat Server
operatingSystemVersion: 6.x
operatingSystemServicePack: Samba 3.6.9-164.el6
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
=end
Facter.add('ad_computer') do
    setcode do
        ad_info_str = Facter::Core::Execution.exec('/usr/bin/net ads status -P')
        ad_info = {}
        if !ad_info_str.empty?
            ad_info_str.each_line { |line|
                l,p,r = line.chomp.partition(':')
                ad_info[l.strip] = r.strip
            }
        end
        ad_info
    end
end
