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

# Step 1: Copy the entire parent directory, excluding hidden files (like .git)
echo "Copying parent directory (excluding hidden files)..."
rsync -av --exclude=".git" "../$OLD_PARENT_DIR/" "../$NEW_PARENT_DIR/"

# Step 2: Navigate to the new directory
cd "../$NEW_PARENT_DIR"

# Step 3: Fully reinitialize the Git repository
echo "Reinitializing a fresh Git repository..."
rm -rf .git  # Ensure no remnants of the old Git repository exist
git init > /dev/null 2>&1

# Step 4: Stage all files and create the initial commit
echo "Staging all files..."
git add --all > /dev/null 2>&1

echo "Creating the initial commit..."
git commit -m "Initial commit for $NEW_PARENT_DIR" > /dev/null 2>&1

# Step 5: Force fix the Git index
echo "Force rebuilding Git index..."
rm -f .git/index          # Remove the current index
git add --all > /dev/null 2>&1  # Rebuild the index by restaging all files
git commit --amend --no-edit > /dev/null 2>&1  # Amend the commit with the rebuilt index

# Step 6: Rename directories
echo "Renaming directories..."
find . -type d -name "*$OLD_PARENT_DIR*" | while read dir; do
    new_dir=$(echo "$dir" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$dir" "$new_dir"
done

# Step 7: Rename files
echo "Renaming files..."
find . -type f -name "*$OLD_PARENT_DIR*" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 8: Replace content inside all files
echo "Replacing content inside files..."
export LC_CTYPE=C
grep -rl "$OLD_PARENT_DIR" . | while read file; do
    sed -i "" "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g" "$file"
done

# Step 9: Rename .entitlements files explicitly
echo "Renaming .entitlements files..."
find . -name "*.entitlements" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 10: Update Bundle Display Name and Bundle Identifier in Info.plist
echo "Updating Bundle Display Name and Bundle Identifier..."
INFO_PLIST_FILES=$(find . -name "Info.plist")
for plist in $INFO_PLIST_FILES; do
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_PARENT_DIR" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NEW_PARENT_DIR" "$plist"

    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.example.$NEW_PARENT_DIR" "$plist" 2>/dev/null
done

# Step 11: Update Bundle Display Name in Build Settings
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

echo "New project created as $NEW_PARENT_DIR with a fresh and fixed Git repository!"
