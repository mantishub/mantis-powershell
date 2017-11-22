# Mantis PowerShell

## Works with

- MantisBT: v2.8.0 or above.
- MantisHub

## Install PowerShell Core

[Install PowerShell](https://github.com/PowerShell/PowerShell)

## Import Mantis Module

Load Mantis PowerShell module in an open PowerShell terminal:

```
Import-Module ./mantis.psm1
```

## Get Mantis Version

```
Get-MantisVersion
```

## Create an API token via Mantis UI

Create API Token as per the following [article](https://support.mantishub.com/hc/en-us/articles/206640376-Using-API-Tokens-to-access-MantisHub).

## Create Login Credentials File

Create `~/.mantis.json` with contents like the one below and place the token in the appropriate field:

```json
{
  "uri": "http://localhost/mantisbt/",
  "token": "YjQlU7OI0D..........sWC1vGaAuq3Q"
}
```

### Get Logged In User Info

```
Get-MantisUser
```

## Creating an issue

```
$issue = New-MantisIssue -summary "summary" -description "desc" -handler "vboctor" -project "mantisbt" -category "ui" 
$issue.AddCustomField( "The City", "Seattle" )
$issue | Add-MantisIssue
```

### Getting an issue by Id

```
Get-MantisIssue 1
```

## Get issue history by id

```
$issue = Get-MantisIssue 1
$issue.history | ForEach-Object -Process { Write-Output $_ }
```

### Getting issues

```
Get-MantisIssue
```

### Getting a config option

```
Get-MantisConfig webmaster_email
```
