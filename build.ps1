using namespace System.IO

[CmdletBinding()]
param
(
    [ValidateSet('clean', 'build', 'rebuild')]
    $Target = 'build'
)

function Resolve-Version
{
    if ($minver = Get-Command 'minver')
    {
        return & $minver -ve
    }

    throw "Version not resolved"
}

function Ensure-Directory
{
    param([string] $LiteralPath, [switch] $PassThru)

    $dir = Get-Item -ErrorAction Ignore -LiteralPath $LiteralPath
    if (!$dir)
    {
        $dir = mkdir -Path $LiteralPath
    }


    if ($PassThru)
    {
        return $dir
    }
}

function Get-CssHeader($name, $namespace, $version, $description, $author, $license)
{
    @"
/* ==UserStyle==
@name           $name
@namespace      $namespace
@version        $version
@description    $description
@author         $($author -join ', ')
@license        $license
==/UserStyle== */
"@
}

[string] $Indent = ''

function Enter-Domain([FileSystemInfo[]] $LiteralPath, [string[]] $domains)
{


    $strDomains = ($domains | ForEach-Object { 'domain("{0}")' -f $_ }) -join ', '
    "@-moz-document $strDomains {"
    $Script:Indent = '    '
    "${Indent}/* {0} */" -f (($LiteralPath | ForEach-Object { [Path]::GetRelativePath($src, $_) -creplace '[\\/]', '/' }) -join ',' )
}

function Exit-Domain([string[]] $domains)
{
    '}'
    ''
    $Script:Indent = ''
}

function Get-CssFileContent
{
    param
    (
        [Parameter(Position=0,Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [FileSystemInfo[]] $LiteralPath
    )

    process
    {
        Enter-Domain -LiteralPath $LiteralPath -Domains $domains
        try
        {
            (Get-Content -LiteralPath:$LiteralPath) -creplace '^', $Indent
        }
        finally
        {
            Exit-Domain $domains
        }

    }
}

function Get-CssContent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,Mandatory,ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [FileSystemInfo[]] $LiteralPath
    )
    
    begin
    {
        Get-CssHeader @header
    }

    process
    {
        $LiteralPath | Get-ChildItem -Recurse -File | Get-CssFileContent
    }
}

#
# TARGETS
#

function clean()
{
    Remove-Item -Recurse -ErrorAction Ignore -LiteralPath $dist
}

function build()
{
    Ensure-Directory $dist

    $Common = Get-ChildItem -LiteralPath $src -Include '*.css' -File

    $themesDir = Join-Path $src 'themes'
    Get-ChildItem -LiteralPath $themesDir | ForEach-Object {
        $dstFile = Join-Path $dist ([Path]::ChangeExtension($_.Name, '.user.css'))

        $_, $Common | Get-CssContent | Set-Content $dstFile
    }
}



function rebuild()
{
    clean
    build
}

#
# VARS
#
$header = @{
    name = 'Rally Dark Mode'
    namespace = 'github.com/openstyles/stylus'
    version = Resolve-Version
    description = "Dark Theme for CA Technologies' Rally AgileThis theme is a work-in-progress for the new Rally theme based on Bootstrap"
    author = 'cdonnelly@69bytes.com', 'steeltomato'
    license = 'CC0-1.0'

}

$root = $PSScriptRoot
$src = Join-Path $root 'src'
$dist = Join-Path $root 'dist'

$domains = @('rallydev.com')

#
# MAIN
#

& $target