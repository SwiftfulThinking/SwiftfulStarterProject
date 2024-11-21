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

# Step 1: Copy the entire parent directory
echo "Copying parent directory..."
cp -R "../$OLD_PARENT_DIR" "../$NEW_PARENT_DIR"

# Step 2: Rename directories first
echo "Renaming directories..."
find "../$NEW_PARENT_DIR" -type d -name "*$OLD_PARENT_DIR*" | while read dir; do
    new_dir=$(echo "$dir" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$dir" "$new_dir"
done

# Step 3: Rename files (after directories)
echo "Renaming files..."
find "../$NEW_PARENT_DIR" -type f -name "*$OLD_PARENT_DIR*" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 4: Replace content inside all files
echo "Replacing content inside files..."
export LC_CTYPE=C
grep -rl "$OLD_PARENT_DIR" "../$NEW_PARENT_DIR" | while read file; do
    sed -i "" "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g" "$file"
done

# Step 5: Rename .entitlements files explicitly
echo "Renaming .entitlements files..."
find "../$NEW_PARENT_DIR" -name "*.entitlements" | while read file; do
    new_file=$(echo "$file" | sed "s/$OLD_PARENT_DIR/$NEW_PARENT_DIR/g")
    mv "$file" "$new_file"
done

# Step 6: Update Bundle Display Name and Bundle Identifier in Info.plist
echo "Updating Bundle Display Name and Bundle Identifier..."
INFO_PLIST_FILES=$(find "../$NEW_PARENT_DIR" -name "Info.plist")
for plist in $INFO_PLIST_FILES; do
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_PARENT_DIR" "$plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NEW_PARENT_DIR" "$plist"

    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.example.$NEW_PARENT_DIR" "$plist" 2>/dev/null
done

# Step 7: Update Bundle Display Name in Build Settings
echo "Updating Bundle Display Name in Build Settings..."
PROJECT_FILE="../$NEW_PARENT_DIR/$NEW_PARENT_DIR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Replace Display Names for each configuration
    sed -i "" "s/StarterProject - Dev/$NEW_PARENT_DIR - Dev/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject - Mock/$NEW_PARENT_DIR - Mock/g" "$PROJECT_FILE"
    sed -i "" "s/StarterProject/$NEW_PARENT_DIR/g" "$PROJECT_FILE"
else
    echo "Error: Could not find project.pbxproj file at $PROJECT_FILE"
fi

echo "New parent directory created as $NEW_PARENT_DIR successfully!"
