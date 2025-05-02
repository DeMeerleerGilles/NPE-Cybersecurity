# Handleiding voor het opzetten de omgeving

In deze handleiding wordt uitgelegd hoe je de omgeving voor het project kunt opzetten. De omgeving wordt opgezet met behulp van Vbox manage.

## Stap 1: Download de benodigde software en bestanden

Download de ubuntu server VDI (20.04.4) van OSboxes <https://sourceforge.net/projects/osboxes/files/v/vb/59-U-u-svr/20.04/20.04.4/64bit.7z/download>

Pak deze zip uit en plaats de VDI in een map naar keuze. Voor het gemak kun je de VDI in de map van VirtualBox VMs plaatsen.

Deze staat standaard in `C:\Users\gebruikersnaam\VirtualBox VMs`.

Kopieer het pad naar de map waarin je de VDI hebt geplaatst. In Windows kun je dit eenvoudig doen door de ISO te selecteren en op Ctrl + Shift + C te drukken. Dit kopieert het pad naar het bestand.

Daarnaast heb je de `src` map van deze repository nodig. Deze map bevat alle configuratiebestanden die nodig zijn om de omgeving op te zetten. Maak dus een clone van deze repository.

## Stap 2: Pas de variabelen aan in het script

Om het script te kunnen gebruiken, moet je de volgende variabelen aanpassen:

```powershell
$mediumLocation = "C:\Users\gille\VirtualBox VMs\Ubuntu Server 20.04.4 (64bit).vdi"  # Pad waar de virtuele schijf wordt opgeslagen
```

## Stap 3: Voer het script uit

Eens alle paden zijn ingesteld, kun je het script uitvoeren.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process # Enkel nodig als je een beveiligingsfout krijgt
.\server-setup.ps1
```

Het script zal nu de omgeving opzetten. Dit kan enkele minuten duren.

Log in op de server met de volgende gegevens:

username: `osboxes`
password: `osboxes.org`

```bash
# Intaller nu ssh op de server
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh

# Vraag het ip adres op van de server
ip a
```

Zet de VM in bridge mode. Dit kan gedaan worden door de netwerkadapter van de VM aan te passen in VirtualBox. Ga naar de instellingen van de VM en kies voor "Netwerk". Kies voor "Bridged Adapter" en selecteer de netwerkadapter die je wilt gebruiken.

Verbind nu vanaf je host machine met de server via ssh. Dit kan met de volgende opdracht:

```bash
ssh osboxes@<ip-adres-van-server>
```

Kopieer het installatie script naar de server met scp of WinSCP (pas het ip adres aan naar het ip adres van de server):

```bash
scp -r ./install_webserver.sh osboxes@192.168.0.145:/home/osboxes/install_webserver.sh
```

Controlleer of het script goed is aangekomen met de volgende opdracht:

```bash
osboxes@osboxes:~$ ls
install_webserver.sh
```

Maak het script uitvoerbaar met de volgende opdracht:

```bash
chmod +x install_webserver.sh
```

Voer het script uit met de volgende opdracht:

```bash
./install_webserver.sh
```

Als je nu suft vanaf de kali naar het IP van de VM dan krijg je de vulnerable website te zien.