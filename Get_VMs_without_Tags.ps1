<#
.SYNOPSIS
    Get_VMs_Without_Tags.ps1 - PowerShell Script to gather all VM's from your vCenter server who don't have a vSphere Tag.
.DESCRIPTION
    This script is used to gather all VMs from your vCenter server who don't have a tag out of a specific category.
    The output is saved into a file on the destination you decide.
    The file output ONLY gets send via E-Mail if the amount of VMs without a tag is greater than 0, which means you will only get a mail if a VM exists without a vSphere Tag !
.OUTPUTS
    Results are printed to the console.
.NOTES
    Author        Falko Banaszak, https://virtualhome.blog, Twitter: @Falko_Banaszak
    
    Change Log    V1.00, 27/05/2020 - Initial version: Gathers all VMs without a vSphere Tag and places the output into a file.
    Change Log    V1.01, 28/06/2020 - Update: added function to send E-Mails if the file has contents
    Change Log    V1.02, 28/06/2020 - Update: added function to delete finding files older than 30 days
    Change Log    V1.03, 04/06/2020 - Update: added the VMware credential store item to make the connection to vCenter
.LICENSE
    MIT License
    Copyright (c) 2019 Falko Banaszak
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

# Path to the file which gets send as an attachement
# Adjust the variable $WorkingPath to your needs !
$FileToAttach = "$WorkingPath\VMsWithoutTags_$(Get-Date -format dd_MM_yyyy_hh_mm_ss).txt"
$WorkingPath = "C:\VMsWithoutTags"

# E-Mail settings
# Adjust all these mail variables to your needs except the $Attachement variable !
$From = "veeam-server@domain.com"
$To = "veeam-administrator@domain.com"
$Attachment = "$FileToAttach"
$Subject = "VMs without Tags"
$Body = "Please find attached the list of VMs which are not tagged"
$SMTPServer = "smtp-server.domain.com"
$SMTPPort = "25"

# VMware settings
# Adjust the VMware credentials and variables to your needs. Also don't forget to use a path where the credential.xml will be saved.
$vCenterServer = "vcenter.domain.com"
$vCenterUser = "domain\vcenteruser"
$vCenterUserPassword = 'y0ur_53cur3_p455w0rd'
$CredentialXML = "C:\Path\credentials.xml"
New-VICredentialStoreItem -Host $vCenterServer -User $vCenterUser -Password $vCenterUserPassword -file $CredentialXML
$Credentials = Get-VICredentialStoreItem -File $CredentialXML

# Enter your tag category you want to check here
$TagCategory ="Veeam Backup Tags"

# Load the PowerCLI SnapIn and set the configuration
Add-PSSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# Connect to the vCenter Server with collected credentials
Connect-VIServer -Server $Credentials.Host -User $Credentials.User -Password $Credentials.Password | Out-Null

# Get all VMs and check if they have a vSphere Tag out of the given category
Get-VM | Where-Object {(Get-TagAssignment $_ -Category $TagCategory) -eq $null} | Out-File -FilePath $FileToAttach

# Finally check if the file contains content, which means there is a VM without a tag and send it via e-mail
if ($null -eq (Get-Content -Path "$FileToAttach")) {
    Write-Host "No VMs found with a missing vSphere Tag" -ForegroundColor Green
}
else {
    Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -Priority High -DeliveryNotificationOption None -SmtpServer $SMTPServer -Port $SMTPPort
}
# Disconnecting from the vCenter Server
Disconnect-VIServer * -Confirm:$false
Write-Host "Disconnected from your vCenter Server $vCenterServer" -ForegroundColor Green

# Check if written files are older than 30 days and delete them
$DaysToDelete = "-30"
$CurrentDate = Get-Date
$DeleteDays = $CurrentDate.AddDays($DaysToDelete)
Get-ChildItem $WorkingPath | Where-Object { $_.LastWriteTime -lt $DeleteDays } | Remove-Item