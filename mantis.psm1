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
#>
function Get-MantisIssue {
param(
    [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [int] $id,
    [int] $page,
    [int] $pageSize
  )

  $instance = getInstance
  $headers = getCommonHeaders

  # Handle getting a single issue
  if( $id -ne 0 ) {
    $uri = $instance.uri + "issues/" + $id
    $result = Invoke-RestMethod -Uri $uri -Headers $headers
    return $result.issues[0]
  }

  # Handle getting a batch of issues
  if( -not $PSBoundParameters.ContainsKey( "page" ) ) {
    $page = 1
  }

  if( -not $PSBoundParameters.ContainsKey( "pageSize" ) ) {
    $pageSize = 25
  }

  $uri = $instance.uri + "issues/?page=" + $page + "&page_size=" + $pageSize
  $result = Invoke-RestMethod -Uri $uri -Headers $headers
  return $result.issues
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
    [string] $summary,
    [string] $description,
    [string] $project,
    [string] $category,
    [string] $priority,
    [string] $severity,
    [string] $reproducibility,
    [string] $status,
    [string] $resolution,
    [string] $projection,
    [string] $eta,
    [string] $os,
    [string] $osBuild,
    [string] $platform,
    [string] $reporter,
    [string] $handler,
    [string] $version,
    [string] $fixedInVersion,
    [string] $targetVersion,
    [string] $additionalInformation,
    [string] $stepsToReproduce,
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

  $instance = getInstance

  $headers = getCommonHeaders
  $headers["Content-Type"] = "application/json"

  $uri = $instance.uri + "issues/"
  $body = $issue | ConvertTo-Json -Depth 100
  $result = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body

  return $result.issue
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
   Get-MantisUser
#>
function Get-MantisUser {
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

#
# Helper Functions
#

function getCommonHeaders {
  $headers = @{
    "Authorization" = $instance.token
    "User-Agent" = "MantisPowerShell"
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
export-modulemember -function Get-MantisConfig
export-modulemember -function Get-MantisVersion
