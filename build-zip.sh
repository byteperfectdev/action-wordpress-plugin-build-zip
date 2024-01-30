#!/bin/bash

# Note that this does not use pipefail
# because if the grep later doesn't match any deleted files,
# which is likely the majority case,
# it does not exit with a 0, and we only care about the final exit.
set -eo

# Allow some ENV variables to be customized
SLUG=${GITHUB_REPOSITORY#*/}
echo "ℹ︎ SLUG is $SLUG"

SVN_DIR="${HOME}/svn-${SLUG}"
mkdir "$SVN_DIR" && cd "$SVN_DIR"

echo "➤ Copying files..."
if [[ -e "$GITHUB_WORKSPACE/.distignore" ]]; then
	echo "ℹ︎ Using .distignore"
	# Copy from current branch to /trunk, excluding dotorg assets
	# The --delete flag will delete anything in destination that no longer exists in source
	rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" trunk/ --delete --delete-excluded
else 
	echo "ℹ︎ Without .distignore"
	rsync -rc "$GITHUB_WORKSPACE/" trunk/ --delete --delete-excluded
fi

echo "➤ Generating zip file..."
cd "$SVN_DIR/trunk" || exit
zip -r "${GITHUB_WORKSPACE}/${GITHUB_REPOSITORY#*/}.zip" .
echo "zip-path=${GITHUB_WORKSPACE}/${GITHUB_REPOSITORY#*/}.zip" >> "${GITHUB_OUTPUT}"
echo "✓ Zip file generated!"
