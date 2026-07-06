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

    # If a directory was provided and there are no result files yet, there is nothing to compare.
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
    }

    $results = @(Import-MtMaesterResult -Path $Path -ErrorAction SilentlyContinue)
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
