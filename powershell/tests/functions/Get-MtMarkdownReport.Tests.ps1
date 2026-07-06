BeforeAll {
    Import-Module "$PSScriptRoot/../../Maester.psd1" -Force
}

Describe 'Get-MtMarkdownReport changes section' {
    It 'Renders started failing, fixed and new tests from PreviousResult' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                TenantId = 't1'; TenantName = 'Contoso'; CurrentVersion = '1.0.0'; ExecutedAt = 'now'
                TotalCount = 4; PassedCount = 2; FailedCount = 1; InvestigateCount = 0; SkippedCount = 0; NotRunCount = 0; ErrorCount = 1
                Result = 'Failed'; Blocks = @()
                Tests = @(
                    [PSCustomObject]@{ Id = 'MT.1'; Name = 'MT.1: A'; Result = 'Failed'; PreviousResult = 'Passed'; Block = 'B' }
                    [PSCustomObject]@{ Id = 'MT.2'; Name = 'MT.2: B'; Result = 'Passed'; PreviousResult = 'Failed'; Block = 'B' }
                    [PSCustomObject]@{ Id = 'MT.3'; Name = 'MT.3: C'; Result = 'Passed'; PreviousResult = $null; Block = 'B' }
                    [PSCustomObject]@{ Id = 'MT.4'; Name = 'MT.4: D'; Result = 'Passed'; PreviousResult = 'Passed'; Block = 'B' }
                )
            }

            $md = Get-MtMarkdownReport -MaesterResults $results

            $md | Should -Match 'Changes since last run'
            $md | Should -Match 'Started failing'
            $md | Should -Match 'MT.1: A'
            $md | Should -Match 'Fixed'
            $md | Should -Match 'MT.2: B'
            $md | Should -Match 'New tests'
            $md | Should -Match 'MT.3: C'
        }
    }

    It 'Omits the changes section when no test has a PreviousResult' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                TenantId = 't1'; TenantName = 'Contoso'; CurrentVersion = '1.0.0'; ExecutedAt = 'now'
                TotalCount = 1; PassedCount = 1; FailedCount = 0; InvestigateCount = 0; SkippedCount = 0; NotRunCount = 0; ErrorCount = 0
                Result = 'Passed'; Blocks = @()
                Tests = @([PSCustomObject]@{ Id = 'MT.1'; Name = 'MT.1: A'; Result = 'Passed'; Block = 'B' })
            }

            $md = Get-MtMarkdownReport -MaesterResults $results
            $md | Should -Not -Match 'Changes since last run'
        }
    }

    It 'Shows a no-changes message when PreviousResult matches for all tests' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                TenantId = 't1'; TenantName = 'Contoso'; CurrentVersion = '1.0.0'; ExecutedAt = 'now'
                TotalCount = 2; PassedCount = 1; FailedCount = 1; InvestigateCount = 0; SkippedCount = 0; NotRunCount = 0; ErrorCount = 0
                Result = 'Failed'; Blocks = @()
                Tests = @(
                    [PSCustomObject]@{ Id = 'MT.1'; Name = 'MT.1: A'; Result = 'Passed'; PreviousResult = 'Passed'; Block = 'B' }
                    [PSCustomObject]@{ Id = 'MT.2'; Name = 'MT.2: B'; Result = 'Failed'; PreviousResult = 'Failed'; Block = 'B' }
                )
            }

            $md = Get-MtMarkdownReport -MaesterResults $results
            $md | Should -Match 'No changes since the previous run'
        }
    }
}
