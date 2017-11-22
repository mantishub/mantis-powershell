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
    $issues = Invoke-RestMethod -Uri $uri -Headers $headers
    return $issues.issues
  }

  $uri = $instance.uri + "issues/" + $id
  $issues = Invoke-RestMethod -Uri $uri -Headers $headers
  return $issues.issues[0]
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
    [string] $reporter,
    [string] $handler,
    [string] $additionalInformation,
    [string] $stepsToReproduce
  )

  $issue = @{}
  $issue.summary = $summary;
  $issue.description = $description;
  $issue.project = @{ "name" = $project }
  $issue.category = @{ "name" = $category }
  $issue.custom_fields = @()

  add-member -in $issue scriptmethod AddCustomField {
      param( [string] $name, [string] $value = "auto" )
    $custom_field = @{}
    $custom_field.field = @{ name = $name }
    $custom_field.value = $value
    $issue.custom_fields += $custom_field
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
