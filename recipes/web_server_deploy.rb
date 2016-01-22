#
# Cookbook Name:: laravel
# Recipe:: web_server_deploy
#
# Copyright 2015, Dexter Alkus
#

node[:deploy].each do |app_name, deploy|

  template "#{deploy[:deploy_to]}/current/.env" do
    source ".env.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")   
      owner "apache"
    end

    variables(
      :host =>     (deploy[:database][:host] rescue nil),
      :user =>     (deploy[:database][:username] rescue nil),
      :password => (deploy[:database][:password] rescue nil),
      :db =>       (deploy[:database][:database] rescue nil)
    )

   only_if do
     File.directory?("#{deploy[:deploy_to]}/current")
   end
  end
  
  #not sure why this doesn't happen in the mcrypt recipe...
  script "enable_mcrypt" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    sudo php5enmod mcrypt
    EOH
  end

  # correct permissions to allow apache to write
    execute "chmod #{deploy[:deploy_to]}/current/storage" do
        cwd "#{deploy[:deploy_to]}/current/storage"
        command "chmod -R u+rwX,g+rwX ."
    end

  # Download composer
  script "download_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    curl -sS https://getcomposer.org/installer | php
    EOH
  end

  # Move composer to bin
  script "move_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    mv composer.phar /usr/local/bin/composer
    EOH
  end

  # Install Laravel
  script "install_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    composer install --no-dev --no-interaction --optimize-autoloader
    EOH
  end

  # Run jocopo user auth plugin install first
  #bash 'insert_db_laravel_authentication_extension' do
    #user 'root'
    #cwd "#{deploy[:deploy_to]}/current"
    #code <<-EOH
    #yes | php artisan authentication:install
    #EOH
  #end

  # Run artisan migrate to setup the database and schema, then seed it
  #bash 'insert_db_laravel' do
    #user 'root'
    #cwd "#{deploy[:deploy_to]}/current"
    #code <<-EOH
    #php artisan migrate --env=development
    #php artisan db:seed --env=development
    #EOH
  #end
  
  nodejs_npm "phantomjs" do
    version "1.9.*"
  end
end
