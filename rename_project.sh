#!/bin/bash

# Check if a new project name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <NewParentDirectoryName>"
    exit 1
fi

# Set the old and new project names
OLD_PARENT_DIR="SwiftfulStarterProject"
NEW_PARENT_DIR="$1"

# Ensure the new parent directory does not already exist
if [ -d "../$NEW_PARENT_DIR" ]; then
    echo "Error: A directory with the name '$NEW_PARENT_DIR' already exists!"
    exit 1
fi

# Step 1: Copy the entire parent directory, excluding hidden files (like .git) and the script itself
echo "Copying parent directory (excluding hidden files and rename_project.sh)..."
rsync -av --exclude=".git" --exclude="rename_project.sh" "../$OLD_PARENT_DIR/" "../$NEW_PARENT_DIR/"

# Step 2: Navigate to the new directory
cd "../$NEW_PARENT_DIR"

# Step 3: Rename directories
echo "Renaming directories..."
find . -type d -name "*$OLD_PARENT_DIR*" | while read dir; do
    new_dir=$(echo "$dir" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$dir" "$new_dir"
done

# Step 4: Rename files
echo "Renaming files..."
find . -type f -name "*$OLD_PARENT_DIR*" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 5: Replace content inside all files
echo "Replacing content inside files..."
export LC_CTYPE=C
grep -rl "$OLD_PARENT_DIR" . | while read file; do
    sed -i "" "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g" "$file"
done

# Step 6: Rename .entitlements files explicitly
echo "Renaming .entitlements files..."
find . -name "*.entitlements" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 6.5: Update project.pbxproj with new entitlements file reference
echo "Updating .pbxproj to reference renamed entitlements file..."

PBXPROJ_FILE=$(find . -name "project.pbxproj")
ENTITLEMENTS_FILE="$NEW_PARENT_DIR/SupportingFiles/$NEW_PARENT_DIR.entitlements"

if [ -f "$PBXPROJ_FILE" ]; then
    # Replace any reference to old entitlements filename
    sed -i "" "s/${OLD_PARENT_DIR}.entitlements/${NEW_PARENT_DIR}.entitlements/g" "$PBXPROJ_FILE"

    # Explicitly update CODE_SIGN_ENTITLEMENTS in all build configurations
    sed -i "" "s|CODE_SIGN_ENTITLEMENTS = .*;|CODE_SIGN_ENTITLEMENTS = $ENTITLEMENTS_FILE;|g" "$PBXPROJ_FILE"

    echo "Updated CODE_SIGN_ENTITLEMENTS to $ENTITLEMENTS_FILE"
else
    echo "❌ Error: project.pbxproj not found"
fi

# Step 7: Update Bundle Display Name and Bundle Identifier in Info.plist
echo "Updating Bundle Display Name and Bundle Identifier..."
INFO_PLIST_FILES=$(find . -name "Info.plist")
for plist in $INFO_PLIST_FILES; do
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_PARENT_DIR" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NEW_PARENT_DIR" "$plist"

    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.example.$NEW_PARENT_DIR" "$plist" 2>/dev/null
done

# Step 8: Update Bundle Display Name in Build Settings
echo "Updating Bundle Display Name in Build Settings..."
PROJECT_FILE="./$NEW_PARENT_DIR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Replace Display Names for each configuration
    sed -i "" "s/StarterProject - Dev/$NEW_PARENT_DIR - Dev/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject - Mock/$NEW_PARENT_DIR - Mock/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject/$NEW_PARENT_DIR/g" "$PROJECT_FILE"
else
    echo "Error: Could not find project.pbxproj file at $PROJECT_FILE"
fi

# Step 9: Replace README.md with a new one
echo "Replacing README.md with a new one..."
echo "# $NEW_PARENT_DIR" > README.md
echo "
#### 🚀 This project was created from [SwiftfulStarterProject](https://github.com/SwiftfulThinking/SwiftfulStarterProject)!

#### 🚀 Learn how build and use this architecture in the [SwiftUI Advanced Architecture](https://www.swiftful-thinking.com/offers/REyNLwwH) course." >> README.md

# Step 10: Reinitialize Git at the very end
echo "Resetting Git to fix any index issues..."
rm -rf .git  # Remove the existing Git repository
git init      # Reinitialize a fresh Git repository
git add .     # Add all files to the staging area
git commit -m "Fresh Git repository for the new project"  # Create an initial commit

echo "New project created as $NEW_PARENT_DIR with a fresh Git repository!"
