#!/bin/bash

# iOS Icon Resizer Script
# 
# This script takes a Gemini_generated* icon and resizes it to create
# a complete iOS icon set covering all iPhone and iPad sizes.
# 
# Usage: ./resize_icons.sh [input_icon_path] [output_directory]
# 
# Requirements:
# - ImageMagick (convert command)
# - Input icon should be at least 1024x1024 pixels
# - Output directory will be created if it doesn't exist

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [input_icon_path] [output_directory]"
    echo
    echo "Arguments:"
    echo "  input_icon_path    Path to the Gemini_generated* icon (e.g., Gemini_generated_icon.png)"
    echo "  output_directory   Directory to save the resized icons (default: ios_icons/)"
    echo
    echo "Examples:"
    echo "  $0 Gemini_generated_icon.png"
    echo "  $0 Gemini_generated_icon.png custom_icons/"
    echo
    echo "Requirements:"
    echo "  - ImageMagick (convert command)"
    echo "  - Input icon should be at least 1024x1024 pixels"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command_exists convert; then
        log_error "ImageMagick (convert command) not found"
        log_error "Please install ImageMagick: brew install imagemagick"
        exit 1
    fi
    
    log_success "Prerequisites satisfied"
}

# Function to validate input icon
validate_input_icon() {
    local input_path="$1"
    
    if [ ! -f "$input_path" ]; then
        log_error "Input icon not found: $input_path"
        exit 1
    fi
    
    # Check if it's a valid image
    if ! convert "$input_path" -ping /dev/null 2>/dev/null; then
        log_error "Invalid image file: $input_path"
        exit 1
    fi
    
    # Get image dimensions
    local dimensions=$(convert "$input_path" -ping -format "%wx%h" info:)
    local width=$(echo "$dimensions" | cut -d'x' -f1)
    local height=$(echo "$dimensions" | cut -d'x' -f2)
    
    log_info "Input icon dimensions: ${width}x${height}"
    
    # Check if dimensions are sufficient
    if [ "$width" -lt 1024 ] || [ "$height" -lt 1024 ]; then
        log_warning "Input icon is smaller than 1024x1024. Results may be blurry."
    fi
    
    log_success "Input icon validated"
}

# Function to create output directory
create_output_directory() {
    local output_dir="$1"
    
    if [ ! -d "$output_dir" ]; then
        log_info "Creating output directory: $output_dir"
        mkdir -p "$output_dir"
    fi
    
    log_success "Output directory ready: $output_dir"
}

# Function to resize icon
resize_icon() {
    local input_path="$1"
    local output_path="$2"
    local size="$3"
    local description="$4"
    
    log_info "Creating $description (${size}x${size})..."
    
    if convert "$input_path" -resize "${size}x${size}" -quality 100 "$output_path"; then
        log_success "Created $description"
    else
        log_error "Failed to create $description"
        exit 1
    fi
}

# Function to create all iOS icons
create_ios_icons() {
    local input_path="$1"
    local output_dir="$2"
    
    log_info "Creating iOS icon set..."
    
    # iPhone App Icons
    resize_icon "$input_path" "$output_dir/AppIcon-20@2x.png" 40 "iPhone Settings (20@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-20@3x.png" 60 "iPhone Settings (20@3x)"
    resize_icon "$input_path" "$output_dir/AppIcon-29@2x.png" 58 "iPhone Settings (29@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-29@3x.png" 87 "iPhone Settings (29@3x)"
    resize_icon "$input_path" "$output_dir/AppIcon-40@2x.png" 80 "iPhone Spotlight (40@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-40@3x.png" 120 "iPhone Spotlight (40@3x)"
    resize_icon "$input_path" "$output_dir/AppIcon-60@2x.png" 120 "iPhone App (60@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-60@3x.png" 180 "iPhone App (60@3x)"
    
    # iPad App Icons
    resize_icon "$input_path" "$output_dir/AppIcon-20.png" 20 "iPad Settings (20)"
    resize_icon "$input_path" "$output_dir/AppIcon-20@2x.png" 40 "iPad Settings (20@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-29.png" 29 "iPad Settings (29)"
    resize_icon "$input_path" "$output_dir/AppIcon-29@2x.png" 58 "iPad Settings (29@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-40.png" 40 "iPad Spotlight (40)"
    resize_icon "$input_path" "$output_dir/AppIcon-40@2x.png" 80 "iPad Spotlight (40@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-76.png" 76 "iPad App (76)"
    resize_icon "$input_path" "$output_dir/AppIcon-76@2x.png" 152 "iPad App (76@2x)"
    resize_icon "$input_path" "$output_dir/AppIcon-83.5@2x.png" 167 "iPad Pro App (83.5@2x)"
    
    # App Store Icon
    resize_icon "$input_path" "$output_dir/AppIcon-1024.png" 1024 "App Store (1024)"
    
    # Notification Icons
    resize_icon "$input_path" "$output_dir/NotificationIcon-20@2x.png" 40 "Notification (20@2x)"
    resize_icon "$input_path" "$output_dir/NotificationIcon-20@3x.png" 60 "Notification (20@3x)"
    
    # Watch App Icons (if needed)
    resize_icon "$input_path" "$output_dir/WatchIcon-24@2x.png" 48 "Watch App (24@2x)"
    resize_icon "$input_path" "$output_dir/WatchIcon-27.5@2x.png" 55 "Watch App (27.5@2x)"
    resize_icon "$input_path" "$output_dir/WatchIcon-29@2x.png" 58 "Watch App (29@2x)"
    resize_icon "$input_path" "$output_dir/WatchIcon-33@2x.png" 66 "Watch App (33@2x)"
    resize_icon "$input_path" "$output_dir/WatchIcon-40@2x.png" 80 "Watch App (40@2x)"
    resize_icon "$input_path" "$output_dir/WatchIcon-44@2x.png" 88 "Watch App (44@2x)"
    
    log_success "All iOS icons created successfully!"
}

# Function to create icon set manifest
create_icon_set_manifest() {
    local output_dir="$1"
    local manifest_file="$output_dir/Contents.json"
    
    log_info "Creating icon set manifest..."
    
    cat > "$manifest_file" << 'EOF'
{
  "images" : [
    {
      "filename" : "AppIcon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "AppIcon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "AppIcon-20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-20@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "AppIcon-29.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-29@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-40@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "AppIcon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "AppIcon-76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "AppIcon-83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "AppIcon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    log_success "Icon set manifest created: $manifest_file"
}

# Function to install icons to Flutter project
install_icons_to_flutter() {
    local output_dir="$1"
    local flutter_icons_dir="ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    log_info "Installing icons to Flutter project..."
    
    if [ ! -d "ios/Runner/Assets.xcassets" ]; then
        log_error "Flutter iOS project not found. Please run this script from the Flutter project root."
        exit 1
    fi
    
    # Create AppIcon.appiconset directory
    mkdir -p "$flutter_icons_dir"
    
    # Copy icons
    cp "$output_dir"/*.png "$flutter_icons_dir/"
    cp "$output_dir/Contents.json" "$flutter_icons_dir/"
    
    log_success "Icons installed to Flutter project: $flutter_icons_dir"
}

# Function to print summary
print_summary() {
    local output_dir="$1"
    local icon_count=$(find "$output_dir" -name "*.png" | wc -l)
    
    echo
    echo "=========================================="
    echo "           ICON RESIZE SUMMARY"
    echo "=========================================="
    echo "Output Directory: $output_dir"
    echo "Icons Created: $icon_count"
    echo "Manifest: Contents.json"
    echo "=========================================="
    log_success "Icon resize completed successfully! 🎉"
    echo
    echo "Next steps:"
    echo "1. Review the generated icons in: $output_dir"
    echo "2. Copy icons to your Flutter project: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
    echo "3. Run: flutter clean && flutter build ios"
}

# Main execution
main() {
    echo "=========================================="
    echo "        iOS Icon Resizer Script"
    echo "=========================================="
    echo
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_usage
        exit 0
    fi
    
    local input_icon="$1"
    local output_dir="${2:-ios_icons}"
    
    # Check prerequisites
    check_prerequisites
    
    # Validate input
    validate_input_icon "$input_icon"
    
    # Create output directory
    create_output_directory "$output_dir"
    
    # Create all icons
    create_ios_icons "$input_icon" "$output_dir"
    
    # Create manifest
    create_icon_set_manifest "$output_dir"
    
    # Install to Flutter project (optional)
    if [ -d "ios" ]; then
        install_icons_to_flutter "$output_dir"
    fi
    
    # Print summary
    print_summary "$output_dir"
}

# Run main function
main "$@"
