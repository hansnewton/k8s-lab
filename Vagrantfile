# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variaveis
VAGRANTFILE_API_VERSION=2
VAGRANT_DISABLE_VBOXSYMLINKCREATE=1


# Chamando modulo YAML
require 'yaml'

# Lendo o arquivo YAML com as configuracoes do ambiente
env = YAML.load_file('environment.yaml')

# Limitando apenas a ultima versao estavel do Vagrant instalada
Vagrant.require_version '>= 2.0.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # forçar chave privada
  #config.ssh.private_key_path = "~/.ssh/id_rsa"
  #config.ssh.forward_agent = true
  
  # forçar senha
  #config.ssh.username = 'vagrant'
  #config.ssh.password = 'vagrant'
  #config.ssh.insert_key = false
  
  # provisionamento em todos os ambientes
  config.vm.provision 'shell' do |shell|
    shell.path               = 'provision/shell/comum.sh'
    shell.privileged         = true
  end
  # Iteracao com os servidores do ambiente
  env.each do |env|
    config.vm.define env['name'] do |srv|
      srv.vm.box      = env['box']
      srv.vm.hostname = env['hostname']
      srv.vm.network 'private_network', ip: env['ipaddress']
      if env['additional_interface'] == true
        srv.vm.network 'private_network', ip: '1.0.0.100',
          auto_config: false
      end
      srv.vm.provider 'virtualbox' do |vb|
        vb.name   = env['name']
        vb.memory = env['memory']
        vb.cpus   = env['cpus']
      end
      srv.vm.provision 'shell' do |shell|
        shell.path               = env['provision']
        shell.privileged         = true
      end
    end
  end
end
