#!/usr/bin/env bash
# Phase 50: generate out/update.json for the module update channel.
# Version data is derived from the Mesa VERSION file (freedreno_turnip-CI
# parity); the download base comes from RELEASE_BASE in config.sh.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../config.sh"
source "$HERE/lib.sh"

version="$(mesa_version)"
version_code="$(mesa_version_code)"

# Phase 30 stamps the staged module.prop from the same source.  When the
# staging tree exists, make sure update.json advertises the same version as
# the payload that was (or would be) packed.
staged_prop="$WORKDIR/pack-module/module.prop"
if [ -f "$staged_prop" ]; then
    packed_version="$(sed -n 's/^version=//p' "$staged_prop" | head -n 1)"
    packed_code="$(sed -n 's/^versionCode=//p' "$staged_prop" | head -n 1)"
    if [ "$packed_version" != "$version" ] || [ "$packed_code" != "$version_code" ]; then
        die "staged module.prop is stale (version=$packed_version/$packed_code, mesa=$version/$version_code); rerun ./build.sh module"
    fi
fi

mkdir -p "$OUTDIR"
cat > "$OUTDIR/update.json" <<EOF
{
  "version": "$version",
  "versionCode": $version_code,
  "zipUrl": "$RELEASE_BASE/turnip.zip",
  "changelog": "$RELEASE_BASE/changelog.md"
}
EOF

if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$OUTDIR/update.json" >/dev/null || die "generated update.json is invalid"
fi
info "wrote $OUTDIR/update.json (version=$version, versionCode=$version_code)"
