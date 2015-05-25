#
# Cookbook Name:: laravel
# Recipe:: web_server
#
# Copyright 2013, Mathias Hansen
#

# Install xdebug
include_recipe "chef-php-extra::xdebug"

node[:deploy].each do |app_name, deploy|

  script "install_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    curl -sS https://getcomposer.org/installer | php
    php composer.phar install --no-dev
    sudo mv composer.phar /usr/local/bin/composer
    EOH
  end

  template "#{deploy[:deploy_to]}/current/db-connect.php" do
    source "db-connect.php.erb"
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
      :db =>       (deploy[:database][:database] rescue nil),
      :table =>    (node[:phpapp][:dbtable] rescue nil)
    )

   only_if do
     File.directory?("#{deploy[:deploy_to]}/current")
   end
  end
  
  bash 'run composer to grab extensions' do
  user 'root'
  cwd "#{deploy[:deploy_to]}/current"
  code <<-EOH
  composer update
  EOH
  end

  # Run jocopo user auth plugin install first
  bash 'insert_db_laravel_authentication_extension' do
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    yes | php artisan authentication:install
    EOH
  end

  # Run artisan migrate to setup the database and schema, then seed it
  bash 'insert_db_laravel' do
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    php artisan migrate --env=development
    php artisan db:seed --env=development
    EOH
  end
end
