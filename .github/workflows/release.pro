name: Release Automation

on:
  push:
    branches:
      - main

permissions:
  contents: write
  id-token: write

jobs:
  create-release:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Extract version number
        id: extract_version
        run: |
          VERSION=$( grep VERSION= simple-script.sh | head -n 1 | awk -F'"' '{print $2}')
          echo "VERSION=$VERSION" >> $GITHUB_ENV
          UPDATE=$( grep VERSION_UPDATED= simple-script.sh | head -n 1 | awk -F'"' '{print $2}')
          echo "UPDATE=$UPDATE" >> $GITHUB_ENV
          UPLOAD=$( grep UPLOAD_TO_ALIREZAZ simple-script.sh | head -n 1 | awk -F '=' '{print $2}')
          echo "UPLOAD=$UPLOAD" >> $GITHUB_ENV
      - name: Get Commit Details
        id: commit_details
        run: |
          COMMIT_TITLE=$(git log -1 --pretty=%s)
          COMMIT_BODY=$(git log -1 --pretty=%b)
          echo "Commit Title: $COMMIT_TITLE"
          echo "Commit Body: $COMMIT_BODY"
          echo "COMMIT_TITLE=$COMMIT_TITLE" >> $GITHUB_ENV
          echo "COMMIT_BODY=$COMMIT_BODY" >> $GITHUB_ENV

      - name: Create release notes
        id: generate_notes
        run: |
          echo "# Version: $VERSION" > release_notes.md
          echo "# Updated: $UPDATE" >> release_notes.md
          echo "# Upload : $UPLOAD  " >> release_notes.md
          echo "If true, it will upload to External Server" >> release_notes.md
          echo "" >> release_notes.md
          echo "## Commit Details" >> release_notes.md
          echo "**Title:** $COMMIT_TITLE" >> release_notes.md
          echo "**Description:** $COMMIT_BODY" >> release_notes.md
          echo "" >> release_notes.md
          echo "## Installation" >> release_notes.md
          echo "curl -k  https://github.com/${{ github.repository }}/releases/download/$VERSION/simple-script.sh | bash" >> release_notes.md
          echo "" >> release_notes.md

      - name: Create simple-github-action.zip
        run: |
          zip -r simple-github-action.zip . -x ".git/*"

      - name: Create release
        uses: softprops/action-gh-release@v1
        with:
          name: ${{ env.VERSION }}
          tag_name: ${{ env.VERSION }}
          body_path: ./release_notes.md
          files: |
            simple-script.sh
            simple-github-action.pdf
            simple-github-action.zip
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}


