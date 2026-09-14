# Nice & Beautiful Bash Prompt

A stylized, multi-segment Bash prompt built for WSL, with colored "pill" containers for username, directory, file/folder counts, and the current Git branch (color-coded by dirty state).

## Preview

```
╭─ 🐧 you  ~/projects/my-repo  ▰ 3 ≡ 12 🔗 0 ⎇  main
╰ $
```

- Magenta **username** pill with a penguin icon (WSL/Linux indicator)
- Blue **directory** pill showing the current working directory
- Cyan **file-stats** pill showing folder count (▰), file count (≡), and symlink count (🔗)
- **Git branch** pill (⎇) that only appears inside a Git repo — background/foreground turn **yellow** when the repo is dirty, **green** when clean
- Two-line layout with a rounded arrow (`╭─` / `╰`) leading into the prompt

## Installation

1. Open your WSL shell config:
   ```bash
   nano ~/.bashrc
   ```

2. Paste in the script below.

3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

> **Note:** This prompt uses emoji and box-drawing characters (`╭`, `╰`, `▰`, `≡`, `⎇`), so it needs a terminal font with good Unicode/emoji coverage (e.g. a [Nerd Font](https://www.nerdfonts.com/) or Windows Terminal's default Cascadia Code with emoji fallback).

## Full Script

```bash
# ==============================================
# Nice and Beautiful WSL Bash Prompt
# ==============================================

# Prompt
FMT_BOLD="\[\e[1m\]"
FMT_DIM="\[\e[2m\]"
FMT_RESET="\[\e[0m\]"
FMT_UNBOLD="\[\e[22m\]"
FMT_UNDIM="\[\e[22m\]"
FG_BLACK="\[\e[30m\]"
FG_BLUE="\[\e[34m\]"
FG_CYAN="\[\e[36m\]"
FG_GREEN="\[\e[32m\]"
FG_GREY="\[\e[37m\]"
FG_MAGENTA="\[\e[35m\]"
FG_RED="\[\e[31m\]"
FG_WHITE="\[\e[97m\]"
BG_BLACK="\[\e[40m\]"
BG_BLUE="\[\e[44m\]"
BG_CYAN="\[\e[46m\]"
BG_GREEN="\[\e[42m\]"
BG_MAGENTA="\[\e[45m\]"
BG_RED="\[\e[41m\]"

parse_git_bg() {
        [[ $(git status -s 2> /dev/null) ]] && echo -e "\e[43m" || echo -e "\e[42m"
}

parse_git_fg() {
        [[ $(git status -s 2> /dev/null) ]] && echo -e "\e[33m" || echo -e "\e[32m"
}

PS1="\n${FG_BLUE}╭─" # begin arrow to prompt
PS1+="${FG_MAGENTA}" # begin USERNAME container
PS1+="${BG_MAGENTA}${FG_CYAN}${FMT_BOLD} 🐧 " # print OS icon
PS1+="${FG_WHITE}\u" # print username
PS1+="${FMT_UNBOLD} ${FG_MAGENTA}${BG_BLUE} " # end USERNAME container / begin DIRECTORY container
PS1+="${FG_GREY}\w " # print directory
PS1+="${FG_BLUE}${BG_CYAN} " # end DIRECTORY container / begin FILES container
PS1+="${FG_BLACK}"
PS1+="▰ \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) " # print number of folders
PS1+="≡ \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) " # print number of files
PS1+="🔗 \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l) " # print number of symlinks
PS1+="${FMT_RESET}${FG_CYAN}"
PS1+="\$(git branch 2> /dev/null | grep '^*' | colrm 1 2 | xargs -I BRANCH echo -n \"" # check if git branch exists
PS1+="\$(parse_git_bg) " # end FILES container / begin BRANCH container
PS1+="${FG_BLACK}⎇  BRANCH " # print current git branch
PS1+="${FMT_RESET}\$(parse_git_fg)\")\n" # end last container (either FILES or BRANCH)
PS1+="${FG_BLUE}╰ " # end arrow to prompt
PS1+="${FG_CYAN}\\$ " # print prompt
PS1+="${FMT_RESET}"
export PS1
```

## How It Works

| Piece | Purpose |
|---|---|
| `FMT_*` / `FG_*` / `BG_*` variables | Named ANSI escape codes for text formatting, foreground colors, and background colors, wrapped in `\[...\]` so Bash doesn't miscount non-printing characters. |
| `parse_git_bg()` / `parse_git_fg()` | Check `git status -s` — if there are any pending changes, return yellow (background `\e[43m` / foreground `\e[33m`); if clean, return green (`\e[42m` / `\e[32m`). |
| Username segment | Penguin emoji + `\u` (current user) on a magenta pill. |
| Directory segment | `\w` (current working directory) on a blue pill. |
| Files segment | Uses `find` with `-maxdepth 1` to count subdirectories, files, and symlinks in the current directory, shown on a cyan pill. |
| Git branch segment | `git branch | grep '^*'` extracts the active branch name; `colrm 1 2` strips the leading `* ` marker. The whole block is wrapped in a conditional so it **only renders inside a Git repo** — outside one, `git branch` returns nothing and the segment collapses. |
| `╭─` / `╰` | Rounded corner characters that visually frame the two-line prompt. |

## Notes

- **Performance:** The `find` commands re-scan the current directory on every prompt render. In directories with very large file counts, this can make the prompt feel sluggish — if that happens, add `-not -path '*/.*'` or cap depth further, or drop the file-stats segment.
- **WSL-specific styling:** The penguin icon (🐧) is a nod to running Linux inside WSL — feel free to swap it for `` (Nerd Font Linux glyph) or drop it if not on WSL.
- This is a heavier, more "themed" alternative to a minimal prompt — see the companion [minimal Bash + Git prompt](#) if you'd prefer something simpler and lighter-weight.

## License

Free to use, modify, and share.
