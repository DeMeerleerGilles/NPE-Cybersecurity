# Variabelen
$VM_NAME = "Ubuntu-Server"
$VM_RAM = "2048"       
$VM_CPUS = "2"            
$VM_VDI_PATH = "C:\Users\gille\VirtualBox VMs"  # Pad waar de virtuele schijf wordt opgeslagen
$VM_ISO_PATH = "C:\Users\gille\ISO\ubuntu-24.04.2-live-server-amd64.iso"  # Pad naar de Ubuntu Server ISO
$INSTALL_SCRIPT_PATH = ".\install_webserver.sh" 
$VM_USERNAME = "admin"
$VM_PASSWORD = "NPE-cybers3curity"

# Controleer of de ISO bestaat
if (-Not (Test-Path $VM_ISO_PATH)) {
    Write-Host "Fout: De ISO is niet gevonden op het opgegeven pad: $VM_ISO_PATH"
    exit
}


# Maak een nieuwe VM aan
Write-Host "Maak een nieuwe VM aan: $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

# Configureer de VM
Write-Host "Configureer de VM: RAM en CPU"
VBoxManage modifyvm "$VM_NAME" --memory "$VM_RAM" --cpus "$VM_CPUS" --nic1 nat --graphicscontroller vboxsvga

# Maak een virtuele schijf aan
Write-Host "Maak een virtuele schijf aan: $VM_VDI_PATH"
VBoxManage createhd --filename "$VM_VDI_PATH" --size 20480 --format VDI  # 20 GB schijf

# Koppel de virtuele schijf aan de VM
Write-Host "Koppel de virtuele schijf aan de VM"
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_VDI_PATH"

# Koppel de ISO voor installatie
Write-Host "Koppel de ISO voor installatie: $VM_ISO_PATH"
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$VM_ISO_PATH"

# Start de VM op om Ubuntu Server te installeren
Write-Host "Start de VM op om Ubuntu Server te installeren..."
VBoxManage startvm "$VM_NAME" --type gui

# Wacht tot de installatie is voltooid
Write-Host "Wacht tot de installatie van Ubuntu Server is voltooid..."
Read-Host "Druk op Enter nadat de installatie is voltooid en de VM is afgesloten."

# Start de VM opnieuw op in headless modus
Write-Host "Start de VM opnieuw op in headless modus..."
VBoxManage startvm "$VM_NAME" --type headless

# Wacht even tot de VM is opgestart
Start-Sleep -Seconds 30

# Kopieer het installatiescript naar de VM
Write-Host "Kopieer het installatiescript naar de VM"
VBoxManage guestcontrol "$VM_NAME" copyto --username "$VM_USERNAME" --password "$VM_PASSWORD" --target-directory /tmp "$INSTALL_SCRIPT_PATH"

# Voer het installatiescript uit in de VM
Write-Host "Voer het installatiescript uit in de VM"
VBoxManage guestcontrol "$VM_NAME" run --username "$VM_USERNAME" --password "$VM_PASSWORD" -- /bin/bash /tmp/install_webserver.sh

Write-Host "De VM is succesvol aangemaakt, Ubuntu Server is geïnstalleerd en de webserver is geconfigureerd!"