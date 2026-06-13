# ResetPack.ps1 - Retro Fish Modpack Reset
# Cleans local folders and re-downloads the pack from repository.
# Run via: powershell irm https://raw.githubusercontent.com/isadora-6th/rybalka-3-retro/main/ResetPack.ps1 | iex

$repoOwner = "isadora-6th"
$repoName  = "rybalka-3-retro"
$branch    = "main"
$baseUrl   = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch"

# Folders to clean under instances\1.4.7\.minecraft\
$cleanFolders = @(
    "texturepacks",
    "mods",
    "coremods",
    "config",
    "resources"
)

function Reset-Pack {
    Write-Output "============================================"
    Write-Output "  RESET PACK - Clean and re-download"
    Write-Output "============================================"
    Write-Output ""
    Write-Output "This will DELETE everything in:"
    foreach ($folder in $cleanFolders) {
        Write-Output "  - instances\1.4.7\.minecraft\$folder\"
    }
    Write-Output ""
    Write-Output "Then re-download the pack from repository."
    Write-Output ""

    # No interactive prompt when running from batch with iex — proceed directly
    # (The batch wrapper asks for confirmation before invoking this script.)

    $root = (Get-Location).Path

    # -----------------------------------------------------------
    # 1. Clean specified folders
    # -----------------------------------------------------------
    Write-Output "--- Cleaning folders ---"
    foreach ($folder in $cleanFolders) {
        $targetPath = Join-Path $root "instances\1.4.7\.minecraft\$folder"
        if (Test-Path $targetPath) {
            Write-Output "  Deleting contents of $folder..."
            try {
                Remove-Item -Path "$targetPath\*" -Recurse -Force -ErrorAction Stop
                Write-Output "    Done."
            } catch {
                Write-Output "    Warning: Could not delete some files in $folder : $_"
            }
        } else {
            Write-Output "  $folder not found, skipping."
        }
    }

    Write-Output ""
    Write-Output "============================================"
    Write-Output "  Cleanup complete!"
    Write-Output "  Now downloading fresh pack files..."
    Write-Output "============================================"
    Write-Output ""

    # -----------------------------------------------------------
    # 2. Download and run UpdatePack.ps1
    # -----------------------------------------------------------
    $updateUrl = "$baseUrl/UpdatePack.ps1"
    try {
        Write-Output "[Fetching UpdatePack.ps1...]"
        $updateScript = Invoke-RestMethod -Uri $updateUrl -UseBasicParsing -ErrorAction Stop
        Invoke-Expression $updateScript
    } catch {
        Write-Output "ERROR: Could not fetch or execute UpdatePack.ps1: $_"
        Write-Output "Make sure you have internet access and try again."
        exit 1
    }

    Write-Output ""
    Write-Output "============================================"
    Write-Output "  Reset complete!"
    Write-Output "============================================"
}

# Run
Reset-Pack
