## change log for winbind
0.6.0
	bc - move the sssd/winbind decision out

0.5.2
	bc - DISABLE krb5 in security/pam_winbind.conf for now for RHEL6

0.5.1
	New SMB.conf format:
	https://access.redhat.com/sites/default/files/attachments/rhel-ad-integration-deployment-guidelines-v1.5.pdf
	 - idmap_rid
	 - evade number collision/nonuniformity
	 - ensure winbindd_idmap.tdb nuked if the smb.conf changes

	 - check that domain and search is set right in resolv.conf
	 - recommends HOSTNAME = fqdn

0.5.0
	bc - change restart disco for RHEL7/dbus
	bc - sensitive all ops
	bc - ensure smb.conf interfaces set for primary interface

0.4.0
	bc - ensure chrony is removed after adding ntpd support.
	bc - don't write * into krb.conf

0.3.0
	bc - ensure authconfig is installed where required.

0.2.0
	add in 3p ntp instead of local wheel reinvention
