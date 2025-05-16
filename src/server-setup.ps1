# Zet VirtualBox in PATH als het nog niet is toegevoegd
$virtualBoxPath = "C:\Program Files\Oracle\VirtualBox"
if (-not ($env:PATH -like "*$virtualBoxPath*")) {
    $env:PATH += ";$virtualBoxPath"
}

# Naam van de VM en pad naar VDI-bestand
$vm_name = "Cybersecurity_NPE_Ubuntu"
$mediumLocation = "C:\Users\gille\VirtualBox VMs\Ubuntu Server 20.04.4 (64bit).vdi"

# Haal de eerste door VB erkende bridge-adapter op
$bridge = (& VBoxManage list bridgedifs |
            Select-String '^Name:' |
            Select-Object -First 1).ToString().Split(':',2)[1].Trim()

# Controleer welke adapter is gekozen             
Write-Host "Gekozen bridged-adapter:" $bridge


# Controleer of het VDI-bestand bestaat
if (-not (Test-Path $mediumLocation)) {
    Write-Error "VDI-bestand niet gevonden op pad: $mediumLocation"
    exit 1
}

# Maak de VM aan
VBoxManage createvm --name $vm_name `
    --ostype "Ubuntu_64" `
    --register `
    --groups "/NPE Cybersecurity 24-25"

# Configureer de VM
VBoxManage modifyvm $vm_name `
    --memory 4096 `
    --cpus 2 `
    --vram 128 `
    --clipboard-mode bidirectional `
    --graphicscontroller vmsvga

# Voeg een SATA-controller toe
VBoxManage storagectl $vm_name `
    --name "SATA Controller" `
    --add sata `
    --controller IntelAhci

# Koppel de VDI aan de VM
VBoxManage storageattach $vm_name `
    --storagectl "SATA Controller" `
    --port 0 `
    --device 0 `
    --type hdd `
    --medium "$mediumLocation"

# Zet netwerk van VM in bridged adapter
VBoxManage modifyvm $vm_name --nic1 bridged --bridgeadapter1 $bridge


# Start de VM
VBoxManage startvm $vm_name
