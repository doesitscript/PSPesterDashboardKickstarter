# PowerShell Pester Dashboard Kickstarter

Pester is a Unit Testing framework. While it can be used to test code through mocking, it can also be used to validate anything that can be coded in PowerShell.  Here are some of the features

  - Outputs Pretty + and - to define passes and failures (most common use)
  - Can be used to output a standard NUnit xml file which can be read by many interpreters
  - Can send an error code to the console for further automation

### Goal
Provide a finished HTML dashboard with no setup other than to download and run the main script.  I want you to take this to your boss and show him today that PowerShell can provide immediate buisiness value to your company. 

### Note
There are lots of passing and also lots of failing tests. That is intentional. Won't your boss be so happy when he clicks a failed test and can tell you exactly what you need to fix? Try it!

### Suggested Ways to Start a Release Pipeline
* Run the Invoke-InsfrastructureValidation.ps1 as a sceduled task during the the next maintanence window of your servers and re-run every 15 minutes. 
Direct the output of the reports to an internal webserver for your team or manager to see. 
Near the end of the maintanence windowcapture the return code from Pester and send an email to all parties that the infrastructure is validated healthy by automated checks.
* Replace the Infrastructure unit tests with code unit tests. On every code commit, run the Invoke-InfrastructureValidation.ps1 and direct the web reports to a Web server.  
Have a secondary monitor/tv refresh this page automatically to create a live stream effect.

### Special Thanks

The following individuals & organizations have inspired me in this small project.

* [@migreen] - Michael Greene is a Principal Program Manager at Microsoft in the Enterprise Cloud Group division. Co-Author to the  [ReleasePipeline](https://msdn.microsoft.com/en-us/powershell/dsc/whitepapers#the-release-pipeline-model)
* [@StevenMurawski] - Devops & Chef enthusiast. Co-Author to the  [ReleasePipeline](https://msdn.microsoft.com/en-us/powershell/dsc/whitepapers#the-release-pipeline-model)
* [@ModelAMSummit] - Automation Summit 2016 put on by @ModelTechSol 
* [@adbertram] - For having a beer with me while we talked working on pipelines. Be on the lookout for some of his upcoming Pester work.

### Dependencies
This project makes use of [ReportUnit](http://reportunit.relevantcodes.com/) for reading the NUnit Spec XML from Pester & HTML generation.
It is included in the bin folder and is called during script execution.

* I have found that this runs best with Internet Explorer or Edge. **The reports will not display without ActiveX**

###  In 5 Second, Get-Results 
Option 1: Clone/Download and open OperationalReports\Index.html in IE or Edge.  Profit.
**Enable ActiveX!!**

### Have More Time?  
Option 2: Step through the controller script. 
Its well commented.
You can change the parameters at the top but don't have to.
```PowerShell
. Invoke-InfrastructureValidation.ps1
```
After the script runs, it will dump a suite of reports in the OperationalReports folder. Open Index.html in IE or Edge.

### Development

Want to contribute? Great!
Send me your pull request!  

