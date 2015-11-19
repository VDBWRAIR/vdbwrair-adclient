Puppet::Type.newtype(:importcert) do
    @doc = "manages importing a pem file that is actually multiple certs.

        Example:
        importcert{ '/root/certs/DoD_CAs.pem':
                ensure => absent,
                nssdb  => '/etc/pki/nssdb',
                #cert   => '/root/certs/DoD_CAs.pem',
                certdir => '/tmp/cert1'
        }
    "

    ensurable

    newparam(:nssdb) do
        desc 'Path to nssdb'
        defaultto '/etc/pki/nssdb'
        validate do |value|
            unless Dir.exist?(value)
                raise(Puppet::Error, "'#{value}' is not an existing path")
            end
        end
    end

    newparam(:cert, :namevar => true) do
        desc "Cert to import into nssdb"
        validate do |value|
            unless value =~ /.*\.pem/
                raise ArgumentError, "%s is not a pem file"
            end
        end
    end

    newparam(:certdir) do
        desc "Where split pem files will be put prior to import"
        defaultto '/etc/pki/CA/certs'
    end
end
