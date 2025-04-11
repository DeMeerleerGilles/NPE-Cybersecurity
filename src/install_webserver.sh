#!/bin/bash

echo "Installeer Apache 2.4.50 ..."

# Update package lists
sudo apt update

# Installeer benodigde afhankelijkheden
sudo apt install -y software-properties-common wget build-essential \
    libpcre3 libpcre3-dev libssl-dev zlib1g-dev libexpat1-dev

# Download Apache, APR en APR-Util broncode
wget https://archive.apache.org/dist/httpd/httpd-2.4.50.tar.gz
wget https://archive.apache.org/dist/apr/apr-1.7.0.tar.gz
wget https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz

# Pak alles uit
tar xvf httpd-2.4.50.tar.gz
tar xvf apr-1.7.0.tar.gz
tar xvf apr-util-1.6.1.tar.gz

# Verplaats APR en APR-Util naar de Apache source tree
mv apr-1.7.0 httpd-2.4.50/srclib/apr
mv apr-util-1.6.1 httpd-2.4.50/srclib/apr-util

# Configureer en compileer Apache
cd httpd-2.4.50
./configure --enable-cgi --enable-so --with-mpm=event
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

# Activeer CGI-module
sudo sed -i 's|#LoadModule cgi_module modules/mod_cgi.so|LoadModule cgi_module modules/mod_cgi.so|' /usr/local/apache2/conf/httpd.conf

# Pas Directory-blok aan (vervang indien al aanwezig)
sudo sed -i '/<Directory "\/usr\/local\/apache2\/cgi-bin">/,/<\/Directory>/c\<Directory "/usr/local/apache2/cgi-bin">\n    Options +ExecCGI\n    AddHandler cgi-script .cgi .pl .sh\n    AllowOverride All\n    Require all granted\n</Directory>' /usr/local/apache2/conf/httpd.conf

# Voeg AllowEncodedSlashes toe als het nog niet bestaat
if ! grep -q "AllowEncodedSlashes" /usr/local/apache2/conf/httpd.conf; then
    echo -e "\n# Nodig voor exploit van CVE-2021-42013\nAllowEncodedSlashes NoDecode" | sudo tee -a /usr/local/apache2/conf/httpd.conf > /dev/null
fi

# Herstart Apache om alles toe te passen
sudo apachectl restart

# Maak een eenvoudige testpagina aan met cybersecurity-thema
cat << 'EOF' | sudo tee /usr/local/apache2/htdocs/index.html > /dev/null
<!DOCTYPE html>
<html lang="nl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Apache 2.4.50 – Cybersec Lab</title>
  <style>
    body {
      background-color: #0d1117;
      color: #f0f6fc;
      font-family: 'Courier New', Courier, monospace;
      text-align: center;
      padding: 50px;
    }
    h1 {
      font-size: 2.5em;
      color: #39ff14;
      margin-bottom: 10px;
      animation: blink 1.5s infinite;
    }
    h2 {
      color: #58a6ff;
    }
    .box {
      border: 1px solid #58a6ff;
      padding: 20px;
      background: #161b22;
      box-shadow: 0 0 20px #39ff14;
      display: inline-block;
      max-width: 600px;
      margin-top: 30px;
    }
    @keyframes blink {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }
    .footer {
      margin-top: 50px;
      font-size: 0.9em;
      color: #8b949e;
    }
  </style>
</head>
<body>
  <h1>[!] Apache 2.4.50 actief</h1>
  <div class="box">
    <h2>Cybersecurity Lab VM</h2>
    <p>Deze server draait een kwetsbare versie van Apache (<strong>CVE-2021-42013</strong>).</p>
    <p>Enkel te gebruiken voor pen testing.</p>
  </div>
  <div class="footer">
    Cybersecurity and Virtualization HOGENT<br>
    <a href="https://github.com/DeMeerleerGilles">Gilles De Meerleer</a>, <a href="https://github.com/YanaCattoir">Yana Cattoir</a> en <a href="https://github.com/Davinski12">David Bukasa Ntunu</a> 
  </div>
</body>
</html>
EOF

# Geef de juiste rechten
sudo chmod -R 755 /usr/local/apache2/htdocs

# Controleer of Apache correct draait
sudo apachectl status
