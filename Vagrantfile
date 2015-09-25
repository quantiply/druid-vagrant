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
      s.path = "overlord/install.sh"
      s.privileged = true
    end
  end

  config.vm.define :middlemanager do |middlemanager|
    middlemanager.vm.network :private_network, ip: "192.168.50.5"
    middlemanager.vm.box = "ubuntu/trusty64"
    middlemanager.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", "4048"]
        v.customize ["modifyvm", :id, "--cpus", "1"] # druid overlord requires multi-core machine
        v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    middlemanager.vm.synced_folder ".", "/vagrant"
    middlemanager.vm.provision "shell" do |s|
      s.path = "middlemanager/install.sh"
      s.privileged = true
    end
  end
end
