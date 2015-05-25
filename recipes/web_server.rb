#
# Cookbook Name:: laravel
# Recipe:: web_server
#
# Copyright 2013, Mathias Hansen
#

# Install xdebug
include_recipe "chef-php-extra::xdebug"

# Install Composer
bash "composer" do
  code <<-EOH
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
  EOH
end
