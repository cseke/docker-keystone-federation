import mechanicalsoup as mc

brow = mc.StatefulBrowser()
brow.open('http://keystone:5000/v3/OS-FEDERATION/identity_providers/shibboleth/protocols/saml2/auth', verify=False)
brow.select_form()
brow['j_username'] = 'kb'
brow['j_password'] = 'r00tme'
brow.submit_selected()
brow.select_form()
resp = brow.submit_selected()
print "TOKEN: {}".format(resp.headers['X-Subject-Token'])
