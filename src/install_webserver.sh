#!/bin/bash

# Installeer Apache 2.4.50 (kwetsbare versie voor CVE-2021-42013)
echo "Installeer Apache 2.4.50..."

# Voeg de bronnen voor Apache 2.4.50 toe
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/apache2
sudo apt update

# Installeer specifieke versie van Apache
sudo apt install -y apache2=2.4.50-1+ubuntu20.04.1+deb.sury.org+1

# Configureer Apache om de kwetsbaarheid te demonstreren
echo "Configureer Apache voor de exploit..."

# Schakel de CGI-module in (nodig voor de exploit)
sudo a2enmod cgi
sudo systemctl restart apache2

# Maak een eenvoudige HTML-pagina aan
echo "<html><body><h1>Welkom op de kwetsbare Apache server!</h1></body></html>" | sudo tee /var/www/html/index.html

# Herstart Apache om de wijzigingen door te voeren
sudo systemctl restart apache2

echo "Apache 2.4.50 is geïnstalleerd en geconfigureerd voor de exploit!"