function Get-MtMarkdownReport {
    <#
    .Synopsis
     Generates a markdown report using the Maester test results format.

    .Description
       This markdown report can be used in GitHub actions to display the test results in a formatted way.

    .Example
       $pesterResults = Invoke-Pester -PassThru
       $maesterResults = ConvertTo-MtMaesterResult -PesterResults $pesterResults
       Get-MtMarkdownReport $maesterResults
    #>
    [CmdletBinding()]
    param(
        # The Maester test results returned from `Invoke-Pester -PassThru | ConvertTo-MtMaesterResult`
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $MaesterResults
    )
    $StatusIcon = @{
        Passed      = '<img src="https://maester.dev/img/test-result/pill-pass.png" height="25" alt="Passed"/>'
        Failed      = '<img src="https://maester.dev/img/test-result/pill-fail.png" height="25" alt="Failed"/>'
        NotRun      = '<img src="https://maester.dev/img/test-result/pill-notrun.png" height="25" alt="Not Run"/>'
        Skipped     = '<img src="https://maester.dev/img/test-result/pill-notrun.png" height="25" alt="Skipped"/>'
        Investigate = '<img src="https://maester.dev/img/test-result/pill-investigate.png" height="25" alt="Investigate"/>'
        Error       = '<img src="https://maester.dev/img/test-result/pill-fail.png" height="25" alt="Error"/>'
    }

    $StatusIconSm = @{
        Passed      = '✅'
        Failed      = '❌'
        NotRun      = '❔'
        Skipped     = '🚫'
        Investigate = '🔍'
        Error       = '⚠️'
    }

    $ResultDisplayName = @{
        Passed      = 'Passed'
        Failed      = 'Failed'
        NotRun      = 'Not Run'
        Skipped     = 'Skipped'
        Investigate = 'Investigate'
        Error       = 'Error'
    }

    $SeverityIcon = @{
        Critical = '🔴 Critical'
        High     = '🟠 High'
        Medium   = '🟡 Medium'
        Low      = '🟢 Low'
        Info     = 'ℹ️ Info'
    }

    function GetSeverityText($severity) {
        if ($severity -and $SeverityIcon.ContainsKey($severity)) { return $SeverityIcon[$severity] } else { return $severity }
    }

    function GetTestSummary() {
        $summary = @'
|Test|Severity|Status|
|-|:-:|:-:|

'@
        foreach ($test in $MaesterResults.Tests) {
            $severityText = GetSeverityText $test.Severity
            $summary += "| $($test.Name) | $severityText | $($StatusIcon[$test.Result]) |`n"
        }
        return $summary
    }

    function GetTestDetails() {

        foreach ($test in $MaesterResults.Tests) {

            $details += "### $($StatusIconSm[$test.Result]) $($test.Name)`n`n"

            $severityText = GetSeverityText $test.Severity
            $resultName = if ($ResultDisplayName.ContainsKey($test.Result)) { $ResultDisplayName[$test.Result] } else { $test.Result }
            $details += "**Severity:** $severityText &nbsp;&nbsp;&nbsp;&nbsp; **Status:** $($StatusIconSm[$test.Result]) $resultName`n`n"

            if (![string]::IsNullOrEmpty($test.ResultDetail)) {
                # Test author has provided details
                $details += "#### Overview`n`n$($test.ResultDetail.TestDescription)`n`n"
                $details += "#### Test Results`n`n$($test.ResultDetail.TestResult)`n`n"
            } elseif (![string]::IsNullOrEmpty($test.ScriptBlock)) {
                # Test author has not provided details, use default code in script
                # make sure we do not execute the code in the script block!
                $cleanedScriptBlock = $test.ScriptBlock.ToString() -replace '%\w+%', '' -replace '\$_', '€_' # or show me how I can make it not execute the $_ thing
                $details += "#### Overview`n`n``````ps1`n$cleanedScriptBlock`n```````n`n"
                if (![string]::IsNullOrEmpty($test.ErrorRecord)) {
                    $details += "#### Reason for failure`n`n$($test.ErrorRecord)`n`n"
                }
            }

            if (![string]::IsNullOrEmpty($test.HelpUrl)) { $details += "**Learn more**: [$($test.HelpUrl)]($($test.HelpUrl))`n`n" }
            if (![string]::IsNullOrEmpty($test.Tag)) {
                $tags = '`{0}`' -f ($test.Tag -join '` `')
                $details += "**Tag**: $tags`n`n"
            }

            if (![string]::IsNullOrEmpty($test.Block)) {
                $category = '`{0}`' -f ($test.Block -join '` `')
                $details += "**Category**: $category`n`n"
            }

            if (![string]::IsNullOrEmpty($test.ScriptBlockFile)) { $details += "**Source**: ``$($test.ScriptBlockFile)```n`n" }

            $details += "---`n`n"
        }

        return $details
    }

    function GetChangesSummary() {
        $tests = @($MaesterResults.Tests) | Where-Object {
            $null -ne $_ -and ($_.PSObject.Properties.Name -contains 'PreviousResult')
        }

        # Without any PreviousResult data there is nothing to compare (comparison was not requested).
        if (@($tests).Count -eq 0) {
            return ''
        }

        $failingResults = @('Failed', 'Error', 'Investigate')
        function Test-IsFailing($result) { return $failingResults -contains $result }
        function Test-IsPassing($result) { return $result -eq 'Passed' }

        $newlyFailing = @($tests | Where-Object { (Test-IsFailing $_.Result) -and ![string]::IsNullOrEmpty($_.PreviousResult) -and -not (Test-IsFailing $_.PreviousResult) })
        $fixed = @($tests | Where-Object { (Test-IsPassing $_.Result) -and (Test-IsFailing $_.PreviousResult) })
        $new = @($tests | Where-Object { [string]::IsNullOrEmpty($_.PreviousResult) })

        if (@($newlyFailing).Count -eq 0 -and @($fixed).Count -eq 0 -and @($new).Count -eq 0) {
            return "## Changes since last run`n`nNo changes since the previous run.`n`n"
        }

        function GetChangeRows($changeTests) {
            $rows = ''
            foreach ($test in @($changeTests)) {
                $name = if (![string]::IsNullOrEmpty($test.Name)) { $test.Name } else { $test.Id }
                $rows += "| $name | $($StatusIconSm[$test.Result]) $($test.Result) |`n"
            }
            return $rows
        }

        $section = "## Changes since last run`n`n"

        if (@($newlyFailing).Count -gt 0) {
            $section += "### ❌ Started failing`n`n|Test|Status|`n|-|:-:|`n"
            $section += GetChangeRows $newlyFailing
            $section += "`n"
        }

        if (@($fixed).Count -gt 0) {
            $section += "### ✅ Fixed`n`n|Test|Status|`n|-|:-:|`n"
            $section += GetChangeRows $fixed
            $section += "`n"
        }

        if (@($new).Count -gt 0) {
            $section += "### 🆕 New tests`n`n|Test|Status|`n|-|:-:|`n"
            $section += GetChangeRows $new
            $section += "`n"
        }

        return $section
    }

    $markdownFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../assets/ReportTemplate.md'
    $templateMarkdown = Get-Content -Path $markdownFilePath -Raw

    # Execute functions first so they don't mess with the markdown template
    $textSummary = GetTestSummary
    $textDetails = GetTestDetails
    $textChanges = GetChangesSummary

    $templateMarkdown = $templateMarkdown -replace '%TenandId%', $MaesterResults.TenantId
    $templateMarkdown = $templateMarkdown -replace '%TenantName%', $MaesterResults.TenantName
    $templateMarkdown = $templateMarkdown -replace '%TenantName%', $MaesterResults.TenantVersion
    $templateMarkdown = $templateMarkdown -replace '%ModuleVersion%', $MaesterResults.CurrentVersion
    $templateMarkdown = $templateMarkdown -replace '%TestDate%', $MaesterResults.ExecutedAt
    $templateMarkdown = $templateMarkdown -replace '%TotalCount%', $MaesterResults.TotalCount
    $templateMarkdown = $templateMarkdown -replace '%PassedCount%', $MaesterResults.PassedCount
    $templateMarkdown = $templateMarkdown -replace '%FailedCount%', $MaesterResults.FailedCount
    $templateMarkdown = $templateMarkdown -replace '%InvestigateCount%', $MaesterResults.InvestigateCount
    $templateMarkdown = $templateMarkdown -replace '%SkippedCount%', $MaesterResults.SkippedCount
    $templateMarkdown = $templateMarkdown -replace '%NotRunCount%', $MaesterResults.NotRunCount

    $templateMarkdown = $templateMarkdown -replace '%TestSummary%', $textSummary
    $templateMarkdown = $templateMarkdown -replace '%TestDetails%', $textDetails
    $templateMarkdown = $templateMarkdown -replace '%ChangesSummary%', $textChanges

    return $templateMarkdown
}
