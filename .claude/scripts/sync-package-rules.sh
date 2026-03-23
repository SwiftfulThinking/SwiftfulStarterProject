#!/bin/bash
# sync-package-rules.sh
# Scans Xcode DerivedData checkouts for actual dependencies, then checks sibling
# repos for matching package names. Only syncs rules for actual dependencies.
# Runs automatically via SessionStart hook.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PARENT_DIR="$(cd "$PROJECT_ROOT/.." && pwd)"
SYNCED_DIR="$PROJECT_ROOT/.claude/rules/synced"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

mkdir -p "$SYNCED_DIR"
rm -f "$SYNCED_DIR"/*.md

synced=0

# Build newline-separated list of actual dependency package names from DerivedData
pkg_names=""
for checkouts_dir in "$DERIVED_DATA/$PROJECT_NAME-"*/SourcePackages/checkouts/; do
    [ -d "$checkouts_dir" ] || continue
    for pkg_dir in "$checkouts_dir"*/; do
        [ -d "$pkg_dir" ] || continue
        pkg_names="$pkg_names$(basename "$pkg_dir")"$'\n'
    done
done

# 1. Scan DerivedData checkouts for rules files
for checkouts_dir in "$DERIVED_DATA/$PROJECT_NAME-"*/SourcePackages/checkouts/; do
    [ -d "$checkouts_dir" ] || continue
    for pkg_dir in "$checkouts_dir"*/; do
        [ -d "$pkg_dir" ] || continue
        for rules_file in "$pkg_dir".claude/*-rules.md; do
            [ -f "$rules_file" ] || continue
            install -m 644 "$rules_file" "$SYNCED_DIR/$(basename "$rules_file")"
            ((synced++))
        done
    done
done

# 2. Scan sibling repos — only if repo name matches an actual dependency
for dir in "$PARENT_DIR"/*/; do
    [ -d "$dir" ] || continue
    dir_name="$(basename "$dir")"
    [ "$(cd "$dir" && pwd)" = "$PROJECT_ROOT" ] && continue
    echo "$pkg_names" | grep -qx "$dir_name" || continue

    for rules_file in "$dir".claude/*-rules.md; do
        [ -f "$rules_file" ] || continue
        install -m 644 "$rules_file" "$SYNCED_DIR/$(basename "$rules_file")"
        ((synced++))
    done
done

echo "Package rules sync: $synced rules copied to .claude/rules/synced/"
