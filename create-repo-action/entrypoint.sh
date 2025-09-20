#!/bin/bash
set -e

# Create directory for final repository files
mkdir -p ./repo

# Copy all package files to repo directory
find . -type f -name "*.tar.zst" -exec cp {} ./repo/ \;

# Change to repo directory
cd ./repo || exit 1

echo "::group::Adding packages to the repo"

# Create the repository database
repo-add "./${repo_name:?}.db.tar.gz" ./*.tar.zst

echo "::endgroup::"

echo "::group::Signing packages"

# Import GPG key if provided
if [ ! -z "$gpg_key" ]; then
    echo "$gpg_key" | gpg --import
    
    # Set up GPG agent with passphrase if provided
    if [ ! -z "$gpg_passphrase" ]; then
        echo "$gpg_passphrase" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --detach-sig --yes testfile 2>/dev/null || true
        rm -f testfile testfile.sig
    fi
    
    # Sign all packages
    for pkg in *.tar.zst; do
        echo "Signing $pkg"
        if [ ! -z "$gpg_passphrase" ]; then
            echo "$gpg_passphrase" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --detach-sig --yes "$pkg"
        else
            gpg --detach-sig --yes "$pkg"
        fi
    done
    
    # Sign the repository database
    echo "Signing repository database"
    if [ ! -z "$gpg_passphrase" ]; then
        echo "$gpg_passphrase" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --detach-sig --yes "${repo_name:?}.db.tar.gz"
    else
        gpg --detach-sig --yes "${repo_name:?}.db.tar.gz"
    fi
fi

echo "::endgroup::"

echo "Repository created successfully in ./repo/"