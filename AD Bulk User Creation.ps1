
# ------- Simple Password for Demo Purposes Only ------- #
$Initial_User_Password   = "Initial@Pass"
# ------------------------------------------------------ #

$password = ConvertTo-SecureString $Initial_User_Password -AsPlainText -Force

New-ADOrganizationalUnit -Name _USERS `
-ProtectedFromAccidentalDeletion $false ### Only for lab purposes, an OU should normally be protected. ###

# -- Change variable depending on individual use case -- #
$User_First_Last_Names = Get-Content .\names.txt
# ------------------------------------------------------ #

# Creating a user account for each person/name on the list
foreach ($name in $User_First_Last_Names) {
    $first = $name.Split(" ")[0].ToLower()
    $last = $name.Split(" ")[1].ToLower()
    $user = "$($first.Substring(0,1))$($last)".ToLower()
    
    # This section is to account for duplicates of same 1st initial + last name combination.
    $NameCheck = Get-ADUser -Filter {sAMAccountName -eq $user}
    if ($NameCheck -eq $null) {$username = $user}
    else {$username = $user + "" + $i++}
    
    Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Magenta
    
    New-ADUser -GivenName $first -Surname $last -DisplayName $username -Name $username -AccountPassword $password -EmployeeID $username `
               -Path "ou=_USERS,$(([ADSI]`"").distinguishedName)" -Enabled $true `
               -PasswordNeverExpires $true ### Only for lab purposes, password expiration should be utilized normally ###
}
