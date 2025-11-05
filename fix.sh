#!/bin/bash

# Fix commentary directory structure
# Target structure: /commentary/{BOOK}/{chapter:03d}/{verse:03d}/{BOOK}-{chapter:03d}-{verse:03d}-{tool}.yaml

cd commentary || exit 1

echo "=========================================="
echo "Fixing commentary directory structure"
echo "Target: {BOOK}/{chapter:03d}/{verse:03d}/{BOOK}-{chapter:03d}-{verse:03d}-{tool}.yaml"
echo "=========================================="
echo ""

echo "Step 1: Fixing chapter directory names (padding with zeros)..."
for book_dir in */; do
    book=$(basename "$book_dir")
    
    # Fix chapter directory names - pad to 3 digits
    for chapter_dir in "$book"/*; do
        if [ -d "$chapter_dir" ]; then
            chapter=$(basename "$chapter_dir")
            
            # If it's a number but not 3 digits, pad it
            if [[ "$chapter" =~ ^[0-9]+$ ]] && [ ${#chapter} -ne 3 ]; then
                padded_chapter=$(printf "%03d" "$chapter")
                echo "  $book: Renaming chapter $chapter -> $padded_chapter"
                
                # If target exists, merge; otherwise rename
                if [ -d "$book/$padded_chapter" ]; then
                    rsync -a "$chapter_dir/" "$book/$padded_chapter/"
                    rm -rf "$chapter_dir"
                else
                    mv "$chapter_dir" "$book/$padded_chapter"
                fi
            fi
        fi
    done
done

echo ""
echo "Step 2: Processing files and organizing into verse subdirectories..."
for book_dir in */; do
    book=$(basename "$book_dir")
    
    for chapter_dir in "$book"/*/; do
        if [ -d "$chapter_dir" ]; then
            chapter=$(basename "$chapter_dir")
            
            # Process all YAML files in chapter directory
            for file in "$chapter_dir"*.yaml; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file")
                    
                    # Extract book, chapter, verse, tool from various filename formats
                    book_code=""
                    ch=""
                    vs=""
                    tool=""
                    
                    # Pattern 1: Underscore format - 1CO_1_001.translations-ebible.yaml
                    if [[ "$filename" =~ ^([A-Z0-9]+)_([0-9]+)_([0-9]+)\.(.+)\.yaml$ ]]; then
                        book_code="${BASH_REMATCH[1]}"
                        ch="${BASH_REMATCH[2]}"
                        vs="${BASH_REMATCH[3]}"
                        tool="${BASH_REMATCH[4]}"
                        echo "  Pattern 1 matched: $filename -> book=$book_code ch=$ch vs=$vs tool=$tool"
                    
                    # Pattern 2: Dot format - 1CO.001.001-translations-ebible.yaml
                    elif [[ "$filename" =~ ^([A-Z0-9]+)\.([0-9]+)\.([0-9]+)-(.+)\.yaml$ ]]; then
                        book_code="${BASH_REMATCH[1]}"
                        ch="${BASH_REMATCH[2]}"
                        vs="${BASH_REMATCH[3]}"
                        tool="${BASH_REMATCH[4]}"
                        echo "  Pattern 2 matched: $filename -> book=$book_code ch=$ch vs=$vs tool=$tool"
                    
                    # Pattern 3: Dash format - MAT-5-3-translations.yaml or MAT-005-003-translations.yaml
                    elif [[ "$filename" =~ ^([A-Z0-9]+)-([0-9]+)-([0-9]+)-(.+)\.yaml$ ]]; then
                        book_code="${BASH_REMATCH[1]}"
                        ch="${BASH_REMATCH[2]}"
                        vs="${BASH_REMATCH[3]}"
                        tool="${BASH_REMATCH[4]}"
                        echo "  Pattern 3 matched: $filename -> book=$book_code ch=$ch vs=$vs tool=$tool"
                    else
                        echo "  WARNING: No pattern matched for: $filename"
                    fi
                    
                    # If we extracted the parts, organize the file
                    if [ -n "$book_code" ] && [ -n "$ch" ] && [ -n "$vs" ] && [ -n "$tool" ]; then
                        # Pad chapter and verse to 3 digits
                        padded_ch=$(printf "%03d" "$ch")
                        padded_vs=$(printf "%03d" "$vs")
                        
                        # Create target directory
                        target_dir="$book_code/$padded_ch/$padded_vs"
                        mkdir -p "$target_dir"
                        
                        # Create new filename
                        new_name="${book_code}-${padded_ch}-${padded_vs}-${tool}.yaml"
                        
                        # Move and rename file
                        echo "  Moving: $filename -> $target_dir/$new_name"
                        mv "$file" "$target_dir/$new_name"
                    fi
                fi
            done
            
            # Also check for verse subdirectories that already exist
            for verse_dir in "$chapter_dir"*/; do
                if [ -d "$verse_dir" ]; then
                    verse=$(basename "$verse_dir")
                    
                    # If it's a numeric directory, fix the verse number padding
                    if [[ "$verse" =~ ^[0-9]+$ ]]; then
                        padded_verse=$(printf "%03d" "$verse")
                        
                        # If verse directory needs padding, rename it
                        if [ ${#verse} -ne 3 ]; then
                            target_verse_dir="$chapter_dir$padded_verse"
                            echo "  Renaming verse dir: $chapter_dir$verse -> $target_verse_dir"
                            
                            if [ -d "$target_verse_dir" ]; then
                                rsync -a "$verse_dir/" "$target_verse_dir/"
                                rm -rf "$verse_dir"
                            else
                                mv "$verse_dir" "$target_verse_dir"
                            fi
                        fi
                        
                        # Now fix filenames inside the verse directory
                        for file in "$chapter_dir$padded_verse/"*.yaml; do
                            if [ -f "$file" ]; then
                                filename=$(basename "$file")
                                
                                # Extract book, chapter, verse, tool from filename
                                book_code=""
                                ch=""
                                vs=""
                                tool=""
                                
                                # Pattern 1: Full format with all parts - BOOK[-._]CHAPTER[-._]VERSE-TOOL.yaml
                                if [[ "$filename" =~ ^([A-Z0-9]+)[-._]([0-9]+)[-._]([0-9]+)[-](.+)\.yaml$ ]]; then
                                    book_code="${BASH_REMATCH[1]}"
                                    ch="${BASH_REMATCH[2]}"
                                    vs="${BASH_REMATCH[3]}"
                                    tool="${BASH_REMATCH[4]}"
                                
                                # Pattern 2: Missing verse in filename - BOOK[-._]CHAPTER-TOOL.yaml
                                # Use the directory's verse number
                                elif [[ "$filename" =~ ^([A-Z0-9]+)[-._]([0-9]+)[-](.+)\.yaml$ ]]; then
                                    book_code="${BASH_REMATCH[1]}"
                                    ch="${BASH_REMATCH[2]}"
                                    vs="$verse"  # Use verse from directory name
                                    tool="${BASH_REMATCH[3]}"
                                    echo "  Note: $filename missing verse number, using directory verse $verse"
                                fi
                                
                                # If we extracted the parts, rename the file
                                if [ -n "$book_code" ] && [ -n "$ch" ] && [ -n "$vs" ] && [ -n "$tool" ]; then
                                    padded_ch=$(printf "%03d" "$ch")
                                    padded_vs=$(printf "%03d" "$vs")
                                    new_name="${book_code}-${padded_ch}-${padded_vs}-${tool}.yaml"
                                    
                                    if [ "$filename" != "$new_name" ]; then
                                        echo "  Renaming: $filename -> $new_name"
                                        mv "$file" "$chapter_dir$padded_verse/$new_name"
                                    fi
                                fi
                            fi
                        done
                    fi
                fi
            done
        fi
    done
done

echo ""
echo "Step 3: Cleaning up empty directories..."
find . -type d -empty -delete 2>/dev/null

echo ""
echo "=========================================="
echo "✓ Directory structure fixed!"
echo "✓ Format: {BOOK}/{chapter:03d}/{verse:03d}/{BOOK}-{chapter:03d}-{verse:03d}-{tool}.yaml"
echo "✓ Example: MAT/005/003/MAT-005-003-translations.yaml"
echo "=========================================="
