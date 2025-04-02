#!/bin/bash

# Installeer Apache 2.4.50 (kwetsbare versie voor CVE-2021-42013)
echo "Installeer Apache 2.4.50 vanaf bron..."

# Update package lists
sudo apt update

# Installeer benodigde afhankelijkheden
sudo apt install -y software-properties-common wget build-essential libpcre3 libpcre3-dev libssl-dev zlib1g-dev

# Download Apache 2.4.50 broncode
wget https://archive.apache.org/dist/httpd/httpd-2.4.50.tar.gz

tar xvf httpd-2.4.50.tar.gz
cd httpd-2.4.50

# Installeer APR en APR-Util
wget https://archive.apache.org/dist/apr/apr-1.7.0.tar.gz
wget https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz

# Uitpakken en installeren van APR
tar xvf apr-1.7.0.tar.gz
cd apr-1.7.0
./configure --prefix=/usr/local/apr
make -j$(nproc)
sudo make install
cd ..

# Uitpakken en installeren van APR-Util
tar xvf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
./configure --with-apr=/usr/local/apr
make -j$(nproc)
sudo make install
cd ..

# Configureer en compileer Apache
./configure --enable-cgi --enable-so --with-mpm=event --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr
make -j$(nproc)
sudo make install

# Zet Apache in het pad
sudo ln -sf /usr/local/apache2/bin/apachectl /usr/bin/apachectl

# Start Apache
sudo apachectl start

# Controleer of Apache draait
if pgrep -x "httpd" > /dev/null; then
    echo "Apache is succesvol geïnstalleerd en gestart."
else
    echo "Apache kon niet starten. Controleer de logs."
    exit 1
fi

# Configureer CGI-module
sudo sed -i 's|#LoadModule cgi_module modules/mod_cgi.so|LoadModule cgi_module modules/mod_cgi.so|' /usr/local/apache2/conf/httpd.conf

echo "<Directory \"/usr/local/apache2/cgi-bin\">
    Options +ExecCGI
    AddHandler cgi-script .cgi .pl
</Directory>" | sudo tee -a /usr/local/apache2/conf/httpd.conf

# Herstart Apache
sudo apachectl restart

# Maak een eenvoudige testpagina aan
echo "<html><body><h1>Welkom op de kwetsbare Apache server!</h1></body></html>" | sudo tee /usr/local/apache2/htdocs/index.html

# Geef de juiste rechten
sudo chmod -R 755 /usr/local/apache2/htdocs

# Controleer of Apache correct draait
sudo apachectl status
