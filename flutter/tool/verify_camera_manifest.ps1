param(
    [switch]$RequireMerged
)

$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$appManifestPath = Join-Path $flutterRoot 'android/app/src/main/AndroidManifest.xml'
$appManifest = Get-Content -Raw -LiteralPath $appManifestPath

foreach ($permission in @('RECORD_AUDIO', 'WRITE_EXTERNAL_STORAGE')) {
    $removeRule = 'android:name="android.permission.' + $permission +
        '"\s+tools:node="remove"'
    if ($appManifest -notmatch $removeRule) {
        throw "Missing tools:node=remove rule for $permission"
    }
}

$mergedCandidates = @(
    (Join-Path $flutterRoot 'build/app/intermediates/merged_manifests/debug/processDebugMainManifest/AndroidManifest.xml'),
    (Join-Path $flutterRoot 'build/app/intermediates/merged_manifest/debug/processDebugMainManifest/AndroidManifest.xml'),
    (Join-Path $flutterRoot 'build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml')
) | Where-Object { Test-Path -LiteralPath $_ }

if ($RequireMerged -and $mergedCandidates.Count -eq 0) {
    throw 'No debug merged manifest found. Run flutter build apk --debug first.'
}

foreach ($mergedPath in $mergedCandidates) {
    $merged = Get-Content -Raw -LiteralPath $mergedPath
    foreach ($permission in @('RECORD_AUDIO', 'WRITE_EXTERNAL_STORAGE')) {
        if ($merged -match 'android:name="android.permission.' + $permission + '"') {
            throw "Forbidden permission remains in merged manifest: $permission"
        }
    }
}

Write-Output 'Camera manifest permission boundary verified.'
