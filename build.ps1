#!/usr/bin/env -S pwsh -NoProfile

Using Namespace System.IO

[CmdletBinding(SupportsShouldProcess)]
param
(
    [Parameter()]
    [ValidateSet('Build', 'Deploy')]
    [string] $Target = 'Build'
)

Set-StrictMode -Version Latest

$ProjectName = 'rally-dark-theme'

$RootDir = $PSScriptRoot

$BuildDir = Join-Path $RootDir 'build'
$DistDir = Join-Path $RootDir 'dist'
$SrcDir = Join-Path $RootDir 'src'

$DocumentInfo = @{
    domain = "rallydev.com"
}

$Artifacts = @{
    Mozilla = (Join-Path $BuildDir 'mozilla' "${ProjectName}.user.css")
}


function CleanStep
{
    @($BuildDir, $DistDir) | Remove-Item -Recurse -ErrorAction Ignore
}

function Write-MozillaContent
{
    param
    (
        [Parameter(Mandatory)]
        [string[]] $Header,

        [Parameter(Mandatory)]
        [Hashtable] $DocumentInfo,

        [Parameter(Mandatory)]
        [FileInfo[]] $Files
    )

    Write-Output $Header

    $DocHeader = '{'
    $DocIndent = '    '
    $DocFooter = '}'

    if ($DocumentInfo.Domain)
    {
        $DocHeader = "@moz-document domain(`"$($DocumentInfo.Domain)`") {"
    }
    else
    {
        Write-Error -Category NotImplemented "For document info:`n$($DocumentInfo | Out-String)"
        return
    }


    $Files | ForEach-Object {
        # 01-colors => colors
        $DocName = $_.BaseName -creplace '^(\d+-)', ''

        Write-Output $DocHeader

        Write-Output "${DocIndent}/*"
        Write-Output "${DocIndent} * ${DocName}"
        Write-Output "${DocIndent} */"
        $_ | Get-Content | ForEach-Object { $DocIndent + $_ }

        Write-Output $DocFooter
    }

}

function BuildStep
{
    mkdir ($Artifacts.Values | Split-Path) | Out-Null

    $HeaderPath = Join-Path $SrcDir 'header.css'
    $SectionsDir = Join-Path $SrcDir 'sections'

    $Header = Get-Content -LiteralPath $HeaderPath

    $SectionFiles = Get-ChildItem -LiteralPath $SectionsDir -Include '*.css'

    Write-MozillaContent -Header $Header -DocumentInfo $DocumentInfo -Files $SectionFiles | Out-File -LiteralPath $Artifacts.Mozilla
}

function DistStep
{
    mkdir $DistDir
    Copy-Item -LiteralPath $Artifacts.Values -Destination $DistDir
}

function Build()
{
    CleanStep
    BuildStep
}

function Dist()
{
    Build
    DistStep
}



& $Target