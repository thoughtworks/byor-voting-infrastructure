#!/bin/bash
set -e;

HOOKS_SRC_DIR="${PWD}/.githooks"
HOOKS_DEST_DIR="${PWD}/.git/hooks"

read -e -p "About to enable the git hooks defined in ${HOOKS_SRC_DIR}... are you sure to continue? [Y/n] " response;
if [[ ${response} == n ]]; then
    echo "Aborting on user choice"
    exit 1;
fi

for HOOK in "$( find ${HOOKS_SRC_DIR} -type f)"; do
  cp "${HOOK}" "${HOOKS_DEST_DIR}"
done

echo "Done, git hooks are now enabled in local git repository"
