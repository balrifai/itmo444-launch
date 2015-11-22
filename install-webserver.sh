#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y php5 apache2 git php5-curl mysql-client curl php5-mysql

cp -R vendor/ /var/www/html

git clone https://github.com/balrifai/itmo444-appsetup.git

cp -R appsetup/* /var/www/html

php /var/www/html/setup.php
chmod 600 /var/www/html/setup.php

mv ../itmo444-appsetup/images /var/www/html/images
mv ../itmo444-appsetup/index.html /var/www/html
mv ../itmo444-appsetup/*.php /var/www/html

curl -s5 https://getcomposer.org/installer | php

sudo php composer.phar require aws/aws-sdk.php

sudo mv  vendor /var/www/html &> /tmp/runcomposer.txt
sudo php /var/www/html/setup.php &> /tmp/setup-db.txt

echo "Hello" > /tmp/hello.txt 
