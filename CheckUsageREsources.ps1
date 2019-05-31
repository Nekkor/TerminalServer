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
$Summary







([wmi]"").ConvertToDateTime((Get-WmiObject -Class Win32_UserProfile | Where-Object SID -eq $user.SID).LastUseTime)


$wmi = Get-WmiObject -Class Win32_UserProfile | Where-Object SID -eq $user.SID
$wmi