#!/bin/bash

# Note that this does not use pipefail
# because if the grep later doesn't match any deleted files,
# which is likely the majority case,
# it does not exit with a 0, and we only care about the final exit.
set -eo

SLUG=${GITHUB_REPOSITORY#*/}

composer install --prefer-dist --no-progress --no-suggest --no-dev

mkdir -p "trunk/$SLUG"

echo "➤ Copying files..."
if [[ -e "$GITHUB_WORKSPACE/.distignore" ]]; then
  echo "ℹ︎ Using .distignore"
  # Copy from current branch to /trunk, excluding assets
  rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" "trunk/$SLUG"
else
  # Copy from current branch to /trunk
  rsync -rc "$GITHUB_WORKSPACE/" "trunk/$SLUG"
fi