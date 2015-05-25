name              "laravel"
maintainer        "Dexter Alkus"
maintainer_email  "dexter505@yahoo.com"
description       "Main entry point for installing and configuring a Laravel 5 stack"
version           "1.0.0"

recipe "laravel", "Main entry point for installing and configuring a Laravel 5 stack"

depends "apt"
depends "chef-php-extra"
#depends "npm"

%w{ debian ubuntu }.each do |os|
  supports os
end
