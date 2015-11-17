=begin
LDAP server: xxx.xxx.xxx.xxx
LDAP server name: adserver.example.com
Realm: EXAMPLE.COM
Bind Path: dc=EXAMPLE,dc=COM
LDAP port: 389
Server time: Fri, 06 Nov 2015 13:38:21 EST
KDC server: xxx.xxx.xxx.xxx
Server time offset: 0
=end
Facter.add('ad_info') do
    setcode do
        ad_info_str = Facter::Core::Execution.exec('/usr/bin/net ads info')
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
