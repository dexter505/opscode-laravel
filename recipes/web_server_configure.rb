#
# Cookbook Name:: laravel
# Recipe:: web_server_configure
#
# Copyright 2015, Dexter Alkus
#

# Install mcrypt
include_recipe "chef-php-extra::module_mcrypt"

# Install xdebug
#include_recipe "chef-php-extra::xdebug"
