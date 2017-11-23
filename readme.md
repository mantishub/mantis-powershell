# Mantis PowerShell

## Demo

[![asciicast](https://asciinema.org/a/2vOZtWFW69bvOZ82Br8AEPQqw.png)](https://asciinema.org/a/2vOZtWFW69bvOZ82Br8AEPQqw)

## Works with

Mantis Versions:
- [MantisBT](https://www.mantisbt.org): v2.8.0 or above.
- [MantisHub](https://www.mantishub.com)

Operating Systems (all supported by PowerShell Core):
- Mac OS X
- Windows
- Linux

## Install PowerShell Core

- [Install PowerShell](https://github.com/PowerShell/PowerShell)
- [Customize PowerShell Colors on Mac](https://info.sapien.com/index.php/quickguides/setting-up-powershell-on-your-mac)

## Download MantisPowershell

Download [Mantis PowerShell Release](https://github.com/mantishub/mantis-powershell/releases/)

## Create an API token via Mantis UI

Create API Token as per the following [article](https://support.mantishub.com/hc/en-us/articles/206640376-Using-API-Tokens-to-access-MantisHub).

## Import Mantis Module

Load Mantis PowerShell module in an open PowerShell terminal:

    Import-Module ./mantis.psm1

## Create Login Credentials File

Create `~/.mantis.companyname.json` with contents like the one below including the appropriate URL and logical
name for the instance.

Example for authenticated instance:
```json
{
  "uri": "https://companyname.com/mantisbt/",
  "token": "YjQlU7OI0D..........sWC1vGaAuq3Q"
}
```

Example for anonymous access
```json
{
  "uri": "https://companyname.com/mantisbt/"
}
```

Select the instance for all future commands:

    Use-MantisInstance companyname

Note that the selected instance will be persisted on disk, hence, it will persist across PowerShell
restarts.  This is done by copying `.mantis.company.json` to `.mantis.json`.  So if the configuration
is changed, re-run the command `Use-MantisInstance`.

## Get Mantis Version

    Get-MantisVersion

## Get Logged In User Info

    Get-MantisUser -me

## Getting Projects

Get projects accessible to logged in user:

    Get-MantisProject

## Creating an issue

    $issue = New-MantisIssue -summary "summary" -description "desc" -handler "vboctor" -project "mantisbt" -category "ui" -version "2.8.0" -priorty "high"
    $issue | Add-MantisIssue

## Importing a CSV file

Sample File (`sample.csv`)

    "project", "category", "summary", "description"
    "mantisbt", "ui", "test csv 1", "test csv 1"
    "mantisbt", "ui", "test csv 2", "test csv 2"

Importing the file

    Import-Csv -Path ./sample.csv | New-MantisIssue | Add-MantisIssue 

## Creating an issue with custom fields

    $issue = New-MantisIssue -summary "summary" -description "desc" -project "mantisbt" -category "ui" -customFields @{ "The City" = "Seattle", "Root Cause" = "Code Bug" }
    $issue | Add-MantisIssue

## Getting an issue by Id

    Get-MantisIssue 1

## Getting multiple issues by id

    @(1, 2, 3) | Get-MantisIssue

## Get issue history by id

    $issue = Get-MantisIssue 1
    $issue.history

## Getting issues

Get the first page of issues with default page size:

    Get-MantisIssue

Get a specific page and page size:

    Get-MantisIssue -page 5 -pageSize 50

## Updating Issues

Assign issue `1` to `vboctor`

    New-MantisIssue -id 1 -handler "vboctor" -status "assigned" | Edit-MantisIssue

Assign a set of issues to `vboctor`

    @(1, 5, 10) | New-MantisIssue -handler "vboctor" -status "assigned" | Edit-MantisIssue

Assign a batch of issues to `vboctor`

    Get-MantisIssue -page 1 -pageSize 5 | New-MantisIssue -handler "vboctor" -status "assigned" | Edit-MantisIssue

## Deleting an issue

Delete an issue via its id

    Remove-MantisIssue 1

Delete an issue via ids on pipeline

    @(1, 2, 3) | Remove-MantisIssue

Delete an issue via issue on pipeline

    Get-MantisIssue 1 | Remove-MantisIssue

## Exporting an issue as a Json file

    Get-MantisIssue 1 | ConvertTo-Json -Depth 100 | Out-File issue000001.json

## Getting config options

Retrieve a single config option:

    Get-MantisConfig webmaster_email

Retrieve multiple config options in one call to Mantis:

    @("status_enum_string", "priority_enum_string") | Get-MantisConfig

Retrieve multiple config options and dumping them to an `config.json` file:

    @("status_enum_string", "priority_enum_string") | Get-MantisConfig | ConvertTo-Json -Depth 100 | Out-File config.json

## Getting localized strings

Get a single string

    Get-MantisString login_anonymously

Get multiple strings in one call to Mantis

    @("login_anonymously", "anonymous") | Get-MantisString

Get multiple strings and dump them to a json file

    @("login_anonymously", "anonymous") | Get-MantisString | ConvertTo-Json -Depth 100 | Out-File lang.json