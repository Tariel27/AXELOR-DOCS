#!/bin/bash
OUTPUT_FILE_NAME="Documents.docx"
FILES_TO_EXPORT=$(find . -type f -name "*.md" | sort -r )
pandoc $FILES_TO_EXPORT -o ~/$OUTPUT_FILE_NAME
