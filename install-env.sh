#! /bin/bash 

sudo apt-get update -y 
sudo apt-get install -y apache2 git

git clone https://github.com/balrifai/itmo444-fall2015.git
mv ./itmo444-fall2015/images /var/www/html/images
mv ./itmo444-fall2015/index.html /var/www/html
 
echo "Hello!" > /tmp/hello.txt
