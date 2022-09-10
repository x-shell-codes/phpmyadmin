Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/jammy64"

	# Port forwarding
	config.vm.network 'forwarded_port', guest: 80, host: 80


	config.vm.provider "virtualbox" do |vb|
		vb.name = "phpmyadmin.local.x-shell.codes"
		vb.cpus = 1
		vb.memory = 4096
	end
end
