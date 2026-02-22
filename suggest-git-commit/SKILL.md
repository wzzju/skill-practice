---
name: suggest-git-commit
description: "Generate git commit commands based on file changes or user instructions. Use when you have modified files or when the user asks for a commit suggestion. Triggers: git commit, commit message, generate commit, suggest commit, 提交信息, 生成提交, 自动提交"
---

# Suggest Git Commit

Generates a git commit command based on file changes or user instructions.

## Instructions

### When to Suggest a Commit

Suggest a git commit command when:
1. You have performed file changes (edit, create, delete).
2. The user explicitly asks for a commit suggestion.

Output the command inside a `suggested_git_command` XML tag.

### Format

If no specific format is requested, use the following convention:

`<symbol> <module/topic> - <short description>`

#### Symbols
- `.`: **Minor** (typo, minor fix, comments, cleanup)
- `-`: **Fix** (bug fix)
- `+`: **Addition** (new feature)
- `^`: **Improvement** (enhancement of existing feature)
- `!`: **Breaking Change** (API breaking changes)
- `>`: **Refactor** (code restructuring without behavior change)

### Examples

**Standard Change:**
<suggested_git_command>
git commit -a -m ". chat_response - Fix typos in documentation"
</suggested_git_command>

**New Files (prepend add command):**
<suggested_git_command>
git add -A . && git commit -m "+ user_auth - Add login module"
</suggested_git_command>

### Placement

Place the `suggested_git_command` block at the **top** of your response.
