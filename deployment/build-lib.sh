#!/bin/bash

# ============================================================================
# build-lib.sh - Build script to create consolidated dist.sh
# ============================================================================

# Function to build consolidated dist.sh from index.sh and its dependencies
build_dist() {
  local output_file="dist.sh"
  local index_file="index.sh"
  
  echo "Building consolidated script: $output_file"
  
  # Check if index.sh exists
  if [[ ! -f "$index_file" ]]; then
    echo "Error: $index_file not found!"
    exit 1
  fi
  
  # Start with shebang and header
  cat > "$output_file" << 'EOF'

EOF

  # Extract all source commands from index.sh dynamically
  echo "Reading source files from $index_file..."
  
  # Get all source lines from index.sh (excluding comments and empty lines)
  local source_files=()
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Check if line contains 'source' command
    if [[ "$line" =~ ^[[:space:]]*source[[:space:]]+([^[:space:]]+) ]]; then
      local source_file="${BASH_REMATCH[1]}"
      source_files+=("$source_file")
    fi
  done < "$index_file"
  
  echo "Found ${#source_files[@]} source files to process:"
  printf "  - %s\n" "${source_files[@]}"
  
  # Process each sourced file dynamically
  for source_file in "${source_files[@]}"; do
    if [[ -f "$source_file" ]]; then
      echo "Processing: $source_file"
      
      # Get filename without path for header
      local filename=$(basename "$source_file")
      
      # Add section header
      echo "# ============================================================================" >> "$output_file"
      echo "# Content from $source_file" >> "$output_file"
      echo "# ============================================================================" >> "$output_file"
      echo "" >> "$output_file"
      
  # Process file content - remove shebang only, keep all source lines
  sed '1{/^#!/d;}' "$source_file" >> "$output_file"
      
      echo "" >> "$output_file"
    else
      echo "Warning: Source file not found: $source_file"
    fi
  done
  
  # Add main script footer
  cat >> "$output_file" << 'EOF'
  
EOF
  # Make the output file executable
  chmod +x "$output_file"
  
  echo "Successfully created $output_file"
  echo "The script is now executable and contains all dependencies."
}

# Function to clean generated files
clean_dist() {
  if [[ -f "dist.sh" ]]; then
    rm -f dist.sh
    echo "Removed dist.sh"
  else
    echo "No dist.sh file to clean"
  fi
}

# Main command handler
case "${1:-build}" in
  build)
    build_dist
    ;;
  clean)
    clean_dist
    ;;
  rebuild)
    clean_dist
    build_dist
    ;;
  help|--help|-h)
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build consolidated dist.sh (default)"
    echo "  clean     - Remove generated dist.sh"
    echo "  rebuild   - Clean and rebuild dist.sh"
    echo "  help      - Show this help message"
    ;;
  *)
    echo "Unknown command: $1"
    echo "Use '$0 help' for available commands"
    exit 1
    ;;
esac
