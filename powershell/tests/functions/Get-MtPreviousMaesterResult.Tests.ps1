BeforeAll {
    Import-Module "$PSScriptRoot/../../Maester.psd1" -Force
}

Describe 'Get-MtPreviousMaesterResult' {
    BeforeAll {
        $script:testDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "MaesterPrevTests_$([guid]::NewGuid().ToString('N'))"
        New-Item -Path $script:testDir -ItemType Directory -Force | Out-Null

        function New-ResultFile {
            param($Name, $TenantId, $ExecutedAt, $Result = 'Passed')
            $obj = [PSCustomObject]@{
                TenantId   = $TenantId
                ExecutedAt = $ExecutedAt
                Tests      = @([PSCustomObject]@{ Id = 'A.1'; Name = 'A.1: a'; Result = $Result })
            }
            $path = Join-Path -Path $script:testDir -ChildPath $Name
            $obj | ConvertTo-Json -Depth 5 | Out-File -FilePath $path -Encoding UTF8
            return $path
        }

        $script:older = New-ResultFile -Name 'TestResults-2026-01-01-100000.json' -TenantId 't1' -ExecutedAt '2026-01-01T10:00:00'
        $script:newer = New-ResultFile -Name 'TestResults-2026-01-02-100000.json' -TenantId 't1' -ExecutedAt '2026-01-02T10:00:00'
        $script:otherTenant = New-ResultFile -Name 'TestResults-2026-01-03-100000.json' -TenantId 't2' -ExecutedAt '2026-01-03T10:00:00'
    }

    AfterAll {
        Remove-Item -Path $script:testDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'Returns the newest result for the matching tenant' {
        $r = InModuleScope Maester -Parameters @{ dir = $script:testDir } { param($dir) Get-MtPreviousMaesterResult -Path $dir -TenantId 't1' }
        ([datetime]$r.ExecutedAt) | Should -Be ([datetime]'2026-01-02T10:00:00')
        $r.TenantId | Should -Be 't1'
    }

    It 'Excludes the specified file (so a run does not compare with itself)' {
        $r = InModuleScope Maester -Parameters @{ dir = $script:testDir; exclude = $script:newer } { param($dir, $exclude) Get-MtPreviousMaesterResult -Path $dir -TenantId 't1' -ExcludeFile $exclude }
        ([datetime]$r.ExecutedAt) | Should -Be ([datetime]'2026-01-01T10:00:00')
    }

    It 'Returns $null when the path does not exist' {
        $r = InModuleScope Maester -Parameters @{ dir = $script:testDir } { param($dir) Get-MtPreviousMaesterResult -Path (Join-Path $dir 'does-not-exist') }
        $r | Should -BeNullOrEmpty
    }

    It 'Returns $null for an empty directory' {
        $empty = Join-Path -Path $script:testDir -ChildPath 'empty'
        New-Item -Path $empty -ItemType Directory -Force | Out-Null
        $r = InModuleScope Maester -Parameters @{ dir = $empty } { param($dir) Get-MtPreviousMaesterResult -Path $dir }
        $r | Should -BeNullOrEmpty
    }
}
