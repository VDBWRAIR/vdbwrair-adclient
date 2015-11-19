import sys
try:
    import ldap
except ImportError:
    sys.stderr.write("You need to install python-ldap\n")
    sys.exit(-1)
import subprocess
import re
import base64
import shutil
from os.path import *
import os
import getpass

'''
Should import all certificates from AD
'''

def get_dn( account ):
  p = subprocess.Popen( "net ads search -P '(sAMAccountName=%s)'" % account, stdout=subprocess.PIPE, shell=True )
  sout,sin = p.communicate()
  try:
    dn = re.search( '^distinguishedName: (.*?)$', sout.rstrip(), re.M|re.S ).group(1)
    return dn
  except AttributeError as e:
    raise Exception( "Error retrieving DN for %s" % account )

def get_certificates( server, dn, certdn ):
  print 'Fetching certificates from %s' % server
  l = ldap.initialize( 'ldap://%s' % server )
  l.set_option(ldap.OPT_REFERRALS,0)
  print l.simple_bind_s( '%s' % dn, getpass.getpass() ) 
  return l.search_s( certdn, ldap.SCOPE_SUBTREE, filterstr='(cacertificate=*)', attrlist=['cn','cACertificate'] )

def der_to_pem( derstr ):
  p = subprocess.Popen( 'openssl x509 -inform der -outform pem', stdout=subprocess.PIPE, stdin=subprocess.PIPE, shell=True )
  sout, sin = p.communicate( input=derstr )
  return sout.rstrip()

def make_cert_dir( domainuser, domainhost, certdn, certdir='/etc/pki/CA/certs' ):
  dn = get_dn( domainuser )
  certs = get_certificates( domainhost, dn, certdn )
  if not exists(certdir):
    os.mkdir( certdir )
  else:
    shutil.rmtree( certdir )
    os.mkdir( certdir )
  
  certlist = []
  adcert = join(certdir, 'adcerts.pem' )
  with open( adcert, 'w' ) as fh:
    for dn, att in certs:
      if not isinstance(att,dict):
        continue
      name = att['cn'][0].replace(' ','_')
      cert = att['cACertificate'][0]
      if cert.rstrip() == '':
        continue
      pem = der_to_pem(cert) + '\n'
      # Write individual certificates
      certpath = join(certdir,name+'.pem')
      with open( certpath, 'w' ) as cfh:
        cfh.write( pem ) 
      print 'Wrote %s' % certpath
      # Write combined certificate file
      fh.write(pem)
      certlist.append( certpath )
  print 'Wrote %s' % adcert
  return certlist

def remove_certs( certdir='/etc/pki/nssdb' ):
  print 'Clearing all certificates from %s' % certdir
  certs = list_certs()
  for c in certs:
    subprocess.call( 'certutil -d %s -D -n %s' % (certdir,c), shell=True )

def list_certs( certdir='/etc/pki/nssdb'):
  p = subprocess.Popen( 'certutil -d %s -L' % certdir, shell=True, stdout=subprocess.PIPE )
  sout,sin = p.communicate()
  names = [s.split()[0] for s in sout.strip().splitlines() if s.startswith('cert')]
  return names

def import_all_certs( certlist, certdir='/etc/pki/nssdb' ):
  for c in certlist:
    import_cert( c, certdir )

def import_cert( certfile, certdir='/etc/pki/nssdb' ):
  print 'Importing %s into %s' % (certfile,certdir)
  name = splitext( certfile )[0]
  return subprocess.call( 'certutil -A -n %s -t CT,C,C -i %s -d %s' % (name,certfile,certdir), shell=True )

'''
if __name__ == '__main__':
  if len(sys.argv) != 3:
    print "Usage: %s domainadmin domainhostname"
    sys.exit(1)
  # Clear Certlist
  remove_certs()
  # Retrieve AD Certs and import them
  
  certlist = make_cert_dir( sys.argv[1], sys.argv[2], certdn, certdir='/etc/pki/CA/certs' )
  import_all_certs( certlist )
'''
