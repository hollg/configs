#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
package_root="$(mktemp -d)"
target="$(mktemp -d)"
trap 'rm -rf "$package_root" "$target"' EXIT

assert_absent() {
    local path="$1"

    if [[ -e "$path" || -L "$path" ]]; then
        echo "expected $path to be absent" >&2
        exit 1
    fi
}

cp -R "$repo_root/pi" "$package_root/pi"
mkdir -p \
    "$package_root/pi/.pi/agent/sessions" \
    "$package_root/pi/.pi/agent/missions" \
    "$package_root/pi/.pi/agent/npm" \
    "$package_root/pi/.pi/agent/git"
touch \
    "$package_root/pi/.pi/agent/models.json" \
    "$package_root/pi/.pi/agent/models.json.bak" \
    "$package_root/pi/.pi/agent/auth.json" \
    "$package_root/pi/.pi/agent/trust.json" \
    "$package_root/pi/.pi/agent/models-store.json" \
    "$package_root/pi/.pi/agent/sessions/marker" \
    "$package_root/pi/.pi/agent/missions/marker" \
    "$package_root/pi/.pi/agent/npm/marker" \
    "$package_root/pi/.pi/agent/git/marker"

mkdir -p "$target/.pi/agent/agents" "$target/.pi/agent/extensions/pi-rtk-optimizer"
stow --simulate --no-folding --dir "$package_root" --target "$target" pi
stow --no-folding --dir "$package_root" --target "$target" pi

test -L "$target/.pi/agent/settings.json"
test -L "$target/.pi/agent/agents/planner.md"
test -L "$target/.pi/agent/extensions/pi-rtk-optimizer/config.json"
assert_absent "$target/.pi/agent/models.json.example"
test -L "$target/.pi/agent/models.json"
assert_absent "$target/.pi/agent/models.json.bak"
assert_absent "$target/.pi/agent/auth.json"
assert_absent "$target/.pi/agent/trust.json"
assert_absent "$target/.pi/agent/models-store.json"
for path in \
    pi/.pi/agent/models.json \
    pi/.pi/agent/models.json.bak \
    pi/.pi/agent/auth.json \
    pi/.pi/agent/trust.json \
    pi/.pi/agent/models-store.json \
    pi/.pi/agent/sessions/marker \
    pi/.pi/agent/missions/marker \
    pi/.pi/agent/npm/marker \
    pi/.pi/agent/git/marker; do
    git -C "$repo_root" check-ignore -q "$path"
done
for dir in sessions missions npm git; do
    assert_absent "$target/.pi/agent/$dir"
done
