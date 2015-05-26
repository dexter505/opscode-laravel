#
# Cookbook Name:: laravel
# Recipe:: web_server_configure
#
# Copyright 2015, Dexter Alkus
#

# Install mcrypt
include_recipe "chef-php-extra::module_mcrypt"

#not sure why this doesn't happen in the mcrypt recipe...
node[:deploy].each do |app_name, deploy|

  script "enable_mcrypt" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    sudo php5enmod mcrypt
    EOH
  end
end

# Install xdebug
include_recipe "chef-php-extra::xdebug"

# Install composer
node[:deploy].each do |app_name, deploy|
  script "install_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    EOH
  end
end
