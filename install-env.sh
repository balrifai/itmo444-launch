#! /bin/bash 

sudo apt-get update -y 
sudo apt-get install -y apache2 git

git clone https://github.com/balrifai/itmo444-appsetup.git
mv ./itmo444-appsetup/images /var/www/html/images
mv ./itmo444-appsetup/index.html /var/www/html
mv ./itmo444-appsetup/page2.html /var/www/html 
echo "Hello!" > /tmp/hello.txt
