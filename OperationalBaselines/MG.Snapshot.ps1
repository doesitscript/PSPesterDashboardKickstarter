[cmdletbinding()]
Param(
    #[string]$ComputerName  # run via invoke-command
)

#Import-Module Import-Module "E:\Program Files\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
Add-PSSnapin microsoft.bdd.pssnapin
New-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "e:\MDTBuildLab" -Description "MDT Deployment Share" -NetworkPath "\\DSMG01\MDTDeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose

#Get-Command -PSSnapin microsoft.bdd.pssnapin

#HashTable to save Management Server Report
$MDTSnapshot = @{}

#region Main
$MDTSnapshot.MonitorData     = Test-MDTMonitorData -ServerName localhost -DataPort 9801 -EventPort 9800   # should be $true
$MDTSnapshot.ShareStatistics = Get-MDTDeploymentShareStatistics -Path DS002:                              
$MDTSnapshot.DeploymentShare = Test-MDTDeploymentShare -SourcePath
#endregion

Write-Output $MDTSnapshot | Export-Clixml -Path c:\Out.xml

