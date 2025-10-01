#!/bin/bash

# Flutter-Rust-Julia FFI Template Project Renamer
# Usage: ./scripts/rename_project.sh "NewProjectName" "com.yourname.newproject"

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if arguments are provided
if [ $# -ne 2 ]; then
    print_error "Usage: $0 \"NewProjectName\" \"com.yourname.newproject\""
    print_error "Example: $0 \"MyAwesomeApp\" \"com.johndoe.myawesomeapp\""
    exit 1
fi

NEW_PROJECT_NAME="$1"
NEW_BUNDLE_ID="$2"

# Validate project name (alphanumeric and underscores only)
if [[ ! "$NEW_PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    print_error "Project name must start with a letter and contain only letters, numbers, and underscores"
    exit 1
fi

# Validate bundle ID format
if [[ ! "$NEW_BUNDLE_ID" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]]; then
    print_error "Bundle ID must be in format: com.yourname.projectname (lowercase, dots, no spaces)"
    exit 1
fi

# Current project identifiers
OLD_PROJECT_NAME="my_working_ffi_app"
OLD_BUNDLE_ID="com.example.my_working_ffi_app"
OLD_DISPLAY_NAME="Flutter-Rust-Julia FFI Demo"

print_status "Starting project rename..."
print_status "Old Project Name: $OLD_PROJECT_NAME"
print_status "New Project Name: $NEW_PROJECT_NAME"
print_status "Old Bundle ID: $OLD_BUNDLE_ID"
print_status "New Bundle ID: $NEW_BUNDLE_ID"

# Backup original files
print_status "Creating backup of original files..."
cp pubspec.yaml pubspec.yaml.backup
cp ios/Runner/Info.plist ios/Runner/Info.plist.backup
cp android/app/build.gradle android/app/build.gradle.backup

# Function to replace text in file
replace_in_file() {
    local file="$1"
    local old_text="$2"
    local new_text="$3"
    
    if [ -f "$file" ]; then
        # Use different sed syntax for macOS vs Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|$old_text|$new_text|g" "$file"
        else
            sed -i "s|$old_text|$new_text|g" "$file"
        fi
        print_success "Updated $file"
    else
        print_warning "File not found: $file"
    fi
}

# 1. Update pubspec.yaml
print_status "Updating pubspec.yaml..."
replace_in_file "pubspec.yaml" "name: $OLD_PROJECT_NAME" "name: $NEW_PROJECT_NAME"
replace_in_file "pubspec.yaml" "description: A new Flutter project with Rust and Julia FFI integration" "description: $NEW_PROJECT_NAME - Flutter app with Rust and Julia FFI integration"

# 2. Update iOS Info.plist
print_status "Updating iOS Info.plist..."
replace_in_file "ios/Runner/Info.plist" "$OLD_BUNDLE_ID" "$NEW_BUNDLE_ID"
replace_in_file "ios/Runner/Info.plist" "$OLD_DISPLAY_NAME" "$NEW_PROJECT_NAME"

# 3. Update Android build.gradle
print_status "Updating Android build.gradle..."
replace_in_file "android/app/build.gradle" "applicationId \"$OLD_BUNDLE_ID\"" "applicationId \"$NEW_BUNDLE_ID\""

# 4. Update Android manifest
print_status "Updating Android manifest..."
replace_in_file "android/app/src/main/AndroidManifest.xml" "$OLD_BUNDLE_ID" "$NEW_BUNDLE_ID"

# 5. Update iOS project.pbxproj
print_status "Updating iOS project.pbxproj..."
replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "$OLD_BUNDLE_ID" "$NEW_BUNDLE_ID"
replace_in_file "ios/Runner.xcodeproj/project.pbxproj" "$OLD_PROJECT_NAME" "$NEW_PROJECT_NAME"

# 6. Update Rust Cargo.toml
print_status "Updating Rust Cargo.toml..."
replace_in_file "rust/Cargo.toml" "name = \"$OLD_PROJECT_NAME\"" "name = \"$NEW_PROJECT_NAME\""

# 7. Update Julia Project.toml
print_status "Updating Julia Project.toml..."
replace_in_file "julia/Project.toml" "name = \"JuliaLib$OLD_PROJECT_NAME\"" "name = \"JuliaLib$NEW_PROJECT_NAME\""

# 8. Update main.dart app title
print_status "Updating Flutter app title..."
replace_in_file "lib/main.dart" "title: 'Flutter-Rust-Julia FFI Demo'" "title: '$NEW_PROJECT_NAME'"

# 9. Update test files
print_status "Updating test files..."
find test/ -name "*.dart" -exec sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" {} \;

# 10. Rename Xcode project files (requires Xcode)
print_status "Renaming Xcode project files..."
if command -v xcodebuild &> /dev/null; then
    print_status "Xcode found. You may need to manually rename the project in Xcode:"
    print_status "1. Open ios/Runner.xcworkspace in Xcode"
    print_status "2. Select 'Runner' in project navigator"
    print_status "3. Press Enter and rename to '$NEW_PROJECT_NAME'"
    print_status "4. Update scheme name if needed"
else
    print_warning "Xcode not found. Please manually rename the Xcode project:"
    print_warning "1. Open ios/Runner.xcworkspace in Xcode"
    print_warning "2. Rename 'Runner' project to '$NEW_PROJECT_NAME'"
fi

# 11. Update documentation
print_status "Updating documentation..."
find docs/ -name "*.md" -exec sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" {} \;
find . -name "*.md" -not -path "./.git/*" -exec sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" {} \;

# 12. Clean up build artifacts
print_status "Cleaning build artifacts..."
flutter clean

print_success "Project rename completed successfully!"
print_success "New project name: $NEW_PROJECT_NAME"
print_success "New bundle ID: $NEW_BUNDLE_ID"

print_status "Next steps:"
print_status "1. Run 'flutter pub get' to update dependencies"
print_status "2. Run './run_tests.sh' to verify everything works"
print_status "3. Open ios/Runner.xcworkspace in Xcode to complete iOS setup"
print_status "4. Update code signing in Xcode for your team"
print_status "5. Start building your amazing app!"

print_warning "Backup files created:"
print_warning "- pubspec.yaml.backup"
print_warning "- ios/Runner/Info.plist.backup"
print_warning "- android/app/build.gradle.backup"

print_success "🎉 Your project '$NEW_PROJECT_NAME' is ready to go!"
