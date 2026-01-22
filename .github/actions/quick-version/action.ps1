


class QuickVersion {
    [int]$Major
    [int]$Minor
    [int]$Patch
    [int]$Build
    [string]$ReleaseLabel      # alpha|beta|rc, empty for production
    [int]$ReleaseBuild         # 0 or greater (optional)
    [string]$ReleaseNote       # [a-z0-9.-]+ (optional)

    QuickVersion([int]$Major, [int]$Minor, [int]$Patch, [int]$Build, [string]$ReleaseLabel, [int]$ReleaseBuild, [string]$ReleaseNote) {
        $this.Major = $Major
        $this.Minor = $Minor
        $this.Patch = $Patch
        $this.Build = $Build
        $this.ReleaseLabel = [String]::IsNullOrEmpty($ReleaseLabel) ? "" : $ReleaseLabel.ToLower()
        $this.ReleaseBuild = $ReleaseBuild
        $this.ReleaseNote = [String]::IsNullOrEmpty($ReleaseNote) ? "" : $ReleaseNote.ToLower()

    }
    QuickVersion([int]$Major, [int]$Minor, [int]$Patch, [int]$Build) {
        $this.Major = $Major
        $this.Minor = $Minor
        $this.Patch = $Patch
        $this.Build = $Build
        $this.ReleaseLabel = ""
        $this.ReleaseBuild = 0
        $this.ReleaseNote = ""
    }
    
    [bool] IsProduction() {
        return [string]::IsNullOrWhiteSpace($this.ReleaseLabel) -and [string]::IsNullOrWhiteSpace($this.ReleaseNote)
    }

    [QuickVersion] Clone() {
        return [QuickVersion]::new($this.Major, $this.Minor, $this.Patch, $this.Build, $this.ReleaseLabel, $this.ReleaseBuild, $this.ReleaseNote)
    }

    [string] ToString() {
        $base = "{0}.{1}.{2}.{3}" -f $this.Major, $this.Minor, $this.Patch, $this.Build
        if ([string]::IsNullOrWhiteSpace($this.ReleaseLabel)) {
            $pre = ""
        }
        else {
            if ($this.ReleaseBuild -gt 0) {
                $pre = "-$($this.ReleaseLabel).$($this.ReleaseBuild)"
            }
            else {
                $pre = "-$($this.ReleaseLabel)"
            }
        }
        $plus = if ([string]::IsNullOrWhiteSpace($this.ReleaseNote)) { "" } else { "+$($this.ReleaseNote)" }
        return "$base$pre$plus"
    }   
    
    static [QuickVersion] Parse([string]$Value) {
        $s = $Value.Trim()
        if ($s -match '^[vV](.+)$') { $s = $Matches[1] }  # allow v1.2.3 style

        # General pattern supporting:
        # Production:          M.m [.p] [.b]
        # Pre-release:         -label [.rbuild]
        # With release note:   +note
        $re = '^(?<major>[1-9]\d*)\.(?<minor>\d+)(?:\.(?<patch>\d+))?(?:\.(?<build>\d+))?(?:-(?<label>alpha|beta|rc)(?:\.(?<rbuild>\d+))?)?(?:\+(?<rnote>[a-z0-9.-]+))?$'
        if ($s -inotmatch $re) { return $null }

        $maj = [int]$Matches.major
        $min = [int]$Matches.minor
        $pat = if ($Matches.patch) { [int]$Matches.patch } else { 0 }
        $bld = if ($Matches.build) { [int]$Matches.build } else { 0 }
        $lbl = $Matches.label
        $rbd = if ($Matches.rbuild) { [int]$Matches.rbuild } else { 0 }
        $rnt = $Matches.rnote

        return [QuickVersion]::new($maj, $min, $pat, $bld, $lbl, $rbd, $rnt)
    }

    static [int] Compare([QuickVersion]$A, [QuickVersion]$B) {
        foreach ($p in 'Major', 'Minor', 'Patch', 'Build') {
            $cmp = [Math]::Sign(($A.$p) - ($B.$p))
            if ($cmp -ne 0) { return $cmp }
        }

        $rankMap = @{ '' = 3; 'rc' = 2; 'beta' = 1; 'alpha' = 0 }
        $la = if ([string]::IsNullOrWhiteSpace($A.ReleaseLabel)) { '' } else { $A.ReleaseLabel.ToLower() }
        $lb = if ([string]::IsNullOrWhiteSpace($B.ReleaseLabel)) { '' } else { $B.ReleaseLabel.ToLower() }
        $ra = if ($rankMap.ContainsKey($la)) { $rankMap[$la] } else { -1 }
        $rb = if ($rankMap.ContainsKey($lb)) { $rankMap[$lb] } else { -1 }
        $cmp = [Math]::Sign($ra - $rb)
        if ($cmp -ne 0) { return $cmp }

        $cmp = [Math]::Sign($A.ReleaseBuild - $B.ReleaseBuild)
        if ($cmp -ne 0) { return $cmp }

        $cmp = [System.StringComparer]::OrdinalIgnoreCase.Compare($A.ReleaseNote, $B.ReleaseNote)
        return [Math]::Sign($cmp)
    }
}

class QuickVersionMessage {
    [string]$Type
    [string]$Scope
    [string]$Message
    QuickVersionMessage([string]$Type, [string]$Scope, [string]$Message) {
        $this.Type = $Type
        $this.Scope = $Scope
        $this.Message = $Message
    }
    QuickVersionMessage([string]$Type, [string]$Message) {
        $this.Type = $Type
        $this.Scope = $null
        $this.Message = $Message
    }
    static [QuickVersionMessage[]] Parse([string]$Value) {
        $allowed = 'feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert|deps|security|release|misc'
        $regex = "^\s*(?<type>($allowed))(?:\s*\([^)]+\)s*)?\s*:\s*(?<msg>.+)$"
        $messages = New-Object 'System.Collections.Generic.List[QuickVersionMessage]'

        foreach ($line in ($Value -split "`n")) {
            $l = $line.Trim()
            if ($l.Length -eq 0) { continue }
            if ($l -imatch $regex) {
                $typ = $Matches.type.ToLower()
                $msg = $Matches.msg.Trim()
                $messages.Add([QuickVersionMessage]::new($typ, $msg)) | Out-Null
            }
        }
        return $messages
    }
}
