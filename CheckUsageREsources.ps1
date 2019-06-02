<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

param(
    [Parameter(Mandatory=$true)] 
    [int]$MaxCpu,
    [Parameter(Mandatory=$true)] 
    [int]$MaxRam
)

$MaxCpu = 123
$MaxRam = 11

#Get Logon Users
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$Users = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current | Select-Object Name,SID

$Summary = New-Object System.Collections.ArrayList

#collect data
foreach ($user in $users){
    $Processes = Get-Process -IncludeUserName | Where-Object -Property UserName -like $user.UserName
    $USerMB =  ($Processes| Measure-Object WorkingSet -sum).Sum / 1kb
    $USerCPU = ($Processes | Measure-Object CPU -sum).Sum
    
    $item = New-Object psobject
    $Item | Add-Member NoteProperty userName    $user.Name
    $Item | Add-Member NoteProperty userSid     $user.Sid
    $Item | Add-Member NoteProperty CPUTotal    $USerCPU
    $Item | Add-Member NoteProperty MBTotal     $USerMB
    $Summary.Add($item) |Out-Null
}

#Show warning message 
foreach ($user in $Summary){
    $NeedToWarninig = $false

    if (($user.CPUTotal -gt $MaxCpu) -and ($User.MBTotal -lt $MaxRam)){
        $MessageBody = "Check your CPU"
        $NeedToWarninig = $true
     } 
    if (($user.CPUTotal -lt $MaxCpu) -and ($User.MBTotal -gt $MaxRam)){
        $MessageBody = "Check your Ram"
        $NeedToWarninig = $true
     } 
    if (($user.CPUTotal -gt $MaxCpu) -and ($User.MBTotal -gt $MaxRam)){
        $MessageBody = "Check your CPU and Ram"
        $NeedToWarninig = $true
     } 

     if ($NeedToWarninig -eq $true){msg $user.userName /server:localhost "$MessageBody"}
}