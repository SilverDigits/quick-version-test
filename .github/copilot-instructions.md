# Quick Version Action Instructions

Quick version is a GitHub Action that processes commit messages and tags to determine versioning based on conventional commit messages and semantic versioning formats.


## Parameters
The action should accept the following parameters:
- `pre-release-label` (string, optional): A pre-release label to append to the version (e.g., "beta", "rc").
- `pre-release-metadata` (string, optional): Build metadata to append to the version (e.g., "exp.sha.5114f85"). Only allowed for pre-release versions and is appended after a plus sign (+), e.g., "1.0.0-beta.1+exp.sha.5114f85".
- `debug` (boolean, optional): Enable debug logging if set to true. Default is false.


## Version Components
The following are the version components to be recognized by the action where:

| Component         | Rule                                            |
|-------------------|-------------------------------------------------|
| `<major>`         | Integer 0 or greater                            |
| `<minor>`         | Integer 0 or greater                            |
| `<patch>`         | Integer 0 or greater                            |
| `<build>`         | Integer 0 or greater                            |
| `<release-label>` | One of the following: `alpha`, `beta`, `rc`     |
| `<release-build>` | Integer 0 or greater                            |
| `<release-note>`  | One or more characters: `a-z`, `0-9`, `-`, `.`  |


## Version Formats
The following are the version formats to be recognized by the action:

### Production Release Formats:
```
<major>.<minor>
<major>.<minor>.<patch>
<major>.<minor>.<patch>.<build>
```

### Pre-Release Formats:
```
<major>.<minor>-<release-label>
<major>.<minor>.<patch>-<release-label>
<major>.<minor>.<patch>.<build>-<release-label>

<major>.<minor>-<release-label>.<release-build>
<major>.<minor>.<patch>-<release-label>.<release-build>
<major>.<minor>.<patch>.<build>-<release-label>.<release-build>

<major>.<minor>-<release-label>+<release-note>
<major>.<minor>.<patch>-<release-label>+<release-note>
<major>.<minor>.<patch>.<build>-<release-label>+<release-note>

<major>.<minor>-<release-label>.<release-build>+<release-note>
<major>.<minor>.<patch>-<release-label>.<release-build>+<release-note>
<major>.<minor>.<patch>.<build>-<release-label>.<release-build>+<release-note>
```

### Special Release Format:

```
<major>.<minor>+<release-note>
<major>.<minor>.<patch>+<release-note>
<major>.<minor>.<patch>.<build>+<release-note>
```

Rules for each component in the versions.
<major>         = number 0 greater
<minor>         = number 0 or greater
<patch>         = number 0 or greater
<build>         = number 0 or greater
<release-label> = alpha | beta | rc
<release-build> = number 0 or greater
<release-note>  = one or more characters a-z, 0-9, -, and .

I would like to load versions to objects like:
class QucikVersionRelease {
    [int]$Major
    [int]$Minor
    [int]$Patch
    [int]$Build
    [string]$ReleaseLabel
    [int]$ReleaseBuild
    [string]ReleaseNote$
}

I would like to load the matched conventional commit messages extracted from the commit comments to objects like:
class QucikVersionMessage {
    [string]$Type
    [string]$Message
}

Once the versions and messages are loaded I need to determine the following:

[QucikVersionRelease]$lastVersion = The highest version in a Production Release Formats
[QucikVersionRelease]$nextVersionMajor = Next major version, e.g., if lastVersion is 1.2.3.4 then nextVersionMajor would be 2.0.0.0.
[QucikVersionRelease]$nextVersionMinor = Next minor version, e.g., if lastVersion is 1.2.3.4 then nextVersionMinor would be 1.3.0.0.
[QucikVersionRelease]$nextVersionPatch = Next patch version, e.g., if lastVersion is 1.2.3.4 then nextVersionPatch would be 1.2.4.0.
[QucikVersionRelease]$nextVersionBuild = Next build version, e.g., if lastVersion is 1.2.3.4 then nextVersionBuild would be 1.2.3.5.






