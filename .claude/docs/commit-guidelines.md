# Commit Style Guidelines

**Note: Only apply these rules when explicitly asked to "commit"**

When explicitly asked to commit changes:
- Generate commit messages automatically based on staged changes without additional user confirmation
- Commit all changes in a single commit
- Keep commit messages short - only a few words long
- Do NOT include "Co-Authored-By" or any references to Claude/AI in commit messages

---

## Commit Message Format

Use one of these prefixes followed by a brief description:

### `[Feature]` - New Functionality
For new functionality, components, screens, managers, or features.

**Examples:**
- `[Feature] Add user dashboard`
- `[Feature] Add profile card component`
- `[Feature] Add analytics manager`
- `[Feature] Add login screen`

### `[Bug]` - Bug Fixes
For bug fixes, corrections, and resolving issues.

**Examples:**
- `[Bug] Fix login validation`
- `[Bug] Fix memory leak in image loader`
- `[Bug] Fix navigation crash`
- `[Bug] Fix data persistence issue`

### `[Clean]` - Refactoring & Improvements
For refactoring, cleanup, code improvements, or documentation updates.

**Examples:**
- `[Clean] Refactor project manager`
- `[Clean] Update documentation structure`
- `[Clean] Simplify auth flow`
- `[Clean] Remove unused code`

---

## Important Rules

1. **Keep it SHORT**: Only a few words after the prefix
2. **No AI attribution**: Never include "Co-Authored-By: Claude" or similar
3. **Single commit**: Combine all staged changes into one commit
4. **Auto-generate**: Create the message based on the changes without asking the user
5. **Only when asked**: Only apply these rules when user explicitly says "commit"

---

## What to Commit

When user says "commit" or "commit all":
- Stage all modified and new files
- Review the changes to understand what was done
- Generate appropriate commit message based on the changes
- Execute the commit immediately
