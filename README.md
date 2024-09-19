# lazy-commit
This script is designed to streamline the process of staging and committing files using Git. It utilizes gum to provide an interactive UI for selecting files, customizing commit messages, and managing the commit process.

## Features
- Interactive file selection for staging changes using gum choose.
- Automated commit message generation based on the files changed.
- Support for various commit types (e.g., feat, chore, fix) with prompts for commit message details.
- Automated ticket extraction from the current branch name.
- Option to push commits after confirmation.

## Prerequisites
- Git: Ensure you have Git installed and configured.
- Gum: This script depends on the gum utility for interactive prompts. You can install gum by using brew.


## Recommended Usage
Define an alias in your shell config, so it can be used from the root folder of any folder.

```bash
alias lz-cmt="/Users/sergio.cortes/data/scripts/lazy-commit/lazy-commit.sh"
```

After calling the script in a working git environment:
- The script will list modified files in the working directory.
- Select the files to stage for commit.
- After staging, you'll be prompted to enter a commit message and choose a commit type.
- The script will generate the commit message and confirm if you want to commit and push the changes.

## Commit Message Structure
The script follows a standardized commit message format:
```
<type>(<scope>): <message> [<ticket>]
```
type: The type of change (e.g., feat, fix, chore).
scope: The files that were changed, automatically inferred from the staged changes.
message: A brief description of the change provided by the user.
ticket: Extracted from the branch name, assuming the branch follows a format like feature/ABC-123-some-description, as happens in many corporate environments.
Example commit message:

feat(index, vbank): Added new feature to index and vbank [ABC-123]

## Notes
The script assumes your branch names follow a specific format like feature/ABC-123-description, where the ticket number is embedded.
If the total file names exceed 50 characters, the scope in the commit message is replaced with * to keep the message concise.

## License
This script is open-source and available for modification or redistribution under the terms of the MIT license.

## Support
Did you like the script? Consider supporting by donating to my PayPal:

[Donate Here](https://www.paypal.com/donate/?hosted_button_id=5ETRMJCAXCHEN)
