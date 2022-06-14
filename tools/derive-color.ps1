using namespace PoshCode.Pansies
using namespace PoshCode.Pansies.ColorSpaces

param
(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNull()]
    [HsbColor] $Light,
    
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNull()]
    [HsbColor] $Dark,
    
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNull()]
    [HsbColor] $Target,

    # Target is dark, not light.
    [switch] $AsDark
)

begin
{
    if ($AsDark) { throw [NotImplementedException]::new() }
}

process
{
    $hdiff = $Dark.H - $Light.H
    $hratio = $Dark.H / $Light.H
    $sdiff = $Dark.S - $Light.S
    $sratio = $Dark.S / $Light.S
    $bdiff = $Dark.B - $Light.B
    $bratio = $Dark.B / $Light.B

    # [Hsb]::new(
    #     $Target.H + $hdiff,
    #     $Target.S + $sdiff,
    #     $Target.B + $bdiff
    # )

    [RgbColor] [Hsb]::new(
        $Target.H * $hratio,
        $Target.S * $sratio,
        $Target.B * $bratio
    )
}