#!/bin/sh

has_gum="true"

# Check if gum is installed
if ! command -v "gum" 2>&1 >/dev/null 
then
    echo "Gum is not installed. Exiting."
    has_gum="false"
    exit 0
else
    echo "Gum is installed at: $(command -v gum)"
fi

# Check the OS type
if [[ "$(uname)" == "Darwin" ]]; then
    # If on macOS, use gum to select files interactively
    files=$(git status --porcelain)
    selected_files=$(echo "$files" | gum choose --no-limit)

    # If files were selected, stage them
    if [ -n "$selected_files" ]; then
        IFS=$'\n'
        for file in $selected_files; do
            filename=$(echo "$file" | awk '{$1=""; print substr($0, 2)}')
            filename=$(echo "$filename" | sed 's/^"\(.*\)"$/\1/')
            git add "$filename"
            echo "Staged: $filename"
        done
    else
        echo "No files selected."
    fi
else
    # If not on macOS, use git add interactive
    echo "Not on macOS. Starting git add interactive."
    git add -i
fi
# Check if there are staged changes
if git diff --cached --quiet; then
    echo "There are no staged changes."
    exit 0 # Exit with a status of 0 for staged changes
else
    echo "There are staged changes."
fi

vbank_modified=""
if git diff --name-only --cached | grep -q "^test/e2e/vbank/"; then
    vbank_modified="vbank, "
fi

index="$(git diff-index HEAD --name-only --cached | grep -v "^test/e2e/vbank/" | sed 's/.*\///' | sed '$!s/$/,/' | tr '\n' ' ')"
index_trimmed=$(echo $index | xargs)

index_snake_case=$(echo "$index_trimmed" | tr '[:upper:]' '[:lower:]')

# Replace with a single * if length exceeds 50 characters
if [ ${#index_snake_case} -gt 50 ]; then
    index_snake_case="*"
fi

# Get the current branch name
branch=$(git rev-parse --abbrev-ref HEAD)

# Extract the ticket number using sed
ticket=$(echo "$branch" | sed 's/.*\/\([A-Z]*-[0-9]*\)-.*/\1/')

# Optional: Print the extracted ticket
echo "Extracted ticket: $ticket"

result="feat($index_snake_case$vbank_modified): $commit_message [$ticket]"

MESSAGE=$(gum input --placeholder "this commit adds..." --header "Describe the change-->")

TYPE=$(gum choose "feat" "chore" "fix" "docs" "test" "style" "refactor" "revert" --header "Choose a type of commit-->")
SCOPE=$(gum input --value "$vbank_modified$index_snake_case" --header "Adjust the files changed-->")

test -n "$SCOPE" && SCOPE="($SCOPE)"

SUMMARY="$TYPE$SCOPE: $MESSAGE [$ticket]"

echo "FINAL COMMIT: $SUMMARY"

gum confirm "Commit changes?" && git commit -m "$SUMMARY"
gum confirm "Push changes?" && git push
