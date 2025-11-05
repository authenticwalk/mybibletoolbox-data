#!/bin/bash

# Fix Strong's concordance directory structure
# Target structure: /strongs/{G|H}{number:04d}/{G|H}{number:04d}-{tool}.strongs.yaml
# Examples: /strongs/G0026/G0026-lexicon.strongs.yaml
#           /strongs/H0157/H0157-usage.strongs.yaml

cd strongs || exit 1

echo "=========================================="
echo "Fixing Strong's directory structure"
echo "Target: {G|H}{number:04d}/{G|H}{number:04d}-{tool}.strongs.yaml"
echo "=========================================="
echo ""

echo "Step 1: Fixing Strong's directory names (G|H + 4-digit padding)..."
for strongs_dir in */; do
    strongs=$(basename "$strongs_dir")
    
    # Extract prefix (G or H) and number
    if [[ "$strongs" =~ ^([GH])([0-9]+)$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        number="${BASH_REMATCH[2]}"
        
        # Check if number needs padding
        if [ ${#number} -ne 4 ]; then
            padded_number=$(printf "%04d" "$number")
            new_strongs="${prefix}${padded_number}"
            echo "  Renaming: $strongs -> $new_strongs"
            
            # If target exists, merge; otherwise rename
            if [ -d "$new_strongs" ]; then
                rsync -a "$strongs_dir" "$new_strongs/"
                rm -rf "$strongs_dir"
            else
                mv "$strongs_dir" "$new_strongs"
            fi
        fi
    # Handle cases where prefix might be lowercase
    elif [[ "$strongs" =~ ^([gh])([0-9]+)$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        number="${BASH_REMATCH[2]}"
        
        # Convert to uppercase and pad
        prefix_upper=$(echo "$prefix" | tr '[:lower:]' '[:upper:]')
        padded_number=$(printf "%04d" "$number")
        new_strongs="${prefix_upper}${padded_number}"
        echo "  Renaming: $strongs -> $new_strongs (uppercase + padding)"
        
        if [ -d "$new_strongs" ]; then
            rsync -a "$strongs_dir" "$new_strongs/"
            rm -rf "$strongs_dir"
        else
            mv "$strongs_dir" "$new_strongs"
        fi
    fi
done

echo ""
echo "Step 2: Fixing filenames inside Strong's directories..."
for strongs_dir in */; do
    strongs=$(basename "$strongs_dir")
    
    # Only process properly formatted directories
    if [[ "$strongs" =~ ^([GH])([0-9]{4})$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        number="${BASH_REMATCH[2]}"
        expected_strongs="${prefix}${number}"
        
        for file in "$strongs_dir"*.yaml; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                
                # Pattern 1: Already has .strongs.yaml - fix Strong's number format
                if [[ "$filename" =~ ^([GHgh])([0-9]+)-(.+)\.strongs\.yaml$ ]]; then
                    file_prefix="${BASH_REMATCH[1]}"
                    file_number="${BASH_REMATCH[2]}"
                    tool="${BASH_REMATCH[3]}"
                    
                    file_prefix_upper=$(echo "$file_prefix" | tr '[:lower:]' '[:upper:]')
                    file_number_padded=$(printf "%04d" "$file_number")
                    new_name="${file_prefix_upper}${file_number_padded}-${tool}.strongs.yaml"
                    
                    if [ "$filename" != "$new_name" ]; then
                        echo "  Renaming: $filename -> $new_name"
                        mv "$file" "$strongs_dir$new_name"
                    fi
                
                # Pattern 2: Has tool but missing .strongs suffix - add it
                elif [[ "$filename" =~ ^([GHgh])([0-9]+)-(.+)\.yaml$ ]]; then
                    file_prefix="${BASH_REMATCH[1]}"
                    file_number="${BASH_REMATCH[2]}"
                    tool="${BASH_REMATCH[3]}"
                    
                    # Skip if tool already contains 'strongs'
                    if [[ "$tool" =~ strongs ]]; then
                        continue
                    fi
                    
                    file_prefix_upper=$(echo "$file_prefix" | tr '[:lower:]' '[:upper:]')
                    file_number_padded=$(printf "%04d" "$file_number")
                    new_name="${file_prefix_upper}${file_number_padded}-${tool}.strongs.yaml"
                    
                    echo "  Renaming: $filename -> $new_name (added .strongs)"
                    mv "$file" "$strongs_dir$new_name"
                
                # Pattern 3: Just Strong's number with tool - needs formatting
                elif [[ "$filename" =~ ^([GHgh])([0-9]+)\.(.+)\.yaml$ ]] || [[ "$filename" =~ ^([GHgh])([0-9]+)_(.+)\.yaml$ ]]; then
                    file_prefix="${BASH_REMATCH[1]}"
                    file_number="${BASH_REMATCH[2]}"
                    tool="${BASH_REMATCH[3]}"
                    
                    file_prefix_upper=$(echo "$file_prefix" | tr '[:lower:]' '[:upper:]')
                    file_number_padded=$(printf "%04d" "$file_number")
                    new_name="${file_prefix_upper}${file_number_padded}-${tool}.strongs.yaml"
                    
                    echo "  Renaming: $filename -> $new_name"
                    mv "$file" "$strongs_dir$new_name"
                fi
            fi
        done
    fi
done

echo ""
echo "Step 3: Cleaning up empty directories..."
find . -type d -empty -delete 2>/dev/null

echo ""
echo "=========================================="
echo "✓ Strong's directory structure fixed!"
echo "✓ Format: {G|H}{number:04d}/{G|H}{number:04d}-{tool}.strongs.yaml"
echo "✓ Example: G0026/G0026-lexicon.strongs.yaml"
echo "=========================================="

