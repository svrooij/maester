function Get-MtPreviousMaesterResult {
    <#
    .SYNOPSIS
    Internal: Resolves the previous Maester results object to compare the current run against.

    .DESCRIPTION
    Loads previously saved Maester result JSON (via Import-MtMaesterResult) and selects the most
    recent one to use as the "previous state" for Compare-MtTestState. When a TenantId is
    supplied, results for that tenant are preferred so multi-tenant output folders compare like
    with like.

    .PARAMETER Path
    A path to a specific result JSON file or a directory containing TestResults-*.json files.

    .PARAMETER TenantId
    Optional tenant id of the current run, used to prefer a matching previous result.

    .PARAMETER ExcludeFile
    Optional full path of a file to ignore (e.g. the result file about to be written by the
    current run) so a run does not compare against itself.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [string] $TenantId,

        [Parameter(Mandatory = $false)]
        [string] $ExcludeFile
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Verbose "Get-MtPreviousMaesterResult: path '$Path' not found; no previous result to compare."
        return $null
    }

    # Build the list of paths to import. For a directory we enumerate the result files so we can
    # exclude the file the current run is about to write (ExcludeFile) before importing.
    $importPaths = @()
    if (Test-Path -Path $Path -PathType Container) {
        $existing = @(Get-ChildItem -Path $Path -Filter 'TestResults-*.json' -File -ErrorAction SilentlyContinue)
        if ($existing.Count -eq 0) {
            $existing = @(Get-ChildItem -Path $Path -Filter '*.json' -File -ErrorAction SilentlyContinue)
        }
        if ($ExcludeFile) {
            $existing = @($existing | Where-Object { $_.FullName -ne $ExcludeFile })
        }
        if ($existing.Count -eq 0) {
            Write-Verbose "Get-MtPreviousMaesterResult: no previous result files found in '$Path'."
            return $null
        }
        $importPaths = @($existing.FullName)
    } else {
        # A specific file was provided. Honor ExcludeFile so a run cannot compare against itself.
        $resolvedFile = (Resolve-Path -Path $Path -ErrorAction SilentlyContinue).Path
        if ($ExcludeFile -and $resolvedFile -eq $ExcludeFile) {
            Write-Verbose "Get-MtPreviousMaesterResult: the only candidate '$Path' is the excluded file."
            return $null
        }
        $importPaths = @($Path)
    }

    $results = @()
    # Import-MtMaesterResult returns its list with a leading unary comma to preserve array
    # semantics, so a single call can surface as one nested array element. Flatten one level
    # so tenant filtering and sorting operate on the individual result objects.
    foreach ($item in @(Import-MtMaesterResult -Path $importPaths -ErrorAction SilentlyContinue)) {
        if ($item -is [System.Array]) {
            $results += $item
        } elseif ($null -ne $item) {
            $results += $item
        }
    }
    if ($results.Count -eq 0) {
        Write-Verbose "Get-MtPreviousMaesterResult: no valid previous results loaded from '$Path'."
        return $null
    }

    # Prefer results for the same tenant when we know which tenant this run targeted.
    $candidates = $results
    if (![string]::IsNullOrWhiteSpace($TenantId)) {
        $tenantMatches = @($results | Where-Object { $_.TenantId -eq $TenantId })
        if ($tenantMatches.Count -gt 0) {
            $candidates = $tenantMatches
        }
    }

    # Newest first by ExecutedAt (falls back to input order when the property is missing).
    $sorted = @($candidates | Sort-Object -Property { [datetime]::Parse([string]$_.ExecutedAt) } -Descending -ErrorAction SilentlyContinue)
    if ($sorted.Count -eq 0) { $sorted = $candidates }

    return $sorted[0]
}
