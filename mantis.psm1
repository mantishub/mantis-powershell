using namespace System.Web.Http;

<# 
 .Synopsis
  Get one or more issues from Mantis.

 .Description
  Gets a paginated list of issues or a specific issue.

 .Parameter Id
  The issue id, if it is desired to retrieve a specific issue

 .Example
   # Get a paginated list of issues
   Get-MantisIssue

 .Example
   # Get a specific issue
   Get-MantisIssue -Id 100
#>
function Get-MantisIssue {
param(
    [int] $id = 0
  )

  $instance = getInstance
  $headers = getCommonHeaders

  if( $id -eq 0 ) {
    $uri = $instance.uri + "issues/"
    $result = Invoke-RestMethod -Uri $uri -Headers $headers
    return $result.issues
  }

  $uri = $instance.uri + "issues/" + $id
  $result = Invoke-RestMethod -Uri $uri -Headers $headers
  return $result.issues[0]
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

  $issue = @{}

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

  return $issue
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
  Get config option value.

 .Example
   Get-MantisConfig webmaster_email
#>
function Get-MantisConfig {
param(
    [string] $name
  )

  $instance = getInstance
  $headers = getCommonHeaders

  $uri = $instance.uri + "config?option[]=" + $name
  $result = Invoke-RestMethod -Uri $uri -Headers $headers
  return $result.configs[0];
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
export-modulemember -function Get-MantisUser
export-modulemember -function Get-MantisConfig
export-modulemember -function Get-MantisVersion
