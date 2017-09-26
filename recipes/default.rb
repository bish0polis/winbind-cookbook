#
# Cookbook:: winbind
# Recipe:: default
#
# Copyright:: 2017, City of Burnaby, BSD2

# cheat around the lack of crypto dbags
include_recipe 'all-datacenter-attributes::realm'	# AD centralized settings

package %w(PackageKit)
package %w(samba samba-client samba-common samba-winbind samba-winbind-clients oddjob-mkhomedir dbus pam_krb5)
package %w(krb5-workstation)
package %w(adcli)

case node[:realm][:auth]||''
when 'sssd'
  include_recipe 'sssd'
else
  package %w(ntp)
  template '/etc/ntp.conf'
  service 'ntpd' do
    supports :restart => true, :reload => true
    action [ :enable, :start ]
  end

  execute "authconfig  --enablewinbindoffline --disablecache --enablewinbind  --enablewinbindauth --smbsecurity=ads --smbworkgroup=TEST --smbrealm=#{node[:realm][:directory_name].upcase} --smbservers=#{node[:realm][:servers].join(',')} --enablewinbindusedefaultdomain --winbindtemplatehomedir=/home/%U  --winbindtemplateshell=/bin/bash --krb5realm=#{node[:realm][:directory_name].upcase} --disablekrb5kdcdns --disablekrb5realmdns --enablelocauthorize  --enablemkhomedir --enablepamaccess  --updateall > /etc/.authconfig" do
    creates '/etc/.authconfig'
  end

# yes, still need to patch up the krb5.conf to add in the KDC addresses  grr....

  %w(messagebus oddjobd).each do |svc|
    service svc do 
      action [ :enable, :start ]
    end
  end
  
  %w(winbind).each do |svc|
    service svc do
      action :nothing
    end
  end

  template '/etc/samba/smb.conf'
  template '/etc/security/pam_winbind.conf'
  template '/etc/krb5.conf'
  
  execute 'join ad in winbind' do
    command "net ads join -U #{node.run_state['realm_username']}%#{node.run_state['realm_password']} " +
      "-S #{node[:realm][:servers][0]}"
    sensitive	true
    notifies :restart, 'service[winbind]', :immediately
    not_if " [ -f '/etc/krb5.keytab' ] && id #{node[:fqdn].split('.')[0]}$"
  end

  Chef::Log.warn "This can sometimes fail due to AD caching and refresh inadequacies.  Run it again."
  (node[:realm][:secgroups]||[]).each do |grp|
    execute "add #{node[:fqdn]} to group #{grp}@#{node[:realm][:realm_name]}" do
      sensitive	true
      command "adcli add-member -D #{node[:realm][:realm_name]} -U #{node.run_state['realm_secname']} #{grp} #{node[:fqdn].split('.')[0]}$ <<< '#{node.run_state['realm_secpass']}'"
      only_if "id #{node[:fqdn].split('.')[0]}$|grep -vqi '(#{grp})'"
    end   	# execute
  end		# each

  (node[:realm][:srvtix]||[]).map(&:upcase).each do |srv|
    execute "get service ticket #{srv}/#{node[:fqdn]}@#{node[:realm][:realm_name].upcase}" do
      command "net ads keytab add #{srv} -U #{node.run_state['realm_username']}%#{node.run_state['realm_password']}; klist -k"
      not_if "klist -k | grep -qi '#{srv}/#{node[:fqdn]}@#{node[:realm][:realm_name].upcase}'"
    end
  end
end

