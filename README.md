# Nice & Beautiful Bash Prompt with Git Branch

A colorful, informative Bash prompt (`PS1`) that shows your **username**, **hostname**, **current directory**, **Git branch with dirty-state markers**, and a **red exit-code indicator** when the last command failed.

## Preview

```
username@hostname:~/projects/my-repo (main*)
❯
```

- 🟢 Green username
- 🔵 Blue hostname
- 🟡 Yellow working directory
- 🟣 Magenta Git branch, with status markers:
  - `*` unstaged changes
  - `+` staged changes
  - `?` untracked files
- 🔴 Red `✗` prefix — shown only when the previous command exited with an error
- Two-line layout so long paths never crowd your typing area

## Installation

1. Open your shell config file:
   ```bash
   nano ~/.bashrc      # Linux
   nano ~/.bash_profile # macOS (if not using .bashrc)
   ```

2. Paste in the script below (or see [`bash_prompt.sh`](#full-script) for the raw file).

3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

## Full Script

```bash
# ~/.bashrc

# Colors
RESET="\[\033[0m\]"
BOLD="\[\033[1m\]"
GREEN="\[\033[32m\]"
BLUE="\[\033[34m\]"
YELLOW="\[\033[33m\]"
RED="\[\033[31m\]"
CYAN="\[\033[36m\]"
MAGENTA="\[\033[35m\]"

# Git branch + dirty state function
parse_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    local status=""
    if ! git diff --quiet 2>/dev/null; then
        status="${status}*"   # unstaged changes
    fi
    if ! git diff --cached --quiet 2>/dev/null; then
        status="${status}+"  # staged changes
    fi
    if [ -n "$(git status --porcelain 2>/dev/null | grep '^??')" ]; then
        status="${status}?"  # untracked files
    fi
    echo " (${branch}${status})"
}

# Exit code indicator
exit_code_prompt() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "${RED}✗${RESET} "
    fi
}

# Build the prompt
PS1="${CYAN}\$(exit_code_prompt)${GREEN}\u${RESET}@${BLUE}\h${RESET}:${YELLOW}\w${RESET}${MAGENTA}\$(parse_git_branch)${RESET}\n${BOLD}❯${RESET} "
```

## How It Works

| Piece | Purpose |
|---|---|
| `parse_git_branch()` | Detects if you're inside a Git repo, prints the branch name plus `*`/`+`/`?` markers for unstaged, staged, and untracked changes. |
| `exit_code_prompt()` | Captures `$?` from the previous command and prints a red `✗` if it failed. **Must run first** in `PS1`, before any other command executes and overwrites `$?`. |
| `\[...\]` | Wraps non-printing ANSI escape sequences so Bash correctly counts visible characters — prevents line-wrapping and reverse-search glitches. |
| `PS1` | Assembles everything into the final prompt string, shown on a new line below your path for a clean typing area. |

## Notes

- This is a **Bash-only** solution (relies on `PS1` syntax specific to Bash). For Zsh (macOS default shell), the equivalent uses `PROMPT`/`%F{color}` syntax instead — ask if you'd like that version.
- Want ahead/behind tracking (`↑2 ↓1`) vs. the remote branch, or a two-tone Powerline style with separators? Both are easy extensions to `parse_git_branch()`.

## License

Free to use, modify, and share.
