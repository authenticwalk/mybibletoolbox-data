#!/bin/bash
# Setup sparse checkout with databases included by default
#
# Usage:
#   git clone --filter=blob:none --sparse https://github.com/authenticwalk/mybibletoolbox-data.git
#   cd mybibletoolbox-data
#   ./setup-sparse.sh
#
# Or with specific books:
#   ./setup-sparse.sh JHN ROM GEN

set -e

echo "Setting up sparse checkout..."

# Initialize sparse checkout in cone mode
git sparse-checkout init --cone

# Always include databases (small and useful)
git sparse-checkout set databases

# Add any books passed as arguments
if [ $# -gt 0 ]; then
    for book in "$@"; do
        BOOK=$(echo "$book" | tr '[:lower:]' '[:upper:]')
        echo "Adding commentary/$BOOK..."
        git sparse-checkout add "commentary/$BOOK"
    done
fi

echo ""
echo "Sparse checkout configured:"
git sparse-checkout list
echo ""
echo "Add more content with:"
echo "  git sparse-checkout add commentary/MAT    # Add Matthew"
echo "  git sparse-checkout add strongs           # Add all Strong's"
echo "  git sparse-checkout disable               # Get everything"
