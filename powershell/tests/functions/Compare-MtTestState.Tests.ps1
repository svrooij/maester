BeforeAll {
    Import-Module "$PSScriptRoot/../../Maester.psd1" -Force
}

Describe 'ConvertTo-MtTestState' {
    It 'Projects tests into a hashtable keyed by test Id' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                Tests = @(
                    [PSCustomObject]@{ Id = 'A.1'; Name = 'A.1: alpha'; Result = 'Passed'; Tag = @('CIS'); Title = 'alpha'; Severity = 'High'; HelpUrl = 'https://maester.dev' }
                    [PSCustomObject]@{ Id = 'A.2'; Name = 'A.2: beta'; Result = 'Failed'; Tag = @('ORCA'); Title = 'beta' }
                )
            }
            $state = ConvertTo-MtTestState -MaesterResults $results
            $state.Keys.Count | Should -Be 2
            $state['A.1'].Result | Should -Be 'Passed'
            $state['A.1'].Tag | Should -Be @('CIS')
            $state['A.2'].Result | Should -Be 'Failed'
        }
    }

    It 'Falls back to Name when Id is missing' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                Tests = @(
                    [PSCustomObject]@{ Name = 'No-Id test'; Result = 'Failed' }
                )
            }
            $state = ConvertTo-MtTestState -MaesterResults $results
            $state.Contains('No-Id test') | Should -BeTrue
        }
    }

    It 'Returns an empty hashtable when there are no tests' {
        InModuleScope Maester {
            $state = ConvertTo-MtTestState -MaesterResults ([PSCustomObject]@{ Foo = 'bar' })
            $state.Keys.Count | Should -Be 0
        }
    }

    It 'Keeps the first occurrence of a duplicate test id' {
        InModuleScope Maester {
            $results = [PSCustomObject]@{
                Tests = @(
                    [PSCustomObject]@{ Id = 'A.1'; Name = 'first'; Result = 'Passed' }
                    [PSCustomObject]@{ Id = 'A.1'; Name = 'second'; Result = 'Failed' }
                )
            }
            $state = ConvertTo-MtTestState -MaesterResults $results
            $state.Keys.Count | Should -Be 1
            $state['A.1'].Result | Should -Be 'Passed'
        }
    }
}

Describe 'Compare-MtTestState' {
    BeforeEach {
        $script:previous = @{
            'A.1' = [PSCustomObject]@{ TestId = 'A.1'; Result = 'Passed' }   # -> newly failing
            'A.2' = [PSCustomObject]@{ TestId = 'A.2'; Result = 'Failed' }   # -> fixed
            'A.3' = [PSCustomObject]@{ TestId = 'A.3'; Result = 'Failed' }   # -> still failing
            'A.5' = [PSCustomObject]@{ TestId = 'A.5'; Result = 'Passed' }   # -> still passing
            'A.6' = [PSCustomObject]@{ TestId = 'A.6'; Result = 'Passed' }   # -> removed
        }
        $script:current = @{
            'A.1' = [PSCustomObject]@{ TestId = 'A.1'; Result = 'Failed' }
            'A.2' = [PSCustomObject]@{ TestId = 'A.2'; Result = 'Passed' }
            'A.3' = [PSCustomObject]@{ TestId = 'A.3'; Result = 'Failed' }
            'A.4' = [PSCustomObject]@{ TestId = 'A.4'; Result = 'Failed' }   # -> new
            'A.5' = [PSCustomObject]@{ TestId = 'A.5'; Result = 'Passed' }
        }
    }

    It 'Classifies every change bucket correctly' {
        InModuleScope Maester -Parameters @{ prev = $script:previous; cur = $script:current } {
            param($prev, $cur)
            $c = Compare-MtTestState -CurrentState $cur -PreviousState $prev
            $c.NewlyFailing.TestId | Should -Be 'A.1'
            $c.Fixed.TestId | Should -Be 'A.2'
            $c.New.TestId | Should -Be 'A.4'
            $c.StillFailing.TestId | Should -Be 'A.3'
            $c.StillPassing.TestId | Should -Be 'A.5'
            $c.Removed.TestId | Should -Be 'A.6'
            $c.HasChanges | Should -BeTrue
        }
    }

    It 'Treats Error and Investigate results as failing' {
        InModuleScope Maester {
            $prev = @{ 'X.1' = [PSCustomObject]@{ TestId = 'X.1'; Result = 'Passed' } }
            $cur = @{ 'X.1' = [PSCustomObject]@{ TestId = 'X.1'; Result = 'Error' } }
            $c = Compare-MtTestState -CurrentState $cur -PreviousState $prev
            $c.NewlyFailing.TestId | Should -Be 'X.1'
        }
    }

    It 'Reports HasChanges = false when nothing meaningful changed' {
        InModuleScope Maester {
            $state = @{ 'X.1' = [PSCustomObject]@{ TestId = 'X.1'; Result = 'Passed' } }
            $c = Compare-MtTestState -CurrentState $state -PreviousState $state
            $c.HasChanges | Should -BeFalse
            $c.StillPassing.TestId | Should -Be 'X.1'
        }
    }
}

Describe 'Compare-MtTestResult -Detailed' {
    It 'Returns the classification object for two result objects' {
        $prior = [PSCustomObject]@{
            TenantId = 't1'; ExecutedAt = '2026-01-01T10:00:00'
            Tests    = @(
                [PSCustomObject]@{ Id = 'A.1'; Name = 'A.1: a'; Result = 'Passed' }
                [PSCustomObject]@{ Id = 'A.2'; Name = 'A.2: b'; Result = 'Failed' }
            )
        }
        $new = [PSCustomObject]@{
            TenantId = 't1'; ExecutedAt = '2026-01-02T10:00:00'
            Tests    = @(
                [PSCustomObject]@{ Id = 'A.1'; Name = 'A.1: a'; Result = 'Failed' }
                [PSCustomObject]@{ Id = 'A.2'; Name = 'A.2: b'; Result = 'Passed' }
                [PSCustomObject]@{ Id = 'A.3'; Name = 'A.3: c'; Result = 'Failed' }
            )
        }
        $c = Compare-MtTestResult -PriorTest $prior -NewTest $new -Detailed
        $c.NewlyFailing.TestId | Should -Be 'A.1'
        $c.Fixed.TestId | Should -Be 'A.2'
        $c.New.TestId | Should -Be 'A.3'
    }
}
