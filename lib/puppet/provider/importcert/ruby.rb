Puppet::Type.type(:importcert).provide(:ruby) do
    def create
        import_pem(resource[:cert], resource[:nssdb])
    end

    def destroy
        remove_pem(resource[:cert], resource[:nssdb])
    end

    def exists?
        tf = pem_imported?(resource[:cert], resource[:nssdb])
    end

    private
    # Split a pem file that has many entries
    def split_cert(pemfile)
        certdir = resource[:certdir]
        certlist = []
        Dir.mkdir(certdir) unless Dir.exist?(certdir)
        File.open(pemfile) do |fh|
            contents = fh.read.strip
            certs = contents.split(/^$/)
            certs.each do |cert|
                cl = cert.strip.lines.to_a
                subject = cl[0].strip.split('/')[-1].split('=')[1].gsub(' ', '_')
                cert = cl[2..-1].join('')
                certfile = File.join(certdir, subject + '.pem')
                unless File.exist?(certfile)
                    File.open(certfile, 'w') do |fw|
                        fw.write(cert)
                    end
                end
                certlist.push(certfile)
            end
        end
        certlist
    end

    def certlist(pempath, nssdb, notimported=false)
        allcerts = split_cert(resource[:cert])
        # Only keep certs that are not imported
        allcerts.keep_if{ |certpath|
            subject = File.basename(certpath,'.pem')
            cert_imported?(subject, nssdb) ^ notimported
        }
    end

    # Returns a list of all certs that have
    # been imported into database
    def imported_certs(pempath, nssdb)
        certlist(pempath, nssdb)
    end

    # Returns a list of certs that have not been
    # imported into the database
    def not_imported_certs(pempath, nssdb)
        certlist(pempath, nssdb, true)
    end

    # Check each certificate to ensure ensure
    # that it is in the nssdb
    def pem_imported?(pempath, nssdb)
        not_imported_certs(pempath, nssdb).length == 0
    end

    def cert_imported?(subject, nssdb)
        out = `/usr/bin/certutil -d #{nssdb} -L -n #{subject} 2>&1`
        ret = $?
        ret == 0
    end

    def import_pem(pempath, nssdb)
        to_import = not_imported_certs(pempath, nssdb)
        debug("To Import: %s" % to_import.to_s)
        to_import.each do |cert|
            if !import_cert(cert, nssdb)
                raise Puppet::Error, "Failed to import %s" % cert
            end
        end
    end

    # Import a single cert file into nssdb
    def import_cert(pemfile, nssdb)
        subject = File.basename(pemfile, '.pem')
        # Output seems to be empty if it succeeds
        `/usr/bin/certutil -A -n #{subject} -t CT,C,C -i #{pemfile} -d #{nssdb}`
        ret = $?
        ret == 0
    end

    def remove_pem(pempath, nssdb)
        to_remove = imported_certs(pempath, nssdb)
        debug("To Remove: %s" % to_remove.to_s)
        to_remove.each do |cert|
            if !remove_cert(cert, nssdb)
                raise Puppet::Error, "Failed to remove %s" % cert
            end
        end
    end

    # Remove a single cert from db
    def remove_cert(pemfile, nssdb)
        subject = File.basename(pemfile, '.pem')
        out = `/usr/bin/certutil -D -n #{subject} -t CT,C,C -i #{pemfile} -d #{nssdb}`
        ret = $?
        ret == 0
    end
end
