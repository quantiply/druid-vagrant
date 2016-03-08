Vagrant.configure(2) do |config|
  config.vm.define :druid do |druid|
    druid.vm.network :private_network, ip: "192.168.50.4"
    druid.vm.box = "ubuntu/trusty64"
    druid.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", "4048"]
        v.customize ["modifyvm", :id, "--cpus", "2"] # druid overlord requires multi-core machine
        v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    druid.vm.synced_folder ".", "/vagrant"
    druid.vm.provision "shell" do |s|
      s.path = "install.sh"
      s.privileged = true
    end
  end
end
