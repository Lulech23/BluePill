powershell.exe "Get-ExecutionPolicy -Scope 'CurrentUser' | Out-File -FilePath '%TEMP%\executionpolicy.txt' -Force; Set-ExecutionPolicy -Scope 'CurrentUser' -ExecutionPolicy 'Unrestricted'; $script = Get-Content '%~dpnx0'; $script -notmatch 'supercalifragilisticexpialidocious' | Out-File -FilePath '%TEMP%\%~n0.ps1' -Force; Start-Process powershell.exe \"Set-Location -Path '%~dp0'; ^& '%TEMP%\%~n0.ps1' %1\" -verb RunAs" && exit

<#
////////////////////////////
//  BluePill by Lulech23  //
////////////////////////////

Ditch green tint on the default Aya Neo display configuration!

What's New:
* Added support for custom profiles via command-line argument
* Slightly decreased gamma for taste

Notes:
* 

To-do:
* 
#>


<#
INITIALIZATION
#>

# Version... obviously
$version = "1.1"

# Profile path
$profile = "AyaNeo.icc"
if ($args.count -gt 0) {
    $profile = (Get-Item $args[0]).Name
}
$path = "$env:WinDir\System32\spool\drivers\color\$profile"


<#
SHOW VERSION
#>

# Ooo, shiny!
Write-Host "`n                             " -BackgroundColor Green -NoNewline
Write-Host "`n BluePill [v$version] by Lulech23 " -NoNewline -BackgroundColor Green -ForegroundColor Black
Write-Host "`n                             " -BackgroundColor Green

# About
Write-Host "`nThis script will replace the current display calibration with a custom profile,"
Write-Host "fine-tuned for the Aya Neo (IGG Edition). Profile may not be applicable to other"
Write-Host "devices or other editions of the Aya Neo."
Write-Host "`nTo undo changes and restore the original calibration, run this script again later."

# Current OSK
Write-Host "`nCalibration profile is currently set to: " -NoNewline
$prof = [string] (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles\").sRGB
if ($prof.contains("$profile")) {
    Write-Host "BluePill" -ForegroundColor Cyan
    Write-Host " * Optimal calibration is enabled" -ForegroundColor Gray
    $task = "Revert to original profile"
} elseif ($prof.length -gt 0) {
    Write-Host "Custom Calibration" -ForegroundColor Yellow
    Write-Host " * Profile not recognized--reinstallation recommended" -ForegroundColor Gray
    Write-Host " * WARNING: Existing calibration data will be lost!" -ForegroundColor Gray
    $task = "Revert to original profile"
} else {
    Write-Host "Default" -ForegroundColor Magenta
    Write-Host " * Display is not calibrated" -ForegroundColor Gray
    Write-Host " * Colors and gamma may be inaccurate" -ForegroundColor Gray
    $task = "Install $profile"
}

# Setup Info
Write-Host "`nSetup will: " -NoNewline
Write-Host "$task`n" -ForegroundColor Cyan
for ($s = 10; $s -ge 0; $s--) {
    $p = if ($s -eq 1) { "" } else { "s" }
    Write-Host "`rPlease wait $s second$p to continue, or close now (Ctrl + C) to exit..." -NoNewLine -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
Write-Host


<#
INSTALL BLUEPPILL
#>

if ($task.contains("Install")) {
    if (Test-Path -Path "$path") {
        # Show setup info
        Write-Host "`nRemoving previous versions..."
        Start-Sleep -Seconds 1

        # Take ownership of previous versions
        takeown /f "$path" /a
        Write-Host
        icacls "$path" /grant administrators:F
        Write-Host

        # Remove old versions, if any
        Remove-Item -Path "$path" -Force
    }

    # Show setup info
    Write-Host "`nGenerating profile..."
    Start-Sleep -Seconds 1

    # Import custom profile, if specified
    if ($args.count -gt 0) {
        $icc = $args[0]
        $icc = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$icc"))
    } else {
        # Otherwise use default profile
        $icc = 
            "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bwBtAC8AdwBpAG4AZABvAHcAcwAvADIAMAAwADcALwAxADEALwBjAG8AbABvAHIALwBDAGEAbABpAGIAcgBhAHQAaQBvAG4AIgAgAHgAbQBsAG4AcwA6AHcAYwBzAD0AIgBoAHQAdABwADoALwAvAHMAYwBoAGUAbQBhAHMALgBtAGkAYwByAG8AcwBvAGYAdAAuAGMAbwBtAC8AdwBpAG4AZABvAHcAcwAvADIAMAAwADUALwAwADIALwBjAG8AbABvAHIALwBXAGMAcwBDAG8AbQBtAG8AbgBQAHIAbwBmAGkAbABlAFQAeQBwAGUAcwAiACAAeABtAGwAbgBzADoAbQBjAD0AIgBoAHQAdABwADoALwAvAHMAYwBoAGUAbQBhAHMALgBvAHAAZQBuAHgAbQBsAGYAbwByAG0AYQB0AHMALgBvAHIAZwAvAG0AYQByAGsAdQBwAC0AYwBvAG0AcABhAHQAaQBiAGkAbABpAHQAeQAvADIAMAAwADYAIgA+AA0ACgAJADwAYwBkAG0AOgBQAHIAbwBmAGkAbABlAE4AYQBtAGUAPgANAAoACQAJADwAdwBjAHMAOgBUAGUAeAB0ACAAeABtAGwAOgBsAGEAbgBnAD0AIgBlAG4ALQBVAFMAIgA+AEMAYQBsAGkAYgByAGEAdABlAGQAIABkAGkAcwBwAGwAYQB5ACAAcAByAG8AZgBpAGwAZQA8AC8AdwBjAHMAOgBUAGUAeAB0AD4ADQAKAAkAPAAvAGMAZABtADoAUAByAG8AZgBpAGwAZQBOAGEAbQBlAD4ADQAKAAkAPABjAGQAbQA6AEQAZQBzAGMAcgBpAHAAdABpAG8AbgA+AA0ACgAJAAkAPAB3AGMAcwA6AFQAZQB4AHQAIAB4AG0AbAA6AGwAYQBuAGcAPQAiAGUAbgAtAFUAUwAiAD4AcwBSAEcAQgAgAGQAaQBzAHAAbABhAHkAIABwAHIAbwBmAGkAbABlACAAdwBpAHQAaAAgAGQAaQBzAHAAbABhAHkAIABoAGEAcgBkAHcAYQByAGUAIABjAG8AbgBmAGkAZwB1AHIAYQB0AGkAbwBuACAAZABhAHQAYQAgAGQAZQByAGkAdgBlAGQAIABmAHIAbwBtACAAYwBhAGwAaQBiAHIAYQB0AGkAbwBuADwALwB3AGMAcwA6AFQAZQB4AHQAPgANAAoACQA8AC8AYwBkAG0AOgBEAGUAcwBjAHIAaQBwAHQAaQBvAG4APgANAAoACQA8AGMAZABtADoAQQB1AHQAaABvAHIAPgANAAoACQAJADwAdwBjAHMAOgBUAGUAeAB0ACAAeABtAGwAOgBsAGEAbgBnAD0AIgBlAG4ALQBVAFMAIgA+AE0AaQBjAHIAbwBzAG8AZgB0ACAARABpAHMAcABsAGEAeQAgAEMAbwBsAG8AcgAgAEMAYQBsAGkAYgByAGEAdABpAG8AbgA8AC8AdwBjAHMAOgBUAGUAeAB0AD4ADQAKAAkAPAAvAGMAZABtADoAQQB1AHQAaABvAHIAPgANAAoACQA8AGMAZABtADoATQBlAGEAcwB1AHIAZQBtAGUAbgB0AEMAbwBuAGQAaQB0AGkAbwBuAHMAPgANAAoACQAJADwAYwBkAG0AOgBDAG8AbABvAHIAUwBwAGEAYwBlAD4AQwBJAEUAWABZAFoAPAAvAGMAZABtADoAQwBvAGwAbwByAFMAcABhAGMAZQA+AA0ACgAJAAkAPABjAGQAbQA6AFcAaABpAHQAZQBQAG8AaQBuAHQATgBhAG0AZQA+AEQANgA1ADwALwBjAGQAbQA6AFcAaABpAHQAZQBQAG8AaQBuAHQATgBhAG0AZQA+AA0ACgAJADwALwBjAGQAbQA6AE0AZQBhAHMAdQByAGUAbQBlAG4AdABDAG8AbgBkAGkAdABpAG8AbgBzAD4ADQAKAAkAPABjAGQAbQA6AFMAZQBsAGYATAB1AG0AaQBuAG8AdQBzAD4AdAByAHUAZQA8AC8AYwBkAG0AOgBTAGUAbABmAEwAdQBtAGkAbgBvAHUAcwA+AA0ACgAJADwAYwBkAG0AOgBNAGEAeABDAG8AbABvAHIAYQBuAHQAPgAxAC4AMAA8AC8AYwBkAG0AOgBNAGEAeABDAG8AbABvAHIAYQBuAHQAPgANAAoACQA8AGMAZABtADoATQBpAG4AQwBvAGwAbwByAGEAbgB0AD4AMAAuADAAPAAvAGMAZABtADoATQBpAG4AQwBvAGwAbwByAGEAbgB0AD4ADQAKAAkAPABjAGQAbQA6AFIARwBCAFYAaQByAHQAdQBhAGwARABlAHYAaQBjAGUAPgANAAoACQAJADwAYwBkAG0AOgBNAGUAYQBzAHUAcgBlAG0AZQBuAHQARABhAHQAYQAgAFQAaQBtAGUAUwB0AGEAbQBwAD0AIgAyADAAMgAxAC0AMAA2AC0AMgA2AFQAMAA2ADoANAA5ADoAMAA5ACIAPgANAAoACQAJAAkAPABjAGQAbQA6AE0AYQB4AEMAbwBsAG8AcgBhAG4AdABVAHMAZQBkAD4AMQAuADAAPAAvAGMAZABtADoATQBhAHgAQwBvAGwAbwByAGEAbgB0AFUAcwBlAGQAPgANAAoACQAJAAkAPABjAGQAbQA6AE0AaQBuAEMAbwBsAG8AcgBhAG4AdABVAHMAZQBkAD4AMAAuADAAPAAvAGMAZABtADoATQBpAG4AQwBvAGwAbwByAGEAbgB0AFUAcwBlAGQAPgANAAoACQAJAAkAPABjAGQAbQA6AFcAaABpAHQAZQBQAHIAaQBtAGEAcgB5ACAAWAA9ACIAOQA1AC4AMAA1ACIAIABZAD0AIgAxADAAMAAuADAAMAAiACAAWgA9ACIAMQAwADgALgA5ADAAIgAvAD4ADQAKAAkACQAJADwAYwBkAG0AOgBSAGUAZABQAHIAaQBtAGEAcgB5ACAAWAA9ACIANAAxAC4AMgA0ACIAIABZAD0AIgAyADEALgAyADYAIgAgAFoAPQAiADEALgA5ADMAIgAvAD4ADQAKAAkACQAJADwAYwBkAG0AOgBHAHIAZQBlAG4AUAByAGkAbQBhAHIAeQAgAFgAPQAiADMANQAuADcANgAiACAAWQA9ACIANwAxAC4ANQAyACIAIABaAD0AIgAxADEALgA5ADIAIgAvAD4ADQAKAAkACQAJADwAYwBkAG0AOgBCAGwAdQBlAFAAcgBpAG0AYQByAHkAIABYAD0AIgAxADgALgAwADUAIgAgAFkAPQAiADcALgAyADIAIgAgAFoAPQAiADkANQAuADAANQAiAC8APgANAAoACQAJAAkAPABjAGQAbQA6AEIAbABhAGMAawBQAHIAaQBtAGEAcgB5ACAAWAA9ACIAMAAiACAAWQA9ACIAMAAiACAAWgA9ACIAMAAiAC8APgANAAoACQAJAAkAPABjAGQAbQA6AEcAYQBtAG0AYQBPAGYAZgBzAGUAdABHAGEAaQBuAEwAaQBuAGUAYQByAEcAYQBpAG4AIABHAGEAbQBtAGEAPQAiADIALgA0ACIAIABPAGYAZgBzAGUAdAA9ACIAMAAuADAANQA1ACIAIABHAGEAaQBuAD0AIgAwAC4AOQA0ADcAOAA2ADcAIgAgAEwAaQBuAGUAYQByAEcAYQBpAG4APQAiADEAMgAuADkAMgAiACAAVAByAGEAbgBzAGkAdABpAG8AbgBQAG8AaQBuAHQAPQAiADAALgAwADQAMAA0ADUAIgAvAD4ADQAKAAkACQA8AC8AYwBkAG0AOgBNAGUAYQBzAHUAcgBlAG0AZQBuAHQARABhAHQAYQA+AA0ACgAJADwALwBjAGQAbQA6AFIARwBCAFYAaQByAHQAdQBhAGwARABlAHYAaQBjAGUAPgANAAoACQA8AGMAZABtADoAQwBhAGwAaQBiAHIAYQB0AGkAbwBuAD4ADQAKAAkACQA8AGMAYQBsADoAQQBkAGEAcAB0AGUAcgBHAGEAbQBtAGEAQwBvAG4AZgBpAGcAdQByAGEAdABpAG8AbgA+AA0ACgAJAAkACQA8AGMAYQBsADoAUABhAHIAYQBtAGUAdABlAHIAaQB6AGUAZABDAHUAcgB2AGUAcwA+AA0ACgAJAAkACQAJADwAdwBjAHMAOgBSAGUAZABUAFIAQwAgAEcAYQBtAG0AYQA9ACIAMAAuADkANAAwADkAMAA5ACIAIABHAGEAaQBuAD0AIgAwAC4AOAA1ADEAOAA5ADMAIgAgAE8AZgBmAHMAZQB0ADEAPQAiADAALgAwACIALwA+AA0ACgAJAAkACQAJADwAdwBjAHMAOgBHAHIAZQBlAG4AVABSAEMAIABHAGEAbQBtAGEAPQAiADAALgA5ADQAMAA5ADAAOQAiACAARwBhAGkAbgA9ACIAMAAuADgAMwAwADgANQAyACIAIABPAGYAZgBzAGUAdAAxAD0AIgAwAC4AMAAiAC8APgANAAoACQAJAAkACQA8AHcAYwBzADoAQgBsAHUAZQBUAFIAQwAgAEcAYQBtAG0AYQA9ACIAMAAuADkANAAwADkAMAA5ACIAIABHAGEAaQBuAD0AIgAxAC4AMAAwADAAMAAwADAAIgAgAE8AZgBmAHMAZQB0ADEAPQAiADAALgAwACIALwA+AA0ACgAJAAkACQA8AC8AYwBhAGwAOgBQAGEAcgBhAG0AZQB0AGUAcgBpAHoAZQBkAEMAdQByAHYAZQBzAD4ADQAKAAkACQA8AC8AYwBhAGwAOgBBAGQAYQBwAHQAZQByAEcAYQBtAG0AYQBDAG8AbgBmAGkAZwB1AHIAYQB0AGkAbwBuAD4ADQAKAAkAPAAvAGMAZABtADoAQwBhAGwAaQBiAHIAYQB0AGkAbwBuAD4ADQAKADwALwBjAGQAbQA6AEMAbwBsAG8AcgBEAGUAdgBpAGMAZQBNAG8AZABlAGwAPgANAAoAPAA/AHgAbQBsACAAdgBlAHIAcwBpAG8AbgA9ACIAMQAuADAAIgA/AD4ADQAKADwAYwBhAG0AOgBDAG8AbABvAHIAQQBwAHAAZQBhAHIAYQBuAGMAZQBNAG8AZABlAGwAIABJAEQAPQAiAGgAdAB0AHAAOgAvAC8AcwBjAGgAZQBtAGEAcwAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0ALwB3AGkAbgBkAG8AdwBzAC8AMgAwADAANQAvADAAMgAvAGMAbwBsAG8AcgAvAEQANgA1AC4AYwBhAG0AcAAiACAAeABtAGwAbgBzADoAYwBhAG0APQAiAGgAdAB0AHAAOgAvAC8AcwBjAGgAZQBtAGEAcwAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0ALwB3AGkAbgBkAG8AdwBzAC8AMgAwADAANQAvADAAMgAvAGMAbwBsAG8AcgAvAEMAbwBsAG8AcgBBAHAAcABlAGEAcgBhAG4AYwBlAE0AbwBkAGUAbAAiACAAeABtAGwAbgBzADoAdwBjAHMAPQAiAGgAdAB0AHAAOgAvAC8AcwBjAGgAZQBtAGEAcwAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0ALwB3AGkAbgBkAG8AdwBzAC8AMgAwADAANQAvADAAMgAvAGMAbwBsAG8AcgAvAFcAYwBzAEMAbwBtAG0AbwBuAFAAcgBvAGYAaQBsAGUAVAB5AHAAZQBzACIAIAB4AG0AbABuAHMAOgB4AHMAPQAiAGgAdAB0AHAAOgAvAC8AdwB3AHcALgB3ADMALgBvAHIAZwAvADIAMAAwADEALwBYAE0ATABTAGMAaABlAG0AYQAtAGkAbgBzAHQAYQBuAGMAZQAiAD4ADQAKAAkAPABjAGEAbQA6AFAAcgBvAGYAaQBsAGUATgBhAG0AZQA+AA0ACgAJAAkAPAB3AGMAcwA6AFQAZQB4AHQAIAB4AG0AbAA6AGwAYQBuAGcAPQAiAGUAbgAtAFUAUwAiAD4AVwBDAFMAIABwAHIAbwBmAGkAbABlACAAZgBvAHIAIABzAFIARwBCACAAdgBpAGUAdwBpAG4AZwAgAGMAbwBuAGQAaQB0AGkAbwBuAHMAPAAvAHcAYwBzADoAVABlAHgAdAA+AA0ACgAJADwALwBjAGEAbQA6AFAAcgBvAGYAaQBsAGUATgBhAG0AZQA+AA0ACgAJADwAYwBhAG0AOgBEAGUAcwBjAHIAaQBwAHQAaQBvAG4APgANAAoACQAJADwAdwBjAHMAOgBUAGUAeAB0ACAAeABtAGwAOgBsAGEAbgBnAD0AIgBlAG4ALQBVAFMAIgA+AEQAZQBmAGEAdQBsAHQAIABwAHIAbwBmAGkAbABlACAAZgBvAHIAIABhACAAcwBSAEcAQgAgAG0AbwBuAGkAdABvAHIAIABpAG4AIABzAHQAYQBuAGQAYQByAGQAIAB2AGkAZQB3AGkAbgBnACAAYwBvAG4AZABpAHQAaQBvAG4AcwA8AC8AdwBjAHMAOgBUAGUAeAB0AD4ADQAKAAkAPAAvAGMAYQBtADoARABlAHMAYwByAGkAcAB0AGkAbwBuAD4ADQAKAAkAPABjAGEAbQA6AEEAdQB0AGgAbwByAD4ADQAKAAkACQA8AHcAYwBzADoAVABlAHgAdAAgAHgAbQBsADoAbABhAG4AZwA9ACIAZQBuAC0AVQBTACIAPgBNAGkAYwByAG8AcwBvAGYAdAAgAEMAbwByAHAAbwByAGEAdABpAG8AbgA8AC8AdwBjAHMAOgBUAGUAeAB0AD4ADQAKAAkAPAAvAGMAYQBtADoAQQB1AHQAaABvAHIAPgANAAoACQA8AGMAYQBtADoAVgBpAGUAdwBpAG4AZwBDAG8AbgBkAGkAdABpAG8AbgBzAD4ADQAKAAkACQA8AGMAYQBtADoAVwBoAGkAdABlAFAAbwBpAG4AdABOAGEAbQBlAD4ARAA2ADUAPAAvAGMAYQBtADoAVwBoAGkAdABlAFAAbwBpAG4AdABOAGEAbQBlAD4ADQAKAAkACQA8AGMAYQBtADoAQgBhAGMAawBnAHIAbwB1AG4AZAAgAFgAPQAiADEAOQAuADAAIgAgAFkAPQAiADIAMAAuADAAIgAgAFoAPQAiADIAMQAuADcAOAAiAC8APgANAAoACQAJADwAYwBhAG0AOgBTAHUAcgByAG8AdQBuAGQAPgBBAHYAZQByAGEAZwBlADwALwBjAGEAbQA6AFMAdQByAHIAbwB1AG4AZAA+AA0ACgAJAAkAPABjAGEAbQA6AEwAdQBtAGkAbgBhAG4AYwBlAE8AZgBBAGQAYQBwAHQAaQBuAGcARgBpAGUAbABkAD4AMQA2AC4AMAA8AC8AYwBhAG0AOgBMAHUAbQBpAG4AYQBuAGMAZQBPAGYAQQBkAGEAcAB0AGkAbgBnAEYAaQBlAGwAZAA+AA0ACgAJAAkAPABjAGEAbQA6AEQAZQBnAHIAZQBlAE8AZgBBAGQAYQBwAHQAYQB0AGkAbwBuAD4AMQA8AC8AYwBhAG0AOgBEAGUAZwByAGUAZQBPAGYAQQBkAGEAcAB0AGEAdABpAG8AbgA+AA0ACgAJADwALwBjAGEAbQA6AFYAaQBlAHcAaQBuAGcAQwBvAG4AZABpAHQAaQBvAG4AcwA+AA0ACgA8AC8AYwBhAG0AOgBDAG8AbABvAHIAQQBwAHAAZQBhAHIAYQBuAGMAZQBNAG8AZABlAGwAPgANAAoAPAA/AHgAbQBsACAAdgBlAHIAcwBpAG8AbgA9ACIAMQAuADAAIgA/AD4ADQAKADwAZwBtAG0AOgBHAGEAbQB1AHQATQBhAHAATQBvAGQAZQBsACAASQBEAD0AIgBoAHQAdABwADoALwAvAHMAYwBoAGUAbQBhAHMALgBtAGkAYwByAG8AcwBvAGYAdAAuAGMAbwBtAC8AdwBpAG4AZABvAHcAcwAvADIAMAAwADUALwAwADIALwBjAG8AbABvAHIALwBNAGUAZABpAGEAUwBpAG0ALgBnAG0AbQBwACIAIAB4AG0AbABuAHMAOgBnAG0AbQA9ACIAaAB0AHQAcAA6AC8ALwBzAGMAaABlAG0AYQBzAC4AbQBpAGMAcgBvAHMAbwBmAHQALgBjAG8AbQAvAHcAaQBuAGQAbwB3AHMALwAyADAAMAA1AC8AMAAyAC8AYwBvAGwAbwByAC8ARwBhAG0AdQB0AE0AYQBwAE0AbwBkAGUAbAAiACAAeABtAGwAbgBzADoAdwBjAHMAPQAiAGgAdAB0AHAAOgAvAC8AcwBjAGgAZQBtAGEAcwAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0ALwB3AGkAbgBkAG8AdwBzAC8AMgAwADAANQAvADAAMgAvAGMAbwBsAG8AcgAvAFcAYwBzAEMAbwBtAG0AbwBuAFAAcgBvAGYAaQBsAGUAVAB5AHAAZQBzACIAIAB4AG0AbABuAHMAOgB4AHMAPQAiAGgAdAB0AHAAOgAvAC8AdwB3AHcALgB3ADMALgBvAHIAZwAvADIAMAAwADEALwBYAE0ATABTAGMAaABlAG0AYQAtAGkAbgBzAHQAYQBuAGMAZQAiAD4ADQAKAAkAPABnAG0AbQA6AFAAcgBvAGYAaQBsAGUATgBhAG0AZQA+AA0ACgAJAAkAPAB3AGMAcwA6AFQAZQB4AHQAIAB4AG0AbAA6AGwAYQBuAGcAPQAiAGUAbgAtAFUAUwAiAD4AUAByAG8AbwBmAGkAbgBnACAALQAgAHMAaQBtAHUAbABhAHQAZQAgAHAAYQBwAGUAcgAvAG0AZQBkAGkAYQAgAGMAbwBsAG8AcgA8AC8AdwBjAHMAOgBUAGUAeAB0AD4ADQAKAAkAPAAvAGcAbQBtADoAUAByAG8AZgBpAGwAZQBOAGEAbQBlAD4ADQAKAAkAPABnAG0AbQA6AEQAZQBzAGMAcgBpAHAAdABpAG8AbgA+AA0ACgAJAAkAPAB3AGMAcwA6AFQAZQB4AHQAIAB4AG0AbAA6AGwAYQBuAGcAPQAiAGUAbgAtAFUAUwAiAD4AQQBwAHAAcgBvAHAAcgBpAGEAdABlACAAZgBvAHIAIABJAEMAQwAgAGEAYgBzAG8AbAB1AHQAZQAgAGMAbwBsAG8AcgBpAG0AZQB0AHIAaQBjACAAcgBlAG4AZABlAHIAaQBuAGcAIABpAG4AdABlAG4AdAAgAHcAbwByAGsAZgBsAG8AdwBzADwALwB3AGMAcwA6AFQAZQB4AHQAPgANAAoACQA8AC8AZwBtAG0AOgBEAGUAcwBjAHIAaQBwAHQAaQBvAG4APgANAAoACQA8AGcAbQBtADoAQQB1AHQAaABvAHIAPgANAAoACQAJADwAdwBjAHMAOgBUAGUAeAB0ACAAeABtAGwAOgBsAGEAbgBnAD0AIgBlAG4ALQBVAFMAIgA+AE0AaQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIAcABvAHIAYQB0AGkAbwBuADwALwB3AGMAcwA6AFQAZQB4AHQAPgANAAoACQA8AC8AZwBtAG0AOgBBAHUAdABoAG8AcgA+AA0ACgAJADwAZwBtAG0AOgBEAGUAZgBhAHUAbAB0AEIAYQBzAGUAbABpAG4AZQBHAGEAbQB1AHQATQBhAHAATQBvAGQAZQBsAD4ASABQAE0AaQBuAEMARABfAEEAYgBzAG8AbAB1AHQAZQA8AC8AZwBtAG0AOgBEAGUAZgBhAHUAbAB0AEIAYQBzAGUAbABpAG4AZQBHAGEAbQB1AHQATQBhAHAATQBvAGQAZQBsAD4ADQAKADwALwBnAG0AbQA6AEcAYQBtAHUAdABNAGEAcABNAG8AZABlAGwAPgANAAoAAAA="
    }

    # Export source
    [IO.File]::WriteAllBytes("$path", [Convert]::FromBase64String($icc))

    # Ensure export succeeded
    if (Test-Path -Path "$path") {
        Write-Host "`nUpdating system config (this may take a while)..."

        # Delete user calibration to enable system calibration, if any
        $regpath = (reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" 2>$null)
        if ($regpath.length -gt 0) {
            reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" /f
        }

        # Associate calibration profile with display
        $regpath = (reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\ProfileAssociations\Display") -match "HKEY_CURRENT_USER"
        for ($r = 0; $r -lt $regpath.count; $r++) {
            $reg = $regpath[$r]
            reg add "$reg\0007" /t REG_DWORD /v "UsePerUserProfiles" /d 1 /f
            reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfile" /d "$profile" /f
            reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileAC" /d "$profile" /f
            reg delete "$reg\0007" /v "ICMProfileSnapshot" /f
            reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileSnapshot" /f
            reg delete "$reg\0007" /v "ICMProfileSnapshotAC" /f
            reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileSnapshotAC" /f
        }

        # Enable calibration profile
        $regpath = (reg query "HKLM\SYSTEM\ControlSet001\Control\Class" /f "ICMProfile" /s /c /e) -match "HKEY_LOCAL_MACHINE"
        $regpath += (reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /f "ICMProfile" /s /c /e) -match "HKEY_LOCAL_MACHINE"
        for ($r = 0; $r -lt $regpath.count; $r++) {
            $reg = $regpath[$r]
            reg add "$reg" /t REG_MULTI_SZ /v "ICMProfile" /d "$profile" /f
        }

        # Enable calibration management
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\Calibration" /t REG_DWORD /v "CalibrationManagementEnabled" /d 1 /f

        # Register calibration profile
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" /t REG_SZ /v "sRGB" /d "$profile" /f
        
        # Restart graphics driver to apply changes
        $gpu = Get-PnpDevice | where { $_.class -like "Display*" }
        $gpu | Disable-PnpDevice -Confirm:$false
        Start-Sleep -Seconds 1
        $gpu | Enable-PnpDevice -Confirm:$false
        
        # End process, we're done!
        Write-Host "`nProcess complete! " -NoNewline -ForegroundColor Green
        Write-Host "Default calibration replaced with optimized profile. Enjoy!"
        Write-Host "If you liked this, stop by my website at " -NoNewline
        Write-Host "https://lucasc.me" -NoNewline -ForegroundColor Yellow
        Write-Host "!"
    } else {
        # Show error if replacement failed
        Write-Host "Generating profile failed!" -NoNewline -ForegroundColor Magenta 
        Write-Host "Directory or file is inaccessible:"
        Write-Host "$path" -ForegroundColor Yellow
        Write-Host "`nPlease correct system permissions manually and run this script again."
    }
}


<#
REVERT ORIGINAL PROFILE
#>

if ($task.contains("Revert")) {
    Write-Host "`nReverting display calibration (this may take a while)..."
    Start-Sleep -Seconds 1

    # Delete user calibration to restore system calibration, if any
    $regpath = (reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" 2>$null)
    if ($regpath.length -gt 0) {
        reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" /f
    }

    # Disassociate calibration profile from display
    $regpath = (reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\ProfileAssociations\Display") -match "HKEY_CURRENT_USER"
    for ($r = 0; $r -lt $regpath.count; $r++) {
        $reg = $regpath[$r]
        reg add "$reg\0007" /t REG_DWORD /v "UsePerUserProfiles" /d 0 /f
        reg delete "$reg\0007" /v "ICMProfile" /f
        reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfile" /f
        reg delete "$reg\0007" /v "ICMProfileAC" /f
        reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileAC" /f
        reg delete "$reg\0007" /v "ICMProfileSnapshot" /f
        reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileSnapshot" /f
        reg delete "$reg\0007" /v "ICMProfileSnapshotAC" /f
        reg add "$reg\0007" /t REG_MULTI_SZ /v "ICMProfileSnapshotAC" /f
    }

    # Disable calibration profile
    $regpath = (reg query "HKLM\SYSTEM\ControlSet001\Control\Class" /f "ICMProfile" /s /c /e) -match "HKEY_LOCAL_MACHINE"
    $regpath += (reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /f "ICMProfile" /s /c /e) -match "HKEY_LOCAL_MACHINE"
    for ($r = 0; $r -lt $regpath.count; $r++) {
        $reg = $regpath[$r]
        reg delete "$reg" /v ICMProfile /f
        reg add "$reg" /t REG_MULTI_SZ /v "ICMProfile" /f
    }
    
    # Disable calibration management
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\Calibration" /t REG_DWORD /v "CalibrationManagementEnabled" /d 0 /f

    # Unregister calibration profile
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ICM\RegisteredProfiles" /v "sRGB" /f
    
    # Restart graphics driver to apply changes
    $gpu = Get-PnpDevice | where { $_.class -like "Display*" }
    $gpu | Disable-PnpDevice -Confirm:$false
    Start-Sleep -Seconds 1
    $gpu | Enable-PnpDevice -Confirm:$false

    # If profile exists...
    if (Test-Path -Path "$path") {
        # Take ownership of profile
        takeown /f "$path" /a
        Write-Host
        icacls "$path" /grant administrators:F

        # Delete profile file
        Remove-Item -Path "$path" -Force
    }
    
    # End process, we're done!
    Write-Host "`nProcess complete! " -NoNewline -ForegroundColor Green
    Write-Host "Original calibration restored. Enjoy, I guess..."
}


<#
FINALIZATION
#>

# Exit, we're done!
Write-Host
for ($s = 10; $s -ge 0; $s--) {
    $p = if ($s -eq 1) { "" } else { "s" }
    Write-Host "`rSetup will cleanup and exit in $s second$p, please wait..." -NoNewLine -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
Write-Host
Write-Host "`nCleaning up..."
Start-Sleep -Seconds 1

# Reset execution policy and delete temporary script file
$policy = "Default"
if (Test-Path -Path "$env:Temp\executionpolicy.txt") {
    $policy = [string] (Get-Content -Path "$env:Temp\executionpolicy.txt")
}
Start-Process powershell.exe "Set-ExecutionPolicy -Scope 'CurrentUser' -ExecutionPolicy '$policy'; Remove-Item -Path '$env:Temp\executionpolicy.txt' -Force; Remove-Item -Path '$PSCommandPath' -Force"
