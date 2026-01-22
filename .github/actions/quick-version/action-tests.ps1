
Describe "Quick-Version Action Tests" {

    BeforeAll {
        # Purge any previously loaded modules to ensure a clean test environment
        # Remove-Item Class:QucikVersion -Force -ErrorAction SilentlyContinue
        # Remove-Item Class:QucikVersionMessage -Force -ErrorAction SilentlyContinue

        # Setup code if needed
        $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Path $MyInvocation.MyCommand.Definition -Parent }
        . (Join-Path $scriptDir 'action.ps1')
    }

    It "Constructing QuickVersion object should set properties correctly" {
        $result = [QuickVersion]::new(1, 2, 3, 4, "RC", 5, "Note")
        $result.Major | Should -Be 1
        $result.Minor | Should -Be 2
        $result.Patch | Should -Be 3
        $result.Build | Should -Be 4
        $result.ReleaseLabel | Should -Be "rc"
        $result.ReleaseBuild | Should -Be 5
        $result.ReleaseNote | Should -Be "note"
        $result.ToString() | Should -Be "1.2.3.4-rc.5+note"
    }

    It "Constructing QuickVersion object should set properties correctly" {
        $result = [QuickVersion]::new(1, 2, 3, 4)
        $result.Major | Should -Be 1 
        $result.Minor | Should -Be 2
        $result.Patch | Should -Be 3
        $result.Build | Should -Be 4
        $result.ReleaseLabel | Should -Be ""
        $result.ReleaseBuild | Should -Be 0
        $result.ReleaseNote | Should -Be ""
        Should -Be "1.2.3.4" -ActualValue $result.ToString()
    }
    It "Constructing QuickVersionMessage object should set properties correctly" {
        $result = [QuickVersionMessage]::new("feat", "added new feature")
        $result.Type | Should -Be "feat"
        $result.Scope | Should -BeNull
        $result.Message | Should -Be "added new feature"
    }

    It "Constructing QuickVersionMessage object should set properties correctly" {
        $result = [QuickVersionMessage]::new("feat", "dascope", "added new feature")
        $result.Type | Should -Be "feat"
        $result.Scope | Should -Be "dascope"
        $result.Message | Should -Be "added new feature"
    }

    It "QuickVersion.Parse should work correctly with full version" {
        $tests = @(
            @{ major = 1; minor = 2; patch = 3; build = 4; label = "alpha"; rbuild = 5; rnote = "note"; },
            @{ major = 1; minor = 2; patch = 3; build = 4; label = "beta"; rbuild = 6; rnote = "beta-test"; },
            @{ major = 1; minor = 2; patch = 3; build = 4; label = "rc"; rbuild = 7; rnote = "branch-staging-sha5234ef6"; },
            @{ major = 1; minor = 2; patch = 3; build = 4; label = ""; rbuild = 0; rnote = ""; },
            @{ major = 10; minor = 20; patch = 30; build = 40; label = "rc"; rbuild = 8; rnote = "v10-release"; }
        ) | ForEach-Object {
            return @{
                test   = [QuickVersion]::new($_.major, $_.minor, $_.patch, $_.build, $_.label, $_.rbuild, $_.rnote).ToString()
                major  = $_.major
                minor  = $_.minor
                patch  = $_.patch
                build  = $_.build
                label  = $_.label
                rbuild = $_.rbuild
                rnote  = $_.rnote
            }
        }
        foreach ($test in $tests) {

            $result = [QuickVersion]::Parse($test.test)
            $result.Major | Should -Be $test.major
            $result.Minor | Should -Be $test.minor
            $result.Patch | Should -Be $test.patch
            $result.Build | Should -Be $test.build
            $result.ReleaseLabel | Should -Be $test.label
            $result.ReleaseBuild | Should -Be $test.rbuild
            $result.ReleaseNote | Should -Be $test.rnote
        }
    }

    It "QuickVersion.Compare should work correctly" {
        $tests = @(
            @{ v1 = [QuickVersion]::Parse("1.2.3.4"); v2 = [QuickVersion]::Parse("1.2.3.5"); expected = -1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3.5"); v2 = [QuickVersion]::Parse("1.2.3.4"); expected = 1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3.4"); v2 = [QuickVersion]::Parse("1.2.3.4"); expected = 0 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-rc.1"); v2 = [QuickVersion]::Parse("1.2.3"); expected = -1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3"); v2 = [QuickVersion]::Parse("1.2.3-rc.1"); expected = 1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-rc.1"); v2 = [QuickVersion]::Parse("1.2.3-rc.1"); expected = 0 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-alpha.1"); v2 = [QuickVersion]::Parse("1.2.3-beta.1"); expected = -1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-beta.1"); v2 = [QuickVersion]::Parse("1.2.3-alpha.1"); expected = 1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-beta.1"); v2 = [QuickVersion]::Parse("1.2.3-beta.2"); expected = -1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3-beta.2"); v2 = [QuickVersion]::Parse("1.2.3-beta.1"); expected = 1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3+note1"); v2 = [QuickVersion]::Parse("1.2.3+note2"); expected = -1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3+note2"); v2 = [QuickVersion]::Parse("1.2.3+note1"); expected = 1 },
            @{ v1 = [QuickVersion]::Parse("1.2.3+note"); v2 = [QuickVersion]::Parse("1.2.3+note"); expected = 0 }
        ) | ForEach-Object {
            return @{
                v1       = $_.v1
                v2       = $_.v2
                expected = $_.expected
            }
        }

        foreach ($test in $tests) {
            $result = [QuickVersion]::Compare($test.v1, $test.v2) 
            $result| Should -Be $test.expected
        }
    }


    # It "Should return version 1.2.0.0 for input 1.2" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.0.0"
    # }
    # It "Should return version 1.2.3.0 for input 1.2.3" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.0"
    # }
    # It "Should return version 1.2.3.4 for input 1.2.3.4" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3.4"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.4"
    # }


    # # Pre-release RC tests
    # It "Should return version 1.2.0.0-rc for input 1.2-rc" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2-rc"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.0.0-rc"
    # }
    # It "Should return version 1.2.3.0 for input 1.2.3-rc" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3-rc"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.0-rc"
    # }
    # It "Should return version 1.2.3.4 for input 1.2.3.4-rc" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3.4-rc"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.4-rc"
    # }

    # # Pre-release RC.# tests
    # It "Should return version 1.2.0.0-rc for input 1.2-rc.6" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2-rc.6"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.0.0-rc.6"
    # }
    # It "Should return version 1.2.3.0 for input 1.2.3-rc.6" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3-rc.6"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.0-rc.6"
    # }
    # It "Should return version 1.2.3.4 for input 1.2.3.4-rc.6" {
    #     $result = ConvertTo-QucikVersionRelease -Tag "1.2.3.4-rc.6"
    #     Write-Host "Result: $result"
    #     $result | Should -Be "1.2.3.4-rc.6"
    # }
    # It "Should convert conventional commit messages to QuickVersionMessage objects" {

    #     #feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert|deps|security|release|misc
    #     $tests = @(
    #         @{type="feat"; msg="added new feature"},
    #         @{type="fix"; msg="corrected a bug"},
    #         @{type="chore"; msg="updated dependencies"},
    #         @{type="docs"; msg="improved documentation"},
    #         @{type="style"; msg="formatted code"},
    #         @{type="refactor"; msg="refactored module"},
    #         @{type="perf"; msg="improved performance"},
    #         @{type="test"; msg="added unit tests"},
    #         @{type="build"; msg="updated build process"},
    #         @{type="ci"; msg="updated CI configuration"},
    #         @{type="revert"; msg="reverted previous commit"},
    #         @{type="deps"; msg="updated dependencies"},
    #         @{type="security"; msg="fixed security vulnerability"},
    #         @{type="release"; msg="prepared for release"},
    #         @{type="misc"; msg="miscellaneous changes"}
    #     )   

    #     $commitMessage = ""
    #     for ($i = 0; $i -lt 30; $i++) {
    #         $test = $tests[$i % $tests.Count]
    #         $commitMessage += "$($test.type): $($test.msg)`n"
    #         $commitMessage += "$($test.type) : $($test.msg)`n"
    #     }

    #     $messages = ConvertTo-QuickVersionMessages -CommitMessage $commitMessage
    #     $messages.Count | Should -Be 2
    #     for ($i = 0; $i -lt $tests.Count; $i++) {
    #         $test = $tests[$i]
    #         if ($test -match "^\s*(?<type>\w+)(?:\s*\([^)]+\)s*)?\s*:\s*(?<msg>.+)$") {
    #             $expectedType = $Matches.type
    #             $expectedMsg = $Matches.msg
    #             for($is = 0; $is -lt 2; $is++) {
    #                 $messages[$i].Type | Should -Be $expectedType
    #                 $messages[$i].Message | Should -Be $expectedMsg
    #             }
    #         }
    #     }

    # }

    # It "Should handle no space before/after type, scope, scope parentheses, colon, and message in conventional commit messages" {
    #     $test = "fix:corrected a bug`nci(app):updated build process`nperf(scope):improved performance"

    #     $messages = ConvertTo-QuickVersionMessages -CommitMessage $test
    #     $messages.Count | Should -Be 3
    #     $messages[0].Type | Should -Be "fix"
    #     $messages[0].Message | Should -Be "corrected a bug"
    #     $messages[1].Type | Should -Be "ci"
    #     $messages[1].Message | Should -Be "updated build process"
    #     $messages[2].Type | Should -Be "perf"
    #     $messages[2].Message | Should -Be "improved performance"
    # }

    # It "Should handle spaces before/after type, scope, scope parentheses, colon, and message in conventional commit messages" {
    #     $test = " fix : corrected a bug`n ci ( app  ) : updated build process`n perf ( scope ) : improved performance"

    #     $messages = ConvertTo-QuickVersionMessages -CommitMessage $test
    #     $messages.Count | Should -Be 3
    #     $messages[0].Type | Should -Be "fix"
    #     $messages[0].Message | Should -Be "corrected a bug"
    #     $messages[1].Type | Should -Be "ci"
    #     $messages[1].Message | Should -Be "updated build process"
    #     $messages[2].Type | Should -Be "perf"
    #     $messages[2].Message | Should -Be "improved performance"
    # }

    # It "Should ignore non-conventional commit message lines" {
    #     $test = "some bogus line 1`nfix: corrected a bug`nrandome test`n`nhello world`n`nci: updated build process`nperf(scope): improved performance"

    #     $messages = ConvertTo-QuickVersionMessages -CommitMessage $test
    #     $messages.Count | Should -Be 3
    #     $messages[0].Type | Should -Be "fix"
    #     $messages[0].Message | Should -Be "corrected a bug"
    #     $messages[1].Type | Should -Be "ci"
    #     $messages[1].Message | Should -Be "updated build process"
    #     $messages[2].Type | Should -Be "perf"
    #     $messages[2].Message | Should -Be "improved performance"
    # }

}