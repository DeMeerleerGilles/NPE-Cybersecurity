#!/bin/bash

set -e

# 1. Benodigdheden installeren
sudo apt update
sudo apt install -y build-essential zlib1g-dev libssl-dev libpam0g-dev libselinux1-dev wget

# 2. Download OpenSSH 8.3p1
cd /usr/local/src
sudo wget https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.3p1.tar.gz
sudo tar -xzf openssh-8.3p1.tar.gz
cd openssh-8.3p1

# 3. Configureren en installeren
sudo ./configure --prefix=/usr/local --sysconfdir=/usr/local/etc --with-md5-passwords
sudo make
sudo make install

# 4. Controleer of sshd nu bestaat
if [ ! -f /usr/local/sbin/sshd ]; then
    echo "sshd niet gevonden na installatie. Iets is misgegaan."
    exit 1
fi

# 5. Configuratiebestand aanmaken als het niet bestaat
if [ ! -f /usr/local/etc/sshd_config ]; then
    sudo cp contrib/redhat/sshd_config /usr/local/etc/sshd_config
    sudo sed -i 's/#Port 22/Port 22/' /usr/local/etc/sshd_config
    sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /usr/local/etc/sshd_config
fi

# 6. Systemd servicebestand maken
sudo tee /etc/systemd/system/sshd.service > /dev/null <<EOF
[Unit]
Description=OpenSSH 8.3p1 server
After=network.target

[Service]
ExecStart=/usr/local/sbin/sshd -D -f /usr/local/etc/sshd_config
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 7. Maak de sshd gebruiker aan voor privilege separation (indien nodig)
if ! id -u sshd > /dev/null 2>&1; then
    sudo useradd -r -M -d /var/empty -s /sbin/nologin sshd
fi

# 8. Herlaad systemd en start de service
sudo systemctl daemon-reload
sudo systemctl enable sshd.service
sudo systemctl start sshd.service

echo "OpenSSH 8.3p1 is succesvol geïnstalleerd en draait!"
