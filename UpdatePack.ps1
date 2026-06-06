# UpdatePack.ps1 - Retro Fish Modpack Updater
# Fetches updates from https://github.com/isadora-6th/rybalka-3-retro
# Run via: powershell irm https://raw.githubusercontent.com/isadora-6th/rybalka-3-retro/main/UpdatePack.ps1 | iex

$repoOwner = "isadora-6th"
$repoName  = "rybalka-3-retro"
$branch    = "main"
$baseUrl   = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch"
$apiUrl    = "https://api.github.com/repos/$repoOwner/$repoName/git/trees/$branch`?recursive=1"

# Files to skip (repo-manifest only, not needed on disk)
$skipFiles = @("UpdatePack.ps1", "Readme.md")

# Compute a git-style blob SHA1 for a local file.
# Git computes: SHA1("blob " + filesize + "\0" + content)
# This matches what the GitHub tree API returns.
function Get-GitBlobHash {
    param([string]$Path)
    try {
        # Use -LiteralPath to handle brackets in filenames
        $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
        $bytes = [System.IO.File]::ReadAllBytes($resolved.Path)
        $header = [System.Text.Encoding]::ASCII.GetBytes("blob $($bytes.Length)`0")
        $combined = New-Object byte[] ($header.Length + $bytes.Length)
        [Buffer]::BlockCopy($header, 0, $combined, 0, $header.Length)
        [Buffer]::BlockCopy($bytes, 0, $combined, $header.Length, $bytes.Length)
        $sha1 = [System.Security.Cryptography.SHA1]::Create()
        $hashBytes = $sha1.ComputeHash($combined)
        return [BitConverter]::ToString($hashBytes).Replace('-', '').ToLower()
    } catch {
        return $null
    }
}

# Main update logic
function Update-FromRepo {
    Write-Output "=== Retro Fish Modpack Updater ==="
    Write-Output "Repository: $repoOwner/$repoName ($branch)"
    Write-Output ""

    # -----------------------------------------------------------
    # 1. Fetch the repo tree
    # -----------------------------------------------------------
    Write-Output "[1/3] Fetching file list from repository..."
    try {
        $ProgressPreference = 'SilentlyContinue'
        $treeData = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Output "ERROR: Could not fetch repository tree: $_"
        Write-Output "Make sure you have internet access and try again."
        exit 1
    }

    # Flatten tree into items
    $items = $treeData.tree | Where-Object { $_.type -eq 'blob' }

    Write-Output "       Found $($items.Count) files in repository."

    # -----------------------------------------------------------
    # 2. Determine what needs updating
    # -----------------------------------------------------------
    Write-Output "[2/3] Checking local files..."
    $toDownload = @()
    $upToDate  = 0
    $newFiles  = 0
    $changed   = 0

    # Normalize current location
    $root = (Get-Location).Path

    foreach ($item in $items) {
        $relPath = $item.path
        $repoSha = $item.sha
        $localPath = Join-Path $root $relPath

        # Check if file should be skipped
        $skip = $false
        foreach ($sf in $skipFiles) {
            if ($relPath -eq $sf) { $skip = $true; break }
        }
        if ($skip) { continue }

        if (-not (Test-Path -LiteralPath $localPath)) {
            $newFiles++
            $toDownload += $relPath
        } else {
            $localSha = Get-GitBlobHash -Path $localPath
            if ($localSha -ne $repoSha) {
                $changed++
                $toDownload += $relPath
            } else {
                $upToDate++
            }
        }
    }

    $totalTracked = $newFiles + $changed + $upToDate
    Write-Output "       Up-to-date: $upToDate, Changed: $changed, New: $newFiles (Total tracked: $totalTracked)"

    # -----------------------------------------------------------
    # 3. Download updates
    # -----------------------------------------------------------
    if ($toDownload.Count -eq 0) {
        Write-Output "[3/3] Nothing to download - everything is up to date!"
        Write-Output ""
        Write-Output "=== Update complete ==="
        return
    }

    Write-Output "[3/3] Downloading $($toDownload.Count) file(s)..."
    $success  = 0
    $failures = 0

    for ($i = 0; $i -lt $toDownload.Count; $i++) {
        $relPath = $toDownload[$i]
        $localPath = Join-Path $root $relPath
        $parentDir = Split-Path $localPath -Parent
        $url = "$baseUrl/$relPath"

        # Create parent directory if needed
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        # Progress indicator
        $pct = [math]::Round(($i + 1) / $toDownload.Count * 100)
        Write-Progress -Activity "Downloading updates..." -Status "$pct% - $relPath" -PercentComplete $pct

        try {
            # Use WebClient instead of Invoke-WebRequest -OutFile to avoid wildcard issues with brackets in filenames
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($url, $localPath)
            $wc.Dispose()
            Write-Output "       [OK] $relPath"
            $success++
        } catch {
            Write-Output "       [!!] FAILED: $relPath - $_"
            $failures++
        }
    }

    Write-Progress -Activity "Downloading updates..." -Completed

    Write-Output ""
    if ($failures -eq 0) {
        Write-Output "=== Update complete! $success file(s) updated. ==="
    } else {
        Write-Output "=== Update finished with $failures error(s). $success file(s) updated. ==="
    }
}

# Run
Update-FromRepo
