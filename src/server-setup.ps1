# Variabelen
$VM_NAME = "Ubuntu-Server"
$VM_RAM = "2048"            # RAM in MB
$VM_CPUS = "2"              # Aantal CPU-cores
$VM_VDI_PATH = "C:\path\to\Ubuntu-Server.vdi"  # Pad naar de bestaande Ubuntu Server VDI
$INSTALL_SCRIPT_PATH = ".\install_webserver.sh"  # Relatief pad naar het Bash-script

# Controleer of het Bash-script bestaat
if (-Not (Test-Path $INSTALL_SCRIPT_PATH)) {
    Write-Host "Fout: Het Bash-script is niet gevonden op het opgegeven pad: $INSTALL_SCRIPT_PATH"
    exit
}

# Maak een nieuwe VM aan
Write-Host "Maak een nieuwe VM aan: $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

# Configureer de VM
Write-Host "Configureer de VM: RAM en CPU"
VBoxManage modifyvm "$VM_NAME" --memory "$VM_RAM" --cpus "$VM_CPUS" --nic1 nat --graphicscontroller vboxsvga

# Koppel de bestaande virtuele schijf aan de VM
Write-Host "Koppel de bestaande virtuele schijf aan de VM: $VM_VDI_PATH"
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_VDI_PATH"

# Start de VM op
Write-Host "Start de VM op: $VM_NAME"
VBoxManage startvm "$VM_NAME" --type headless

# Wacht even tot de VM is opgestart
Start-Sleep -Seconds 30

# Kopieer het installatiescript naar de VM
Write-Host "Kopieer het installatiescript naar de VM"
VBoxManage guestcontrol "$VM_NAME" copyto --username osboxes --password osboxes.org --target-directory /tmp "$INSTALL_SCRIPT_PATH"

# Voer het installatiescript uit in de VM
Write-Host "Voer het installatiescript uit in de VM"
VBoxManage guestcontrol "$VM_NAME" run --username osboxes --password osboxes.org -- /bin/bash /tmp/install_webserver.sh

Write-Host "De VM is succesvol aangemaakt en Apache 2.4.50 is geïnstalleerd!"