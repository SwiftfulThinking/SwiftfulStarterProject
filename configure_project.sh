#!/bin/bash
#
# configure_project.sh
#
# Creates a NEW project from this SwiftfulStarterProject template, letting you
# EXCLUDE optional features you don't want. The template itself is never modified
# (everything happens in a fresh copy at ../<NewProjectName>).
#
# Optional features (offered interactively):
#   - gamification : Streak / XP / Progress managers + their example screens
#   - abtesting    : AB Testing manager + Dev Settings AB section
#   - analytics    : Firebase Analytics + Crashlytics + Mixpanel logging backends
#                    (Firebase Auth + Firestore always stay; logging falls back to Console only)
#
# Core scaffolding (Auth, User, Logging, Routing, AppState, Purchases, Push,
# Haptics, Sound, TabBar, Onboarding, Settings) is always kept.
#
# Feature coupling in shared files is delimited with marker comments so removal
# is precise and the result still compiles:
#   // #feature-start: <name> ... // #feature-end: <name>   (multi-line block)
#   <code> // #feature: <name>                              (single line)
#   // #feature-not-start: <name> ... // #feature-not-end:  (fallback used when EXCLUDED;
#                                                            its body lines are prefixed "// ~ ")
#
# Usage:
#   ./configure_project.sh <NewProjectName>
#
set -euo pipefail

OLD_NAME="SwiftfulStarterProject"

# ---------------------------------------------------------------------------
# Args / paths
# ---------------------------------------------------------------------------
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <NewProjectName>"
    exit 1
fi
NEW_NAME="$1"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="$(dirname "$SRC_DIR")/$NEW_NAME"

if [ -d "$DEST_DIR" ]; then
    echo "❌ Error: '$DEST_DIR' already exists."
    exit 1
fi

# ---------------------------------------------------------------------------
# Interactive feature menu
# ---------------------------------------------------------------------------
echo ""
echo "🛠  Configuring new project: $NEW_NAME"
echo "    Answer Y to INCLUDE a feature, n to EXCLUDE it. (Enter = include)"
echo "    Core scaffolding is always kept."
echo ""

ask_include() {
    # ask_include "Prompt" -> 0 = include, 1 = exclude
    local prompt="$1" ans
    read -r -p "  Include ${prompt}? [Y/n] " ans </dev/tty || ans="Y"
    case "${ans:-Y}" in
        n|N|no|NO) return 1 ;;
        *)         return 0 ;;
    esac
}

EXCLUDED=()
if [ -n "${CONFIGURE_EXCLUDE+x}" ]; then
    # Non-interactive override (space-separated feature list, or "none"). Useful for CI/tests.
    echo "  (non-interactive: CONFIGURE_EXCLUDE='${CONFIGURE_EXCLUDE}')"
    for feat in ${CONFIGURE_EXCLUDE}; do
        [ "$feat" = "none" ] && continue
        EXCLUDED+=("$feat")
    done
else
    ask_include "Gamification (Streak / XP / Progress)"            || EXCLUDED+=("gamification")
    ask_include "AB Testing / feature flags"                       || EXCLUDED+=("abtesting")
    ask_include "Analytics backends (Firebase Analytics + Crashlytics + Mixpanel)" || EXCLUDED+=("analytics")
fi

echo ""
if [ ${#EXCLUDED[@]} -eq 0 ]; then
    echo "  → Excluding: (none — full template)"
else
    echo "  → Excluding: ${EXCLUDED[*]}"
fi
echo ""

# ---------------------------------------------------------------------------
# Copy template -> new project (exclude VCS, scripts, build artifacts)
# ---------------------------------------------------------------------------
echo "📦 Copying template to $DEST_DIR ..."
rsync -a \
    --exclude=".git" \
    --exclude="rename_project.sh" \
    --exclude="configure_project.sh" \
    --exclude="DerivedData" \
    --exclude="build" \
    --exclude=".swiftpm" \
    "$SRC_DIR/" "$DEST_DIR/"

cd "$DEST_DIR"

# ---------------------------------------------------------------------------
# Strip excluded features from all Swift files (marker engine)
# ---------------------------------------------------------------------------
ENGINE="$(mktemp -t feature_strip.XXXXXX).pl"
cat > "$ENGINE" <<'PERL'
# In-place marker processor. Reads $ENV{EX} (space-separated excluded features).
# Run per-file:  EX="..." perl -i -n engine.pl <file>
BEGIN { %EX = map { $_ => 1 } split /\s+/, ($ENV{EX} // ""); }

# Reset state at the start of each file processed in this run.
if (!defined $CF || $CF ne $ARGV) { $CF = $ARGV; $MODE = ""; }

my $line = $_;
my $code = $line; $code =~ s/\R$//;

if ($code =~ m{//\s*#feature-start:\s*(\w+)}) {
    $MODE = "del" if $EX{$1};      # excluded: swallow block incl. markers
    next;                          # kept: drop marker line, keep body
}
if ($code =~ m{//\s*#feature-end:\s*(\w+)}) {
    $MODE = "" if $MODE eq "del";
    next;
}
if ($code =~ m{//\s*#feature-not-start:\s*(\w+)}) {
    $MODE = $EX{$1} ? "act" : "drop";   # excluded: activate fallback; kept: drop it
    next;
}
if ($code =~ m{//\s*#feature-not-end:\s*(\w+)}) {
    $MODE = "";
    next;
}
next if ($MODE eq "del" || $MODE eq "drop");
if ($MODE eq "act") {
    $line =~ s{^(\s*)//\s*~\s?}{$1};      # uncomment fallback body ( // ~ <code> )
    print $line; next;
}
# Normal line: handle inline single-line marker.
if ($code =~ m{//\s*#feature:\s*(\w+)}) {
    next if $EX{$1};                     # excluded: drop whole line
    $line =~ s{\s*//\s*#feature:\s*\w+\s*(\R?)$}{$1};  # kept: strip trailing marker
    print $line; next;
}
print $line;
PERL

echo "✂️  Stripping feature markers..."
EX_LIST="${EXCLUDED[*]:-}"
# find -print0 reliably NUL-terminates (BSD `grep -lZ` does not). Per-file perl
# invocation so the engine's state machine resets cleanly between files; skip files
# without markers; then `cat -s` collapses 2+ blank-line runs left by block removal
# (SwiftLint vertical_whitespace).
find . -name "*.swift" -type f -print0 | while IFS= read -r -d '' f; do
    grep -q "#feature" "$f" || continue
    EX="$EX_LIST" perl -i -n "$ENGINE" "$f"
    # Collapse 2+ consecutive blank-or-whitespace-only lines (left by block removal)
    # into a single empty line. cat -s won't do this because Xcode "blank" lines
    # often contain indentation whitespace.
    perl -0777 -i -pe 's/\n([ \t]*\n){2,}/\n\n/g' "$f"
done
rm -f "$ENGINE"

# ---------------------------------------------------------------------------
# Delete whole feature folders + collect SPM packages to remove
# ---------------------------------------------------------------------------
PKGS_TO_REMOVE=()
for feat in "${EXCLUDED[@]:-}"; do
    case "$feat" in
        gamification)
            echo "🗑  Removing Gamification managers + example screens..."
            rm -rf "$OLD_NAME/Managers/Gamification" \
                   "$OLD_NAME/Core/StreakExample" \
                   "$OLD_NAME/Core/ExperiencePointsExample" \
                   "$OLD_NAME/Core/ProgressExample"
            PKGS_TO_REMOVE+=("SwiftfulGamification" "SwiftfulGamificationFirebase")
            ;;
        abtesting)
            echo "🗑  Removing AB Testing manager..."
            rm -rf "$OLD_NAME/Managers/ABTests"
            ;;
        analytics)
            echo "🗑  Removing analytics logging backends..."
            PKGS_TO_REMOVE+=("SwiftfulLoggingMixpanel" \
                             "SwiftfulLoggingFirebaseAnalytics" \
                             "SwiftfulLoggingFirebaseCrashlytics")
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Remove SPM package products from the Xcode project (before rename: old name)
# ---------------------------------------------------------------------------
NEED_MANUAL_PKGS=0
if [ ${#PKGS_TO_REMOVE[@]} -gt 0 ]; then
    if ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
        echo "🔌 Removing Swift packages: ${PKGS_TO_REMOVE[*]}"
        PKG_CSV="$(IFS=,; echo "${PKGS_TO_REMOVE[*]}")"
        ruby - "$OLD_NAME.xcodeproj" "$PKG_CSV" <<'RUBY'
require 'xcodeproj'
proj    = Xcodeproj::Project.open(ARGV[0])
remove  = ARGV[1].split(",")

proj.targets.each do |t|
  next unless t.respond_to?(:package_product_dependencies)
  t.package_product_dependencies.dup.each do |dep|
    next unless remove.include?(dep.product_name)
    # Remove the matching framework-link build file, then the product dependency.
    if t.respond_to?(:frameworks_build_phase) && t.frameworks_build_phase
      t.frameworks_build_phase.files.dup.each do |bf|
        bf.remove_from_project if bf.respond_to?(:product_ref) && bf.product_ref == dep
      end
    end
    dep.remove_from_project
  end
end

# Drop any remote package reference that is now orphaned (no product still uses it).
used = proj.targets.flat_map { |t|
  t.respond_to?(:package_product_dependencies) ? t.package_product_dependencies.map(&:package) : []
}.compact
proj.root_object.package_references.dup.each do |ref|
  proj.root_object.package_references.delete(ref) unless used.include?(ref)
end

proj.save
puts "   ✓ Removed: #{remove.join(', ')}"
RUBY
    else
        NEED_MANUAL_PKGS=1
    fi
fi

# ---------------------------------------------------------------------------
# Rename project SwiftfulStarterProject -> NewName (mirrors rename_project.sh)
# ---------------------------------------------------------------------------
echo "✏️  Renaming project to $NEW_NAME ..."
export LC_CTYPE=C

find . -type d -name "*$OLD_NAME*" | while read -r dir; do
    mv "$dir" "$(echo "$dir" | sed "s/$OLD_NAME/$NEW_NAME/g")"
done
find . -type f -name "*$OLD_NAME*" | while read -r file; do
    mv "$file" "$(echo "$file" | sed "s/$OLD_NAME/$NEW_NAME/g")"
done
grep -rl "$OLD_NAME" . 2>/dev/null | while read -r file; do
    sed -i "" "s/$OLD_NAME/$NEW_NAME/g" "$file"
done

# Entitlements + pbxproj signing reference
find . -name "*.entitlements" | while read -r file; do
    mv "$file" "$(echo "$file" | sed "s/$OLD_NAME/$NEW_NAME/g")"
done
PBXPROJ_FILE=$(find . -name "project.pbxproj")
ENTITLEMENTS_FILE="$NEW_NAME/SupportingFiles/$NEW_NAME.entitlements"
if [ -f "$PBXPROJ_FILE" ]; then
    sed -i "" "s/${OLD_NAME}.entitlements/${NEW_NAME}.entitlements/g" "$PBXPROJ_FILE"
    sed -i "" "s|CODE_SIGN_ENTITLEMENTS = .*;|CODE_SIGN_ENTITLEMENTS = $ENTITLEMENTS_FILE;|g" "$PBXPROJ_FILE"
fi

# Bundle display name / identifier
find . -name "Info.plist" | while read -r plist; do
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_NAME" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NEW_NAME" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.example.$NEW_NAME" "$plist" 2>/dev/null || true
done

# Display-name build settings
PROJECT_FILE="./$NEW_NAME.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    sed -i "" "s/StarterProject - Dev/$NEW_NAME - Dev/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject - Mock/$NEW_NAME - Mock/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject/$NEW_NAME/g" "$PROJECT_FILE"
fi

# README + fresh git
cat > README.md <<EOF
# $NEW_NAME

#### 🚀 Created from [SwiftfulStarterProject](https://github.com/SwiftfulThinking/SwiftfulStarterProject) via configure_project.sh
EOF

rm -rf .git
git init -q
git add .
git commit -qm "Initial commit: $NEW_NAME (configured from SwiftfulStarterProject)"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "✅ New project created at: $DEST_DIR"
if [ ${#EXCLUDED[@]} -gt 0 ]; then
    echo "   Excluded: ${EXCLUDED[*]}"
fi
if [ "$NEED_MANUAL_PKGS" -eq 1 ] && [ ${#PKGS_TO_REMOVE[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Ruby 'xcodeproj' gem not found — packages were NOT auto-removed."
    echo "   In Xcode → Project → Package Dependencies, remove:"
    for p in "${PKGS_TO_REMOVE[@]}"; do echo "     • $p"; done
    echo "   (The project still builds with them present; this only trims unused deps.)"
fi
echo ""
echo "   Next: open $NEW_NAME.xcodeproj, select the Mock scheme, and build."
