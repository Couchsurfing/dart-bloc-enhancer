#!/bin/bash

# directory should be provided as the first argument
DIR=$1

if [ -z "$DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIR=$(realpath "$DIR")

ROOT=$(dirname "$0")/..
cd "$ROOT" || exit 1

# license blob is located at license_bloc.txt
LICENSE_BLOB=$(cat license_blob.txt)
# replace {YEAR} with current year
LICENSE_BLOB=${LICENSE_BLOB//"{YEAR}"/$(date +"%Y")}

LICENSE_BLOB="/**
$LICENSE_BLOB
*/"

# find all files in the directory recursively
FILES=$(find "$DIR" -type f)

IGNORE_FILES=(.test_optimizer.dart type_checker.dart)
IGNORE_EXT=(.g.dart .config.dart)
IGNORE_DIRS=(/test/)

# iterate over all files
for FILE in $FILES; do
    if ! [[ "$FILE" == *.dart ]]; then
        continue
    fi

    # the license blob is located between "--- LICENSE ---" and "--- LICENSE ---"
    # remove all content within these lines
    sed -i '' '/\/\/ --- LICENSE ---/,/\/\/ --- LICENSE ---/c\''' "$FILE"

    # ignore extension
    for ext in "${IGNORE_EXT[@]}"; do
        if [[ "$FILE" == *"$ext" ]]; then
            continue 2
        fi
    done

    for IGNORE_DIR in "${IGNORE_DIRS[@]}"; do
        if [[ "$FILE" == *"$IGNORE_DIR"* ]]; then
            continue 2
        fi
    done

    for IGNORE_FILE in "${IGNORE_FILES[@]}"; do
        if [[ "$FILE" =~ $IGNORE_FILE ]]; then
            continue 2
        fi
    done

    # if the file does not contain the license blob, add it at the beginning
    if ! grep -q '\/\/ \-\-\- LICENSE \-\-\-' "$FILE"; then
        BLOB_WITH_COMMENTS="// --- LICENSE ---
$LICENSE_BLOB
// --- LICENSE ---"
        echo "$BLOB_WITH_COMMENTS" | cat - "$FILE" >temp && mv temp "$FILE"
    fi
done
