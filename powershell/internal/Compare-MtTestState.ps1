function Compare-MtTestState {
    <#
    .SYNOPSIS
    Internal: Classifies the change between a previous and a current Maester test state.

    .DESCRIPTION
    Compares two normalized state maps (see ConvertTo-MtTestState) and buckets every test into
    a change category. This is the provider-agnostic engine behind the "Changes since last run"
    report: the current state always comes from the run that just completed, while the previous
    state can be sourced from a prior TestResults JSON file (today) or, in a later release, from
    GitHub issues.

    A test is considered "failing" when its Result is Failed, Error or Investigate. It is
    considered "passing" only when its Result is Passed. NotRun and Skipped are neither, so a
    test that moves to/from those states is reported as StillPassing/StillFailing only when the
    other side is failing/passing respectively, and otherwise treated as unchanged.

    .PARAMETER CurrentState
    The normalized state map from the current run.

    .PARAMETER PreviousState
    The normalized state map from the previous run.

    .OUTPUTS
    A PSCustomObject with the following array properties, each containing the state entries:
      NewlyFailing  - was passing (or absent) before, is failing now
      Fixed         - was failing before, is passing now
      New           - not present in the previous state at all
      StillFailing  - failing in both runs
      StillPassing  - passing in both runs
      Removed       - present previously but not in the current run
    Plus HasChanges (bool) which is true when any of NewlyFailing/Fixed/New/Removed is non-empty.

    .EXAMPLE
    $comparison = Compare-MtTestState -CurrentState $current -PreviousState $previous
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Collections.IDictionary] $CurrentState,

        [Parameter(Mandatory = $true, Position = 1)]
        [System.Collections.IDictionary] $PreviousState
    )

    $failingResults = @('Failed', 'Error', 'Investigate')

    function Test-IsFailing($result) { return $failingResults -contains $result }
    function Test-IsPassing($result) { return $result -eq 'Passed' }

    $newlyFailing = [System.Collections.Generic.List[psobject]]::new()
    $fixed = [System.Collections.Generic.List[psobject]]::new()
    $new = [System.Collections.Generic.List[psobject]]::new()
    $stillFailing = [System.Collections.Generic.List[psobject]]::new()
    $stillPassing = [System.Collections.Generic.List[psobject]]::new()
    $removed = [System.Collections.Generic.List[psobject]]::new()

    foreach ($testId in $CurrentState.Keys) {
        $current = $CurrentState[$testId]

        if (-not $PreviousState.Contains($testId)) {
            $new.Add($current)
            continue
        }

        $previous = $PreviousState[$testId]
        $currentFailing = Test-IsFailing $current.Result
        $previousFailing = Test-IsFailing $previous.Result

        if ($currentFailing -and -not $previousFailing) {
            $newlyFailing.Add($current)
        } elseif ((Test-IsPassing $current.Result) -and $previousFailing) {
            $fixed.Add($current)
        } elseif ($currentFailing -and $previousFailing) {
            $stillFailing.Add($current)
        } elseif ((Test-IsPassing $current.Result) -and (Test-IsPassing $previous.Result)) {
            $stillPassing.Add($current)
        }
        # Any other transition (e.g. Passed -> Skipped, NotRun -> NotRun) is treated as unchanged
        # and intentionally not surfaced as a highlighted change.
    }

    foreach ($testId in $PreviousState.Keys) {
        if (-not $CurrentState.Contains($testId)) {
            $removed.Add($PreviousState[$testId])
        }
    }

    $hasChanges = ($newlyFailing.Count -gt 0) -or ($fixed.Count -gt 0) -or ($new.Count -gt 0) -or ($removed.Count -gt 0)

    return [PSCustomObject]@{
        NewlyFailing = $newlyFailing.ToArray()
        Fixed        = $fixed.ToArray()
        New          = $new.ToArray()
        StillFailing = $stillFailing.ToArray()
        StillPassing = $stillPassing.ToArray()
        Removed      = $removed.ToArray()
        HasChanges   = $hasChanges
    }
}
