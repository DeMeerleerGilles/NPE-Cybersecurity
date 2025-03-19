# Handleiding voor het opzetten de omgeving

In deze handleiding wordt uitgelegd hoe je de omgeving voor het project kunt opzetten. De omgeving wordt opgezet met behulp van Vbox manage.

## Stap 1: Download de benodigde software en bestanden

Download de ubuntu server VDI van OSboxes <https://www.osboxes.org/ubuntu-server/>

Pak deze zip uit en plaats de VDI in een map naar keuze. Voor het gemak kun je de VDI in de map van VirtualBox VMs plaatsen.

Deze staat standaard in `C:\Users\gebruikersnaam\VirtualBox VMs`.

Kopieer het pad naar de map waarin je de VDI hebt geplaatst. In Windows kun je dit eenvoudig doen door de ISO te selecteren en op Ctrl + Shift + C te drukken. Dit kopieert het pad naar het bestand.

Daarnaast heb je de `src` map van deze repository nodig. Deze map bevat alle configuratiebestanden die nodig zijn om de omgeving op te zetten. Maak dus een clone van deze repository.

## Stap 2: Pas de variabelen aan in het script

Om het script te kunnen gebruiken, moet je de volgende variabelen aanpassen:

```powershell
$VM_VDI_PATH = "C:\Users\gille\VirtualBox VMs"  # Pad waar de virtuele schijf wordt opgeslagen
$VM_ISO_PATH = "C:\ISOs\ubuntu-server.iso"  # Pad naar de Ubuntu Server ISO
```

## Stap 3: Voer het script uit

Eens alle paden zijn ingesteld, kun je het script uitvoeren.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process # Enkel nodig als je een beveiligingsfout krijgt
.\server-setup.ps1
```
