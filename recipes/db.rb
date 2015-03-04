#
# Cookbook Name:: laravel
# Recipe:: db
#
# Credits: David Stanley (https://github.com/davidstanley01/vagrant-chef/)
#

# Install MySQL server & MySQL client
include_recipe "mysql::client"
include_recipe "mysql::server"

# Create database if it doesn't exist
ruby_block "create_#{node['laravel']['name']}_db" do
    block do
        %x[mysql -uroot -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE #{node['laravel']['db_name']};"]
    end 
    not_if "mysql -uroot -p#{node['mysql']['server_root_password']} -e \"SHOW DATABASES LIKE '#{node['laravel']['db_name']}'\" | grep #{node['laravel']['db_name']}";
    action :create
end

bash 'run composer to grab extensions' do
  user 'root'
  cwd "/var/www/#{node['laravel']['name']}"
  code <<-EOH
  composer update
  EOH
end

# Run artisan migrate to setup the database and schema, then seed it
bash 'insert_db_laravel' do
  user 'root'
  cwd "/var/www/#{node['laravel']['name']}"
  code <<-EOH
  php artisan migrate --env=development
  php artisan db:seed --env=development
  EOH
end

bash 'insert_db_laravel_authentication_extension' do
  user 'root'
  cwd "/var/www/#{node['laravel']['name']}"
  code <<-EOH
  yes | php artisan authentication:install
  EOH
end

