#BKStorage

BKStorage is developed based on Ruby on Rails Framework, and deployed by using Passenger Nginx in Centos 6.5
###Installation
####Pre Installation
**OS Requirement**

OS Centos 6, 64 bit 

**Libraries Requirement**

Ruby 2.0
####Install Ruby by using RVM
    sudo yum groupinstall "Development Tools"
    sudo yum install -y curl-devel mysql-devel
    sudo yum install -y git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel sqlite-devel mysql-server
    curl -sSL https://get.rvm.io | bash -s stable

    echo '[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm" ' >> ~/.bashrc
    source ~/.bashrc
    # on non-root user
    sudo yum-config-manager --enable epel
    rvm requirements

    #install ruby
    rvm install 1.9.3
    rvm install 2.0.0
    source ~/.rvm/scripts/rvm
    rvm --default use 1.9.3
####Passenger Nginx Installation
    gem install passenger
    rvmsudo `which passenger-install-nginx-module`

    #fix nginx service
    wget —-no-check-certificate https://raw.github.com/kienbd/scripts/master/RoR/centos/nginx
    sudo cp nginx /etc/init.d/nginx
    sudo chmod +x /etc/init.d/nginx
    sudo chkconfig nginx on
    
####Gems Installation
    git clone git@github.com:kienbd/elrails.git ./elrails
    cd elrails
    bundle install

Configure CAS Server in file **config/config.yml**.

####Create database for production environment:
    cd bkdatabase
    RAILS_ENV=production rake db:recreate
####Precompile Assets
    RAILS_ENV=production rake assets:precompile
####Configure nginx in file /opt/nginx/conf/nginx.conf
    …
    user  bkstorage;
    worker_processes  1;

    …
    http {
    …
    server {
        listen       80;
        server_name  localhost;
        charset utf-8;
        root /home/bkstorage/elrails/public; #remember the "/public"
        passenger_enabled on;
        rails_spawn_method smart; #
        rails_env production; #config enviroment

        error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
        }
        …   
    }
  

#LICENSE
    /* This Source Code Form is subject to the terms of the Mozilla Public
    * License, v. 2.0. If a copy of the MPL was not distributed with this
    * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
