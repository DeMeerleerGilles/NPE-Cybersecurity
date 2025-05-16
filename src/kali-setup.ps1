# Kali VM toevoegen
$kali_vm_name       = "Cybersecurity_NPE_Kali"
$kali_mediumLocation = "C:\Users\bukas\VirtualBoxVMs\Kali Linux 2024.4 (64bit).vdi"

# Controleer of het Kali-VDI-bestand bestaat
if (-not (Test-Path $kali_mediumLocation)) {
    Write-Error "Kali VDI-bestand niet gevonden op pad: $kali_mediumLocation"
    exit 1
}

# Haal de eerste door VB erkende bridge-adapter op
$bridge = (& VBoxManage list bridgedifs |
            Select-String '^Name:' |
            Select-Object -First 1).ToString().Split(':',2)[1].Trim()

# Controleer welke adapter is gekozen             
Write-Host "Gekozen bridged-adapter:" $bridge

# Maak de Kali-VM aan
VBoxManage createvm --name $kali_vm_name `
    --ostype "Debian_64" `
    --register `
    --groups "/NPE Cybersecurity 24-25"

# Configureer de Kali-VM (zelfde resources als Ubuntu)
VBoxManage modifyvm $kali_vm_name `
    --memory 4096 `
    --cpus 2 `
    --vram 128 `
    --clipboard-mode bidirectional `
    --graphicscontroller vmsvga

# Voeg een SATA-controller toe voor Kali
VBoxManage storagectl $kali_vm_name `
    --name "SATA Controller" `
    --add sata `
    --controller IntelAhci

# Koppel het Kali-VDI aan de Kali-VM
VBoxManage storageattach $kali_vm_name `
    --storagectl "SATA Controller" `
    --port 0 `
    --device 0 `
    --type hdd `
    --medium "$kali_mediumLocation"

# Zet VM in bridged networking
VBoxManage modifyvm $kali_vm_name --nic1 bridged --bridgeadapter1 $bridge

# Start de Kali-VM
VBoxManage startvm $kali_vm_name