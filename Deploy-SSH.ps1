# Wannabe Seamless SSH installer by PePi. Run from the SSH install folder only!

# Please watch the prompt closely and act to allow all required actions 
# Before starting troubleshooting, try to run the deployer script again with -force parameter and ignore any red vomits


$ForceFlag = ($args[0]).count

# first test if SSH present

$ssh = (gsv ssh*).count

if (($ssh -lt 2) -or ($forceflag -gt 0) ) {

# copy files from current location to C:\Program Files\OpenSSH (this is required path, will be created)

md "C:\Program Files\OpenSSH"
copy .\*.* "C:\Program Files\OpenSSH"
md c:\programdata\ssh


# copy config file with pre-defined SSH port 22

copy ".\sshd_config_original" "c:\programdata\ssh\sshd_config"

# run the installer 

cd "C:\Program Files\OpenSSH"
.\install-sshd.ps1

# setup services

"waiting 5 seconds for SSH services to initialize safely . . ."
sleep 5

# repair possible permissions issues

.\FixHostFilePermissions.ps1
.\FixUserFilePermissions.ps1

Set-Service sshd -startuptype Automatic
Set-Service ssh-agent -startuptype Automatic

gsv ssh* | Start-service 

# adding FW rules 

 New-NetFirewallRule -DisplayName "Allow inbound port 22 for SSH" -Direction inbound -LocalPort 22 -Protocol TCP -Action Allow
 New-NetFirewallRule -DisplayName "Allow outbound port 22 for SSH" -Direction inbound -LocalPort 22 -Protocol TCP -Action Allow

# adding a program folder to PATH system variable

[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSH", "Machine")} else {"SSH already installed and running!"}

# result check

gsv ssh* | select Status, name, displayname, StartType
