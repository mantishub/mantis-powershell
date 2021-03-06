using namespace System.Web.Http;

<# 
 .Synopsis
  Get one or more issues from Mantis.

 .Description
  Gets a paginated list of issues or a specific issue.

 .Parameter Id
  The issue id, if it is desired to retrieve a specific issue

 .Parameter page
  The page number to retrieve when retrieving multiple issues.

 .Parameter page
  The page size used for batching of issue retrieval.

 .Example
   # Get a specific issue
   Get-MantisIssue -Id 100

 .Example
   # Get first page of issues
   Get-MantisIssue

 .Example
   # Get second page of issues
   Get-MantisIssue -page 2

 .Example
   # Get second page of issues with custom page size
   Get-MantisIssue -page 2 -pageSize 50

 .Example
   # Get multiple issues
   @(1, 2, 3) | Get-MantisIssue
#>
function Get-MantisIssue {
param(
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [int] $id,
    [int] $page,
    [int] $pageSize
  )
  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
  
    # Handle getting a batch of issues
    if( -not $PSBoundParameters.ContainsKey( "page" ) ) {
      $page = 1
    }

    if( -not $PSBoundParameters.ContainsKey( "pageSize" ) ) {
      $pageSize = 25
    }
  }

  Process {
    # Handle getting a single issue
    if( $id -ne 0 ) {
      $uri = $instance.uri + "issues/" + $id
      $result = Invoke-RestMethod -Uri $uri -Headers $headers
      Write-Output $result.issues[0]
    } else {
      $uri = $instance.uri + "issues/?page=" + $page + "&page_size=" + $pageSize
      $result = Invoke-RestMethod -Uri $uri -Headers $headers
      $result.issues | Write-Output
    }
  }
}

<# 
 .Synopsis
  Initialize an issue object and return it.

 .Description
  Initialize an issue object and return it.

 .Example
   $issue = New-MantisIssue -summary "Test" -description "Test" -project "Mantis" -category "UI"
   $issue.AddCustomField( "SomeField", "value" )
#>
function New-MantisIssue() {
  param (
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [int] $id,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $summary,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $description,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $project,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $category,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $priority,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $severity,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $reproducibility,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $status,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $resolution,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $projection,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $eta,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $os,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $osBuild,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $platform,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $reporter,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $handler,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $version,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $fixedInVersion,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $targetVersion,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $additionalInformation,
    [parameter(ValueFromPipelineByPropertyName)]
    [string] $stepsToReproduce,
    [parameter(ValueFromPipelineByPropertyName)]
    [Hashtable] $customFields
  )

  Process {
    $issue = @{}

    if( $PSBoundParameters.ContainsKey( "id" ) ) {
      $issue.id = $id;
    }

    if( $PSBoundParameters.ContainsKey( "summary" ) ) {
      $issue.summary = $summary;
    }

    if( $PSBoundParameters.ContainsKey( "description" ) ) {
      $issue.description = $description;
    }

    if( $PSBoundParameters.ContainsKey( "project" ) ) {
      $issue.project = @{ "name" = $project }
    }

    if( $PSBoundParameters.ContainsKey( "category" ) ) {
      $issue.category = @{ "name" = $category }
    }

    if( $PSBoundParameters.ContainsKey( "reporter" ) ) {
      $issue.reporter = @{ "name" = $reporter }
    }

    if( $PSBoundParameters.ContainsKey( "handler" ) ) {
      $issue.handler = @{ "name" = $handler }
    }

    if( $PSBoundParameters.ContainsKey( "priority" ) ) {
      $issue.priority = @{ "name" = $priority }
    }

    if( $PSBoundParameters.ContainsKey( "severity" ) ) {
      $issue.severity = @{ "name" = $severity }
    }

    if( $PSBoundParameters.ContainsKey( "reproducibility" ) ) {
      $issue.reproducibility = @{ "name" = $reproducibility }
    }

    if( $PSBoundParameters.ContainsKey( "status" ) ) {
      $issue.status = @{ "name" = $status }
    }

    if( $PSBoundParameters.ContainsKey( "resolution" ) ) {
      $issue.resolution = @{ "name" = $status }
    }

    if( $PSBoundParameters.ContainsKey( "projection" ) ) {
      $issue.projection = @{ "name" = $projection }
    }

    if( $PSBoundParameters.ContainsKey( "eta" ) ) {
      $issue.eta = @{ "name" = $eta }
    }

    if( $PSBoundParameters.ContainsKey( "os" ) ) {
      $issue.os = $os
    }

    if( $PSBoundParameters.ContainsKey( "osBuild" ) ) {
      $issue.os_build = $osBuild
    }

    if( $PSBoundParameters.ContainsKey( "platform" ) ) {
      $issue.platform = $platform
    }

    if( $PSBoundParameters.ContainsKey( "version" ) ) {
      $issue.version = @{ name = $version }
    }

    if( $PSBoundParameters.ContainsKey( "fixedInVersion" ) ) {
      $issue.fixed_in_version =  @{ "name" = $fixedInVersion }
    }

    if( $PSBoundParameters.ContainsKey( "targetVersion" ) ) {
      $issue.target_version =  @{ "name" = $targetVersion }
    }

    if( $PSBoundParameters.ContainsKey("additionalInformation") ) {
      $issue.additional_information = $additionalInformation
    }

    if( $PSBoundParameters.ContainsKey("stepsToReproduce") ) {
      $issue.steps_to_reproduce = $stepsToReproduce
    }

    if( $PSBoundParameters.ContainsKey("customFields") ) {
      $issue.custom_fields = @()
      foreach ( $current in $customFields.GetEnumerator() ) {
        Write-Host $current

        $name = $current.Name
        $value = $current.Value

        $custom_field = @{}
        $custom_field.field = @{ name = $name }
        $custom_field.value = $value

        $issue.custom_fields += $custom_field
      }
    }

    $issue = New-Object PSObject -Property $issue
    Write-Output $issue
  }
}

<# 
 .Synopsis
  Add an issue to Mantis

 .Description
  Add an issue to Mantis

 .Example
   $issue | Add-MantisIssue

 .Example
   Add-MantisIssue $issue
#>
function Add-MantisIssue() {
  param(
    [parameter(ValueFromPipeline)]
    $issue
  )

  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
    $headers["Content-Type"] = "application/json"
    $uri = $instance.uri + "issues/"
  }

  Process {
    $body = $issue | ConvertTo-Json -Depth 100
    $result = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    $result.issue
  }
}

<# 
 .Synopsis
  Update an issue.

 .Description
  Update an issue.

 .Example
  @(1, 5, 10) | New-MantisIssue -handler "vboctor" -status "assigned" | Edit-MantisIssue

 .Example
  # Assign issue 1 to "vboctor"
  New-MantisIssue -id 1 -handler "vboctor" -status "assigned" | Edit-MantisIssue

 .Example
  # Batch edit multiple issues to assign to "vboctor"
  Get-MantisIssue -page 1 -pageSize 5 | New-MantisIssue -handler "vboctor" -status "assigned" | Edit-MantisIssue
#>
function Edit-MantisIssue {
  param(
    [parameter(ValueFromPipeline)]
    $issue,
    [parameter(ValueFromPipelineByPropertyName)]
    $id
  )

  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
    $headers["Content-Type"] = "application/json"
  }

  Process {
    $uri = $instance.uri + "issues/" + $id
    $body = $issue | ConvertTo-Json -Depth 100
    $result = Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $body
    Write-Output $result.issues[0]
  }
}

<#
 .Synopsis
  Delete an issue.

 .Description
  Delete an issue.

 .Example
  Remove-MantisIssue -id 1

 .Example
  Remove-MantisIssue 1

 .Example
  Get-MantisIssue 1 | Remove-MantisIssue

 .Example
  @(1, 2, 3) | Remove-MantisIssue
#>
function Remove-MantisIssue {
  param (
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [int] $id
  )

  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
  }

  Process {
    $message = "Deleting issue " + $id
    Write-Verbose $message
    $uri = $instance.uri + "issues/" + $id
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers
  }
}

<#
 .Synopsis
  Get information about logged in user.

 .Description
  Get information about logged in user.

 .Example
   Get-MantisUser -me
#>
function Get-MantisUser {
  param(
    [Switch]
    $me
  )
  $instance = getInstance
  $headers = getCommonHeaders

  $uri = $instance.uri + "users/me"

  $result = Invoke-RestMethod -Uri $uri -Headers $headers
  return $result
}

<#
 .Synopsis
  Get Mantis Version.

 .Description
  Get Mantis Version.

 .Example
   Get-MantisVersion
#>
function Get-MantisVersion {
  $instance = getInstance
  $headers = getCommonHeaders

  $uri = $instance.uri + "users/me"

  $result = Invoke-RestMethod -Uri $uri -Headers $headers -ResponseHeadersVariable 'responseHeaders'

  return $responseHeaders["X-Mantis-Version"]
}

<#
 .Synopsis
  Get config option value.

 .Description
  Get config option value.  If multiple values are supplied via pipeline, a single
  request will be issued to Mantis to retireve all of them.

  Note that configs of special types like enumerations (e.g. status) are returned in a
  structured format.

 .Example
  # Get a single config option
  Get-MantisConfig webmaster_email

 .Example
  # Get multiple configs in one call to Mantis
  @("status_enum_string", "priority_enum_string") | Get-MantisConfig

 .Example
  # Get multiple configs and dump them to a json file
  @("status_enum_string", "priority_enum_string") | Get-MantisConfig | ConvertTo-Json -Depth 100 | Out-File config.json
#>
function Get-MantisConfig {
  param(
    [parameter(ValueFromPipeline)]
    [string] $name
  )
  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
    $uri = $instance.uri + "config?"
    $count = 0
  }

  Process {
    $uri += "option[]=" + $name + "&"
    $count++
  }

  End {
    if( $count -ne 0 ) {
      $result = Invoke-RestMethod -Uri $uri -Headers $headers
      $result.configs | Write-Output;
    }
  }
}

<#
 .Synopsis
  Get localized strings in language for logged in user.

 .Description
  If multiple values are supplied via pipeline, a single
  request will be issued to Mantis to retireve all of them.

 .Example
  # Get a single string
  Get-MantisString login_anonymously

 .Example
  # Get multiple strings in one call to Mantis
  @("login_anonymously", "anonymous") | Get-MantisString

 .Example
  # Get multiple strings and dump them to a json file
  @("login_anonymously", "anonymous") | Get-MantisString | ConvertTo-Json -Depth 100 | Out-File lang.json
#>
function Get-MantisString {
  param(
    [parameter(ValueFromPipeline)]
    [string] $name
  )
  Begin {
    $instance = getInstance
    $headers = getCommonHeaders
    $uri = $instance.uri + "lang?"
    $count = 0
  }

  Process {
    $uri += "string[]=" + $name + "&"
    $count++
  }

  End {
    if( $count -ne 0 ) {
      $result = Invoke-RestMethod -Uri $uri -Headers $headers
      $result.strings | Write-Output;
    }
  }
}

<#
 .Synopsis
  Get all projects accessible to logged in user.

 .Description
  Get all projects accessible to logged in user.

 .Example
  # Get projects accessible to logged in user
  Get-MantisProject
#>
function Get-MantisProject {
    $instance = getInstance
    $headers = getCommonHeaders
    $uri = $instance.uri + "projects"
    $result = Invoke-RestMethod -Uri $uri -Headers $headers
    $result.projects | Write-Output
}

<#
 .Synopsis
  Select Mantis instance to connect to.

 .Description
  The name specified should match a config file at `~/.mantis.<name>.json`.

 .Example
  # Use Mantis Office Bugtracker
  Use-MantisInstance mantisbt

  # Use work bug tracker for acme
  Use-MantisInstance acme
#>
function Use-MantisInstance {
  param(
    $instance
  )

  $source = "~/.mantis." + $instance + ".json"
  $destination = "~/.mantis.json"

  Copy-Item -Path $source -Destination $destination
}

#
# Helper Functions
#

function getCommonHeaders {
  $headers = @{
    "User-Agent" = "MantisPowerShell"
  }

  # Anonymous access instances won't have a token, so check before
  # attempting to add the header.
  if( ($instance.PSobject.Properties.name -match "token") ) {
    $headers["Authorization"] = $instance.token
  }

  return $headers
}

function getInstance() {
  $instance = Get-Content -Raw -Path ~/.mantis.json | ConvertFrom-Json
  $instance.uri = $instance.uri + "api/rest/"
  return $instance
}

#
# Module Exports
#

export-modulemember -function Get-MantisIssue
export-modulemember -function New-MantisIssue
export-modulemember -function Add-MantisIssue
export-modulemember -function Edit-MantisIssue
export-modulemember -function Remove-MantisIssue
export-modulemember -function Get-MantisUser
export-modulemember -function Get-MantisProject
export-modulemember -function Get-MantisConfig
export-modulemember -function Get-MantisString
export-modulemember -function Get-MantisVersion
export-modulemember -function Use-MantisInstance
