[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SN,

    [string]$LogsRoot = "C:\logs",
    [string]$LogSubdirectory = "PostProcess",
    [string]$RobocalRoot = "C:\Users\User\Robocal-v4",
    [string]$StationConfig = "C:\Users\User\Robocal-v4\config\glasses\robocalv4_config_L89VJIQ.yaml",
    [Alias("Template")]
    [string]$AttachCsv = (Join-Path $PSScriptRoot "ML_Postprocess.csv"),
    [string]$OutputName = "ML_PostProcess.csv",
    [string]$IntermediateName = "ML_PostProcess_generated.csv",
    [string]$Run,
    [switch]$OfficialOnly,
    [switch]$OverwriteTemplate
)

$ErrorActionPreference = "Stop"
$snPath = Join-Path $LogsRoot $SN
$logPath = if ($LogSubdirectory) { Join-Path $snPath $LogSubdirectory } else { $snPath }
$reportTool = Join-Path $PSScriptRoot "robocal_report.py"
$adapterTool = Join-Path $PSScriptRoot "robocal_ml_adapter.py"
$intermediatePath = if ($OverwriteTemplate) {
    Join-Path ([System.IO.Path]::GetTempPath()) ("ML_PostProcess_{0}_{1}.csv" -f $SN, [guid]::NewGuid())
} else {
    Join-Path $logPath $IntermediateName
}
$outputPath = if ($OverwriteTemplate) { $AttachCsv } else { Join-Path $logPath $OutputName }

foreach ($requiredPath in @($logPath, $reportTool, $adapterTool, $AttachCsv)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required path not found: $requiredPath"
    }
}

$reportArguments = @(
    "-3.11",
    $reportTool,
    $logPath,
    "--robocal-root",
    $RobocalRoot,
    "--station-config",
    $StationConfig,
    "--output",
    $intermediatePath
)
if ($Run) {
    $reportArguments += @("--run", $Run)
}
if ($OfficialOnly) {
    $reportArguments += "--official-only"
}

try {
    Write-Host "Generating RoboCal report for SN: $SN"
    & py @reportArguments
    if ($LASTEXITCODE -ne 0) {
        throw "robocal_report.py failed with exit code $LASTEXITCODE"
    }

    $adapterArguments = @(
        "-3.11", $adapterTool, $intermediatePath,
        "--template", $AttachCsv,
        "--output", $outputPath,
        "--serial-number", $SN,
        "--replace-tests"
    )
    & py @adapterArguments
    if ($LASTEXITCODE -ne 0) {
        throw "robocal_ml_adapter.py failed with exit code $LASTEXITCODE"
    }
} finally {
    if ($OverwriteTemplate -and (Test-Path -LiteralPath $intermediatePath)) {
        Remove-Item -LiteralPath $intermediatePath -Force
    }
}

Write-Host "Generated ML report: $outputPath"
