APP_NAME = 'spree' #File.basename(Dir.getwd)

Vagrant.require_plugin 'vagrant-berkshelf'

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "https://hc-vagrant-files.s3.amazonaws.com/precise64.box"

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--vram', 64]
    v.customize ['modifyvm', :id, '--cpus', 4]
    v.customize ['modifyvm', :id, '--memory', 4096]
  end

  config.vm.network :forwarded_port, guest: 3000, host: 3001
  config.vm.network :forwarded_port, guest: 5432, host: 3002

  config.ssh.forward_agent = true

  config.vm.provision :shell, inline: %{
    echo "export LANGUAGE=\"en_US.UTF-8\"" >> /etc/profile.d/lang.sh
    echo "export LANG=\"en_US.UTF-8\"" >> /etc/profile.d/lang.sh
    echo "export LC_ALL=\"en_US.UTF-8\"" >> /etc/profile.d/lang.sh
  }

  config.vm.provision :shell, inline: %{
    locale-gen en_US.UTF-8
    dpkg-reconfigure locales
  }

  config.vm.provision :shell, inline: 'locale'

  config.berkshelf.enabled = true
  config.vm.provision :shell, :inline => "gem install chef --version 11.4.2 --no-rdoc --no-ri --conservative"

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe :apt
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'rvm::vagrant'
    chef.add_recipe 'rvm::system'
    chef.add_recipe 'git'
    chef.add_recipe 'imagemagick::rmagick'
    chef.add_recipe 'libqt4'
    chef.add_recipe 'xvfb'
    chef.add_recipe 'nodejs'
    chef.add_recipe 'phantomjs'
    chef.add_recipe 'mysql::client'
    chef.json = {
      :rvm => {
        :rubies => ['2.1.1']
      },
      :postgresql => {
        :config => {
          :listen_addresses => "localhost",
          :port => "5432"
        },
        :password => {
          :postgres => '',
        },
        :pg_hba => [
          {
            :type => "local",
            :db => "all",
            :user => "postgres",
            :addr => nil,
            :method => "trust"
          },
          {
            :type => "local",
            :db => "all",
            :user => "vagrant",
            :addr => nil,
            :method => "trust"
          },
          {
            :type => "host",
            :db => "all",
            :user => "all",
            :addr => "0.0.0.0/0",
            :method => "md5"
          },
          {
            :type => "host",
            :db => "all",
            :user => "all",
            :addr => "::1/0",
            :method => "md5"
          }
        ]
      },
      :mysql => {
        :client => {
          :packages => ["mysql-client", "libmysqlclient-dev","ruby-mysql"]
        }
      },
      :git => {
        :prefix => "/usr/local"
      }
    }
  end

  config.vm.provision :shell, :inline => %{
    sudo -u postgres psql -c "create user vagrant with superuser;"
  }

  #  sudo -u postgres psql -c "create database #{APP_NAME}_development with owner=vagrant encoding='utf8' template=template0 lc_collate='en_US.utf8' lc_ctype='en_US.utf8';"
  #  sudo -u postgres psql -c "create database #{APP_NAME}_test with owner=vagrant encoding='utf8' template=template0 lc_collate='en_US.utf8' lc_ctype='en_US.utf8';"

end
