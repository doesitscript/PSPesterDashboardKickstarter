[CmdletBinding()]
param (
    [string]$AppSuiteTitle   = "My Immutable Infrastructure",
    [string]$AppSuiteVersion = "1.0",
    [switch]$NewBaseline,      # leaving null to use mocked data to generate report
    [switch]$SkipGenReport     # only ouput Pester results
)

# Requires: ActiveDirectory, Pester
Import-Module -Name ActiveDirectory,Pester

#Paths to Tests, Outputs, and Reports
$ScriptPath       = Resolve-Path -Path "$PSScriptRoot"
$ReportsPath      = Join-Path -Path $ScriptPath -ChildPath "OperationalReports"
$BaselinePath     = Join-Path -Path $ScriptPath -ChildPath "OperationalBaselines"
$BaseLineOutPath  = if ($NewBaseline) { Join-Path -Path $BaselinePath -ChildPath "FreshBaselines" } else { Join-Path -Path $BaselinePath -ChildPath "MockBaseLines" }
$BaseSnapshotPath = if ($NewBaseline) { Join-Path -Path $BaselinePath -ChildPath "Snapshots" } else { Join-Path -Path $BaselinePath -ChildPath "MockSnapshots" }
$PesterTestsPath  = Join-Path -Path $ScriptPath -ChildPath "PesterTests"

# Represents the servers required to make my immutable infrastructure. Could have used an array but going for legibility.
$SQ01 = "DSSQ01" # SQL Server.
$MG01 = "DSMG01" # MDT Server. Pull Server.
$MG02 = "DSMG02" # MDT Svr02
$WB03 = "DSWB03" # Web Server.
$DC02 = "DSDC02" # Domain Controller
$DC01 = "DSDC01" # Domain Controller

# Establish remote session with the servers/applications that make up the suite
if ($NewBaseline) {
    $DC02Sess = New-PSSession -ComputerName $DC02
    $SQ01Sess = New-PSSession -ComputerName $SQ01 
    $MG01Sess = New-PSSession -ComputerName $MG01 
    $WB03Sess = New-PSSession -ComputerName $WB03
} # end if NewBaseline

# Generate fresh baseline data, else use mocked up baselines
$files = @()
if ($NewBaseline) {
    $Job = $MG01,$MG02,$DC02,$DC01 | foreach {
        $NodeType = $($_.Substring(2,2))
        $thisSess = Get-Variable $($NodeType + "Sess") -ValueOnly
        Invoke-Command -Session $thisSess -FilePath $BaselinePath\$($_.Substring(2,2)).Snapshot.ps1 -AsJob
    }
    
    $Results = Receive-Job -Wait -Job $Job

    $Results | foreach {
        Export-Clixml -InputObject $_ -Path $BaseLineOutPath\$($_.PSComputerName).xml -Force
        $files += Get-ChildItem (Join-Path -Path $BaseLineOutPath -ChildPath "$($_.PSComputerName).Baseline.xml")
    }
} else {
    $MG01,$MG02,$DC02,$DC01  | foreach {
        $files += Get-ChildItem (Join-Path -Path $BaseLineOutPath -ChildPath "$($_).Baseline.xml")
    }
} # end if NewBaseline 

# Use xml data from baseline to invoke matching Pester Test
$files | foreach {
    $NodeName         = $_.BaseName.Substring(0,6)
    $NodeRole         = $_.BaseName.Substring(2,2)
    $NodeUnitTestFile = Join-Path -Path $PesterTestsPath -ChildPath "NodeUnitTests\$NodeName.Operations.Tests.ps1"
    $NodeBaseSnapshot = Join-Path -Path $BaseSnapshotPath -ChildPath "$($NodeName).Baseline.xml"
    $RoleTestTemplate = Join-Path -Path $PesterTestsPath -ChildPath "TestTemplates\$($NodeRole).Operations.Tests.ps1"
    $paramPester      = @{
        Script        = $NodeUnitTestFile
        OutputFile    = "$PesterTestsPath\NUnitXML\$NodeName.Results.xml"
        OutputFormat  = "NUnitXml"
    }

    # Hard code xml baseline & xml snapshot *.test file when using Invoke-Pester. Better suggestion?
    ((Get-Content -Path $RoleTestTemplate ) -replace "#BaseSnapshotPath#","'$($_.Fullname)'" ) `
                                            -replace "#BaseLineOutPath#","'$($NodeBaseSnapshot)'" |
                                             Out-File -FilePath $NodeUnitTestFile -Encoding utf8 -Force

    Invoke-Pester @paramPester 
} # end foreach xml

# Compile Unit tests
if (-not $SkipGenReport) {
    $paramSuite = @{
        OutputFolder          = $ReportsPath
        NUnitTestsFolder      = "$PesterTestsPath\NUnitXML"
        AppSuiteTitle         = $AppSuiteTitle 
        AppSuiteVersion       = $AppSuiteVersion
    }
    . "$ScriptPath\Invoke-SuiteReport.ps1" @paramSuite

    # Navigate to Reports path
    explorer $ReportsPath
}