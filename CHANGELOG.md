## change log for winbind
0.6.0
	bc - move the sssd/winbind decision out

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
