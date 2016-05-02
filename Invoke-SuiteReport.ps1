[CmdletBinding()]
param (
    [string]$OutputFolder,
    [string]$NUnitTestsFolder,
    [string]$AppSuiteTitle,
    [string]$AppSuiteVersion
)

if (-not (Test-Path -Path $OutputFolder )) {New-Item -Path $OutputFolder -ItemType Directory -Force }

& $PSScriptRoot\bin\ReportUnit.exe $NUnitTestsFolder $OutputFolder | Out-Null

$NUnitHtml= Get-ChildItem -Path $OutputFolder -Filter *.html


foreach ($UnitTest in $NUnitHtml) {
    $OutputHTML = "$($UnitTest.BaseName).html"


    [String]$content = Get-Content -Path $OutputFolder\$OutputHTML

    $CSSJSfiles = @{
        Entries = @(
            @{ Name = "materialize.min.css"
               Path = "./cdnjs.cloudflare.com/ajax/libs/materialize/0.97.2/css/materialize.min.css"
            },
            @{ Name = "reportunit.css"
               Path = "./cdn.rawgit.com/reportunit/reportunit/785c3312e42c0650e7882109db9cca4ffae4259f/cdn/reportunit.css"
            },
            @{ Name = "jquery.min.js"
               Path = "./ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"
            },
            @{ Name = "materialize.min.js"
               Path = "./cdnjs.cloudflare.com/ajax/libs/materialize/0.97.2/js/materialize.min.js"
            },
            @{ Name = "Chart.min.js"
               Path = "./cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min.js"
            },
            @{ Name = "reportunit.js"
               Path = "./cdn.rawgit.com/reportunit/reportunit/785c3312e42c0650e7882109db9cca4ffae4259f/cdn/reportunit.js"
            }
        )
    }

    $files = $CSSJSfiles.Entries
    # Replace CSS & JSS Https references with local copies
    foreach ($file in $files) { 
        $name = $file.Name
        $path = $file.Path

        # Create regex to match each file name
        [regex]$regex = "(?<url>('https\://){1}\S+($name)')"

        #Find the exact url formatted path of the current CSS/JS file
        $urlTypePath = $regex.matches($content) | foreach {$_.groups['url'].value}
    
        $content = $regex.Replace($content,$path)
        
        $content = ($content -replace 'ReportUnit TestRunner Report',"$ApplicationSuiteTitle") `
                             -replace 'Executive Summary',"Infrastrcture Test Suite for $ApplicationSuiteTitle" `
                             -replace "v1.50.0","$AppSuiteVersion"

        # Change url format to file format relative to script location
    } # end foreach URL replace

    Out-File -InputObject $content -FilePath "$OutputFolder\$OutputHTML" -Force
    
} # end Foreach unittests