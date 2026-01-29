#!/bin/bash

# Usage: ./ultimate_compare.sh /path/to/dir1 /path/to/dir2
DIR1="$1"
DIR2="$2"

if [[ ! -d "$DIR1" || ! -d "$DIR2" ]]; then
    echo "Error: Two valid directories must be provided."
    echo "Usage: $0 <DIR1> <DIR2>"
    exit 1
fi

echo "Comparing:"
echo "  DIR1 = $DIR1"
echo "  DIR2 = $DIR2"

echo ""
echo "Step 1: Directory structure comparison..."
STRUCTURE_DIFF=$(diff <(cd "$DIR1" && find . | sort) <(cd "$DIR2" && find . | sort))
if [[ -n "$STRUCTURE_DIFF" ]]; then
    echo "[!] Directory structure differs:"
    echo "$STRUCTURE_DIFF"
else
    echo "[OK] Structures match."
fi

echo ""
echo "Step 2: File content comparison using sha256sum..."
cd "$DIR1"
find . -type f | while read -r file; do
    #echo "$DIR2/$file"


    if [[ -f "$DIR2/$file" ]]; then
        sum1=$(sha256sum "$file" | awk '{print $1}')
        sum2=$(sha256sum "$DIR2/$file" | awk '{print $1}')
        if [[ "$sum1" != "$sum2" ]]; then
            echo "[!] Content mismatch: $file"
        fi
    else
        echo "[!] Missing in DIR2: $file"
    fi
done
cd - >/dev/null

echo ""
echo "Step 3: Permission and timestamp comparison..."
cd "$DIR1"
find . -type f | while read -r file; do
    if [[ -f "$DIR2/$file" ]]; then
        perm1=$(stat -c "%a" "$file")
        perm2=$(stat -c "%a" "$DIR2/$file")
        if [[ "$perm1" != "$perm2" ]]; then
            echo "[!] Permission mismatch: $file ($perm1 vs $perm2)"
        fi

        time1=$(stat -c "%Y" "$file")
        time2=$(stat -c "%Y" "$DIR2/$file")
        if [[ "$time1" != "$time2" ]]; then
            echo "[!] Timestamp mismatch: $file"
        fi
    fi
done
cd - >/dev/null

echo ""
echo "Step 4: Final deep check using rsync checksum mode..."
rsync -nrc "$DIR1/" "$DIR2/" > rsync_diff.log
if [[ -s rsync_diff.log ]]; then
    echo "[!] rsync reports differences:"
    cat rsync_diff.log
else
    echo "[OK] rsync checksum check passed. No differences found."
fi

echo ""
echo "Full comparison complete."

