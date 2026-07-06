function ConvertTo-MtTestState {
    <#
    .SYNOPSIS
    Internal: Projects a Maester test results object into a normalized, provider-agnostic state map.

    .DESCRIPTION
    The Maester "state" is a snapshot of the pass/fail status of every test, keyed by test id.
    It is intentionally decoupled from the source that produced it so that different state
    providers (a previous TestResults JSON file today, GitHub Issues in a later release) can be
    compared with the same Compare-MtTestState engine.

    Returns an ordered hashtable keyed by the test Id. Each value is a PSCustomObject with the
    fields needed for classification and for rendering the "Changes since last run" report
    section (and, in a future provider, for creating/updating GitHub issues).

    .PARAMETER MaesterResults
    A Maester results object (as produced by ConvertTo-MtMaesterResult or loaded via
    Import-MtMaesterResult) that exposes a Tests collection.

    .EXAMPLE
    $state = ConvertTo-MtTestState -MaesterResults $maesterResults
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $MaesterResults
    )

    $state = [ordered]@{}

    if ($null -eq $MaesterResults -or -not ($MaesterResults.PSObject.Properties.Name -contains 'Tests')) {
        Write-Verbose "ConvertTo-MtTestState: results object has no Tests collection; returning empty state."
        return $state
    }

    foreach ($test in @($MaesterResults.Tests)) {
        if ($null -eq $test) { continue }

        # Prefer the stable test Id. Fall back to Name so results that predate the Id split
        # (or malformed tests) still participate in the comparison.
        $testId = if (![string]::IsNullOrWhiteSpace($test.Id)) { $test.Id } else { $test.Name }
        if ([string]::IsNullOrWhiteSpace($testId)) {
            Write-Verbose "ConvertTo-MtTestState: skipping a test with no Id or Name."
            continue
        }

        if ($state.Contains($testId)) {
            # Duplicate ids can occur across blocks; keep the first and warn once.
            Write-Verbose "ConvertTo-MtTestState: duplicate test id '$testId' encountered; keeping the first occurrence."
            continue
        }

        $tags = @()
        if ($test.PSObject.Properties.Name -contains 'Tag' -and $null -ne $test.Tag) {
            $tags = @($test.Tag)
        }

        $state[$testId] = [PSCustomObject]@{
            TestId       = $testId
            Title        = $test.Title
            Name         = $test.Name
            Result       = $test.Result
            Severity     = $test.Severity
            Tag          = $tags
            HelpUrl      = $test.HelpUrl
            ResultDetail = $test.ResultDetail
            Block        = $test.Block
        }
    }

    return $state
}
