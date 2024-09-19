#!/bin/sh

# Get the list of files without the status symbols
files=$(git status --porcelain)

# Use gum to select files interactively (gum choose --no-limit allows multi-selection)
selected_files=$(echo "$files" | gum choose --no-limit)

# If files were selected, stage them
if [ -n "$selected_files" ]; then
    # Stage each selected file
    IFS=$'\n'

    for file in $selected_files; do
        filename=$(echo "$file" | awk '{$1=""; print substr($0, 2)}')
        filename=$(echo "$filename" | sed 's/^"\(.*\)"$/\1/')

        git add $filename
        echo "Staged: $filename"
    done
else
    echo "No files selected."
fi

has_commits=$(git diff --cached --quiet || echo "yes")

if [ "$has_commits" == "yes" ]; then
    echo "There are staged changes."
else
    exit
fi

vbank_modified=""
if git diff --name-only --cached | grep -q "^test/e2e/vbank/"; then
  vbank_modified="vbank, "
fi

index="$(git diff-index HEAD --name-only --cached | grep -v "^test/e2e/vbank/" | sed 's/.*\///' | sed  '$!s/$/,/' | tr '\n' ' ')"
index_trimmed=$(echo $index | xargs) 

index_snake_case=$(echo "$index_trimmed" | tr '[:upper:]' '[:lower:]')

# Replace with a single * if length exceeds 50 characters
if [ ${#index_snake_case} -gt 50 ]; then
  index_snake_case="*"
fi

branch=$(git rev-parse --abbrev-ref HEAD)
ticket=$(sed 's/.*\/\{1\}\([A-Z]*-[0-9]*\)-.*/\1/' <<<"$branch")

result="feat($index_snake_case$vbank_modified): $commit_message [$ticket]"

MESSAGE=$(gum input --placeholder "this commit adds..." --header "Describe the change-->")

TYPE=$(gum choose "feat" "chore" "fix" "docs" "test" "style" "refactor" "revert" --header "Choose a type of commit-->")
SCOPE=$(gum input --value "$vbank_modified$index_snake_case" --header "Adjust the files changed-->")

test -n "$SCOPE" && SCOPE="($SCOPE)"

SUMMARY="$TYPE$SCOPE: $MESSAGE [$ticket]"

echo "FINAL COMMIT: $SUMMARY"

gum confirm "Commit changes?" && git commit -m "$SUMMARY"
gum confirm "Push changes?" && git push