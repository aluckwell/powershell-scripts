# Set subscription context and VM Variables
$subscriptionId = "<SubscriptionID>"
$vmNames = "VM01", "VM02", "VM03"

Set-AzContext -SubscriptionId $subscriptionId


#Begin foreach loop for each VM in $vmNames List
Foreach ($vmName in $vmNames) {
    # Get the VM object from the VM name

    $vm = Get-AzVM | Where-Object { $_.Name -eq $vmName} 

    #verify VM exists 
    if ($null -ne $vm) {

        Write-Host "Virtual Machine $($vm.name) detected, checking if Encryption at Host is enabled" -ForegroundColor Yellow 

        #Verify encryption at host is disabled and proceed to enable
        if ($vm.SecurityProfile.EncryptionAtHost -ne $true) {
            Write-Host "Encryption at Host is currently disabled on $($vm.name)" -ForegroundColor Yellow
    
            Write-Host "Stopping $($vm.name)" -ForegroundColor Yellow
            $vm | Stop-AzVM -Force
    
            Write-Host "Enabling Encryption at Host on $($vm.name)" -ForegroundColor Yellow
            Update-AzVM -VM $VM -ResourceGroupName $VM.ResourceGroupName -EncryptionAtHost $true
    
            Write-Host "Starting $($vm.name)"  -ForegroundColor Yellow
            $vm | Start-AzVM
            Write-Host "$($vm.name) Started"  -ForegroundColor Yellow
        }
        #If encryption at host is already enabled, skip...
        else {
            Write-Host "Encryption at Host currently is already enabled on $($vmName). Skipping" -ForegroundColor Green
        }

    }
    #If VM doesn't exist, report not found.
    else {
        Write-Host "VM $($vmName) not found, please check VM name and subscription" -ForegroundColor Red
    }
}