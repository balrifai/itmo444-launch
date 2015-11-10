#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y php5 apache2 git php5-curl mysql-client curl php5-mysql

git clone https://github.com/balrifai/itmo444-appsetup.git

mv ./itmo444-appsetup/images /var/www/html/images
mv ./itmo444-appsetup/index.html /var/www/html
mv ./itmo444-appsetup/*.php /var/www/html

curl -s5 https://getcomposer.org/installer | php

sudo php composer.phar require aws/aws-sdk.php

sudo vendor /var/www/html &> /tmp/runcomposer.txt

echo "Hello" . /tmp/hello.txt 
