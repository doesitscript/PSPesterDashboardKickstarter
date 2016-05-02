# Modified "snapshot" from PSHIrwin of https://pshirwin.wordpress.com/
[cmdletbinding()]
Param()

Import-Module ActiveDirectory -Verbose:$false

#HashTable to save ADReport
$ADSnapshot = @{}

#region Main
$ADSnapshot.RootDSE = $(Get-ADRootDSE)
$ADSnapshot.ForestInformation = $(Get-ADForest)
$ADSnapshot.DomainInformation = $(Get-ADDomain)
$ADSnapshot.DomainControllers = $(Get-ADDomainController -Filter *)
$ADSnapshot.DefaultPassWordPoLicy = $(Get-ADDefaultDomainPasswordPolicy)
$ADSnapshot.DomainAdministrators =$( Get-ADGroup -Identity $('{0}-512' -f (Get-ADDomain).domainSID) | Get-ADGroupMember -Recursive)
$ADSnapshot.OrganizationalUnits = $(Get-ADOrganizationalUnit -Filter *)
$ADSnapshot.OptionalFeatures =  $(Get-ADOptionalFeature -Filter *)
#endregion

#Write-Output $ADSnapshot | Export-Clixml -Path C:\OneDrive\Develop\Git\PSPesterPresentationKit.HV1\OperationalBaselines\
$ADSnapshot

