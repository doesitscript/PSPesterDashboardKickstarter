# Courtesy of https://pshirwin.wordpress.com/

<#[CmdletBinding()]
Param(
    $xmlFile = "C:\Dev\Verification\OperationalReports\BaseLineName.xml" 
)#>

# Active Directory configuration as you expect it to be. Modify to reflect your AD

#hard coded due to restrction on invoke-pester -script ScriptName  <--needed to pass argument for stored xml data
$CurrentBaseline = Import-Clixml -Path #BaseLineOutPath#

#Import saved AD snapshot
$Snapshot = Import-Clixml -Path #BaseSnapshotPath#

Describe 'Active Directory configuration operational readiness' {

    Context 'Verifying Forest Configuration'{
        it "Forest FQDN $($CurrentBaseline.Forest.FQDN)" {
            $CurrentBaseline.ForestInformation.RootDomain | Should be $Snapshot.ForestInformation.RootDomain
        }
        it "ForestMode $($CurrentBaseline.ForestInformation.ForestMode.ToString())"{
            $CurrentBaseline.ForestInformation.ForestMode | Should be $Snapshot.ForestInformation.ForestMode.ToString()
        }
        it "Server $($CurrentBaseline.ForestInformation.SchemaMaster) is SchemaMaster"{
            $CurrentBaseline.ForestInformation.SchemaMaster | Should be $Snapshot.ForestInformation.SchemaMaster
        }
        it "Server $($CurrentBaseline.ForestInformation.DomainNamingMaster) is DomainNamingMaster"{
            $CurrentBaseline.ForestInformation.DomainNamingMaster | Should be $Snapshot.ForestInformation.DomainNamingMaster
        }
    }

    Context 'Verifying GlobalCatalogs'{
        $CurrentBaseline.ForestInformation.GlobalCatalogs | 
        ForEach-Object{
            it "Server $($_) is a GlobalCatalog"{
                $Snapshot.ForestInformation.GlobalCatalogs.Contains($_) | Should be $true
            }
        }
    }

    Context 'Verifying Domain Configuration'{
        it "Total Domain Controllers $($CurrentBaseline.Domain.DomainControllers.Count)" {
            $CurrentBaseline.Domain.DomainControllers.Count | Should be @($Snapshot.DomainControllers).Count
        }

        $CurrentBaseline.Domain.DomainControllers | 
        ForEach-Object{
            it "DomainController $($_) exists"{
                $Snapshot.DomainControllers.Name.Contains($_) | Should be $true
            }
        }
        it "DNSRoot $($CurrentBaseline.DomainInformation.DNSRoot)"{
            $CurrentBaseline.DomainInformation.DNSRoot | Should be $Snapshot.DomainInformation.DNSRoot
        }
        it "NetBIOSName $($CurrentBaseline.Domain.NetBIOSName)"{
            $CurrentBaseline.DomainInformation.NetBIOSName | Should be $Snapshot.DomainInformation.NetBIOSName
        }
        it "DomainMode $($CurrentBaseline.DomainInformation.DomainMode.ToString())"{
            $CurrentBaseline.DomainInformation.DomainMode.ToString() | Should be $Snapshot.DomainInformation.DomainMode.ToString()
        }
        it "DistinguishedName $($CurrentBaseline.DomainInformation.DistinguishedName)"{
            $CurrentBaseline.DomainInformation.DistinguishedName | Should be $Snapshot.DomainInformation.DistinguishedName
        }
        it "Server $($CurrentBaseline.DomainInformation.RIDMaster) is RIDMaster"{
            $CurrentBaseline.DomainInformation.RIDMaster | Should be $Snapshot.DomainInformation.RIDMaster
        }
        it "Server $($CurrentBaseline.DomainInformation.PDCEmulator) is PDCEmulator"{
            $CurrentBaseline.DomainInformation.PDCEmulator | Should be $Snapshot.DomainInformation.PDCEmulator
        }
        it "Server $($CurrentBaseline.DomainInformation.InfrastructureMaster) is InfrastructureMaster"{
            $CurrentBaseline.DomainInformation.InfrastructureMaster | Should be $Snapshot.DomainInformation.InfrastructureMaster
        }
    }

    Context 'Verifying Default Password Policy'{
        it 'ComplexityEnabled'{
            $CurrentBaseline.DefaultPassWordPoLicy.ComplexityEnabled | Should be $true
        }
        it 'Password History count'{
            $CurrentBaseline.DefaultPassWordPoLicy.PasswordHistoryCount | Should be $Snapshot.DefaultPassWordPoLicy.PasswordHistoryCount
        }
        it "Lockout Threshold equals $($CurrentBaseline.DefaultPassWordPoLicy.LockoutThreshold)"{
            $CurrentBaseline.DefaultPassWordPoLicy.LockoutThreshold | Should be $Snapshot.DefaultPassWordPoLicy.LockoutThreshold
        }
        it "Lockout duration equals $($CurrentBaseline.DefaultPassWordPoLicy.LockoutDuration.ToString())"{
            $CurrentBaseline.DefaultPassWordPoLicy.LockoutDuration.ToString() | Should be $Snapshot.DefaultPassWordPoLicy.LockoutDuration.ToString()
        }
        it "Lockout observation window equals $($CurrentBaseline.DefaultPassWordPoLicy.LockoutObservationWindow.ToString())"{
            $CurrentBaseline.DefaultPassWordPoLicy.LockoutObservationWindow.ToString() | Should be $Snapshot.DefaultPassWordPoLicy.LockoutObservationWindow.ToString()
        }
        it "Min password age equals $($CurrentBaseline.DefaultPassWordPoLicy.MinPasswordAge.ToString())"{
            $CurrentBaseline.DefaultPassWordPoLicy.MinPasswordAge.ToString() | Should be $Snapshot.DefaultPassWordPoLicy.MinPasswordAge.ToString()
        }
        it "Max password age equals $($CurrentBaseline.PasswordPolicy.MaxPasswordAge)"{
            $CurrentBaseline.DefaultPassWordPoLicy.MaxPasswordAge.ToString() | Should be $Snapshot.DefaultPassWordPoLicy.MaxPasswordAge.ToString()
        }
    }

    Context 'Verifying Active Directory Subnets'{
        $CurrentBaseline.Subnets | 
        ForEach-Object{
            it "Subnet $($_)" {
                $Snapshot.Subnets.Name.Contains($_) | Should be $true
            }
        } 
    }
}