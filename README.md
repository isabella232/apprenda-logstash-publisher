# Apprenda Logstash Publisher
This application represents a possible solution to publish apprenda logs to 
logstash.  It is based on guidance [provided by Apprenda for integrating with Splunk](https://github.com/Apprenda/Splunk).

# Building the source
## Prerequisites
### Automatic Installation

<div style="border: solid 1px red; background-color: #ffe6e6; color: black; padding: 10px">
<h4>Warning</h4>
You must run this from a Powershell window with administrative privleges.  Also, be sure that your <a href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_execution_policies">execution policy</a> is overly restrictive to build the code.  Bypass execution policy is sufficient to work with this product.

Also, the test scripts in the product leverage Docker and has been tested with Docker for Windows.  This version of docker has [signficant installation requirements](https://docs.docker.com/docker-for-windows/install/#what-to-know-before-you-install).  This product may also be used with the legacy desktop solution, [Docker Toolbox](https://docs.docker.com/toolbox/overview/), but that configuration is not covered in this document.
</div>

You may build and install prerequisites by hand or use the provided script in [tools/Install-Prerequisites.ps1](blob/master/tools/Install-Prerequisites.ps1)

This script will:
* Download and install the Apprenda SDK if it's not installed.
* Download the [prerequisite powershell library](https://github.com/jasonvanbrackel/powershell)
* Install the preprequisite powershell library as Powershell-JvB
* Import the Powershell-JvB module into the current powershell session.
* Install [chocolatey](https://chocolatey.org) if it's not installed
* Install [MsBuild via chocolatey](https://chocolatey.org/packages/microsoft-build-tools)
* Install [Docker for Windows via chocolatey](https://chocolatey.org/packages/docker-for-windows)  or Install [Docker Toolbox via chocolatey](https://chocolatey.org/packages/docker-toolbox)


```powershell
# From the working directory
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./tools/Install-Prerequisites.ps1
```

### Apprenda SDK
The [Apprenda SDK](https://docs.apprenda.com/downloads#tools) is a dependency to build this project.

### Powershell Library
The build scripts developed for this application rely upon the powershell library available at [https://github.com/jasonvanbrackel/powershell](https://github.com/jasonvanbrackel/powershell).  

### MSBuild 
There are also prerequisites on [MSBuild](https://github.com/Microsoft/msbuild).  MSBuild is used by the scripts to build the various Visual Studio Solution files.

### Docker
[Docker](https://www.docker.com) and [Docker Compose](https://github.com/docker/compose) are used to test the log forwarding service to standup a local [Elastic Stack](https://www.elastic.co/products)

## Building
Once the prerequisites are installed. Run the [tools/Build-LogstashArchives.ps1](blob/master/tools/Build-LogstashArchives.ps1) script.

```powershell
./tools/Build-LogstashArchives.ps1
```

This will create logstashforwarder.zip and logstashAddOn.zip archives in this folder.

# Installation
## Log Forwarding Service and Logstash AddOn
In order to install and test the binaries you will need an Apprenda Platform (version 6.7 or later) available that is able to communicate to the test Elastic Stack.  [Installation of the Apprenda Platform](http://docs.apprenda.com/current/download) is outside of the scope of this document.

1. Build the archives per the instructions above.
2. Deploy the log forwarding service using the [tools/Deploy-LogForwardingSerivce.ps1](blob/master/tools/Deploy-LogForwardingService.ps1) script.
3. Log into the platform SOC and set the logstash properties for the logstash add-on.  The instructions for doing so are at the end of the Deploy-LogForwardingService.ps1
4. Provision and instance of the add-on and promote the Log forwarding service using the [tools/Promote-LogForwardingService.ps1](blob/master/tools/Promote-LogForwardingService.ps1) script.

```powershell
$apprendaCredentials = Get-Credential
.\tools\Build-LogstashArchives.ps1 -Configuration $Configuration
.\tools\Deploy-LogForwardingService.ps1 -PlatformUrl $PlatformUrl -Username $apprendaCredentials.UserName -Password $apprendaCredentials.GetNetworkCredential().Password -Tenant $Tenant
.\tools\Promote-LogForwardingService.ps1
```

## Logstash Setup
Your logstash configuration will need an input for http.  Https is acceptable as long as the the Apprenda logstash Add-On has been configured to use https and the full certificate chain of trust is verifyable.  Here is the example from the [tools/docker/logstash/pipeline/logstash.conf](blob/master/tools/docker/logstash/pipeline/logstash.conf) file used for testing this product.

```
input {
    http {
        codec => "json"
        host => "0.0.0.0"
        id => "apprenda_http_input"
        port => 10001
        ssl => "false"
        verify_mode => "none"
    }
}
```

# Testing the code
Setting up logstash in docker goes beyond the scope of this document.  [tools/Test-LogForwardingService.ps1](blob/master/tools/Test-LogForwardingService.ps1) can be used to run a test of the code.  As with installing the logstash add-on, there is a manual step of setting up the add-on properties.

```powershell
$apprendaCredentials = Get-Credential
.\tools\Test-LogForwardingService.ps1 -Configuration "Debug" -Step 1 -PlatformUrl $PlatformUrl -Username $apprendaCredentials.UserName -Password $apprendaCredentials.GetNetworkCredential().Password -Tenant $Tenant
.\tools\Test-LogForwardingService.ps1 -Configuration "Debug" -Step 2 -PlatformUrl $PlatformUrl -Username $apprendaCredentials.UserName -Password $apprendaCredentials.GetNetworkCredential().Password -Tenant $Tenant
```


