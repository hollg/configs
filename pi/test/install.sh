#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

write_fake_npm() {
    local dir="$1"

    cat > "$dir/npm" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$CALL_LOG"
EOF
    chmod +x "$dir/npm"
}

installed_bin="$temp_root/installed-bin"
mkdir -p "$installed_bin"
write_fake_npm "$installed_bin"
cat > "$installed_bin/pi" <<'EOF'
#!/bin/bash
printf '%s\n' '0.0.0-test'
EOF
chmod +x "$installed_bin/pi"
CALL_LOG="$temp_root/installed.log" PATH="$installed_bin:/usr/bin:/bin" bash "$repo_root/pi/install.sh"
test ! -e "$temp_root/installed.log"

missing_bin="$temp_root/missing-bin"
mkdir -p "$missing_bin"
write_fake_npm "$missing_bin"
CALL_LOG="$temp_root/missing.log" PATH="$missing_bin:/usr/bin:/bin" bash "$repo_root/pi/install.sh"
grep -qx -- 'install -g --ignore-scripts @earendil-works/pi-coding-agent' "$temp_root/missing.log"
