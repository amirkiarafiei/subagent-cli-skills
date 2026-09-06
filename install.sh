#!/usr/bin/env bash
#
# Subagent CLI Skills — interactive installer
#
#   Local:  ./install.sh
#   Remote: curl -sSL https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main/install.sh | bash
#
# Portability notes:
#   - Targets bash 3.2 (macOS default): no associative arrays, no mapfile, no ${x,,}.
#   - All keyboard input is read from /dev/tty so it works when piped from curl.

set -o pipefail

REPO_RAW_URL="https://raw.githubusercontent.com/amirkiarafiei/subagent-cli-skills/main"

# ---------------------------------------------------------------- data ------

# Orchestrators and their global skill directories. Index-aligned arrays.
TOOL_NAMES=(
  "Claude Code" "Cursor" "Antigravity" "Codex" "Gemini" "Copilot"
  "Junie" "Kiro" "OpenHands" "OpenCode" "QwenCode" "Mistral Vibe"
  "Kimi Code" "Qoder CLI" "Hermes Agent" "Grok" "Pi" "Oh My Pi"
  "Custom path…"
)
TOOL_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.cursor/skills"
  "$HOME/.gemini/antigravity-cli/skills"
  "$HOME/.agents/skills"
  "$HOME/.gemini/skills"
  "$HOME/.copilot/skills"
  "$HOME/.junie/skills"
  "$HOME/.kiro/skills"
  "$HOME/.openhands/skills/installed"
  "$HOME/.config/opencode/skills"
  "$HOME/.qwen/skills"
  "$HOME/.vibe/skills"
  "$HOME/.kimi/skills"
  "$HOME/.qoder/skills"
  "$HOME/.hermes/skills"
  "$HOME/.grok/skills"
  "$HOME/.pi/agent/skills"
  "$HOME/.omp/agent/skills"
  ""
)

# Available skills, and the CLI binary each one delegates to.
SKILL_NAMES=(
  "antigravity-cli" "gemini-cli" "copilot-cli" "qwen-code" "codex-cli"
  "kiro-cli" "cursor-cli" "junie-cli" "openhands-cli" "opencode-cli"
  "claude-code" "mistral-vibe" "kimi-code" "qoder-cli" "hermes-agent"
  "grok-cli" "devin-cli" "pi-cli" "oh-my-pi"
)
SKILL_HINTS=(
  "agy · Google Antigravity" "gemini · deprecated, still supported"
  "copilot · GitHub Copilot" "qwen · Qwen Code" "codex · OpenAI Codex"
  "kiro-cli · AWS Kiro" "agent · Cursor" "junie · JetBrains Junie"
  "openhands · OpenHands" "opencode · OpenCode" "claude · Claude Code"
  "vibe · Mistral Vibe" "kimi · Kimi Code" "qodercli · Qoder"
  "hermes · Hermes Agent" "grok · xAI Grok" "devin · Devin"
  "pi · Pi" "omp · Oh My Pi"
)

# ------------------------------------------------------- capabilities ------

# Colors, unless disabled or stdout is not a terminal.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
  B=$'\033[1m';  DIM=$'\033[2m';   R=$'\033[0m'; REV=$'\033[7m'
  RED=$'\033[31m';  GRN=$'\033[32m';  YEL=$'\033[33m'
  BLU=$'\033[34m';  CYN=$'\033[36m';  GRY=$'\033[90m'
else
  B=""; DIM=""; R=""; REV=""; RED=""; GRN=""; YEL=""; BLU=""; CYN=""; GRY=""
fi

# Box-drawing only when the locale can render it.
if printf '%s' "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" | grep -qi 'utf-*8'; then
  LINE="─"; ON="◉"; OFF="○"; CHK="▣"; BOX="□"; ARROW="›"; TICK="✓"; CROSS="✗"
  TL="╭"; TR="╮"; BL="╰"; BR="╯"; VT="│"
else
  LINE="-"; ON="(*)"; OFF="( )"; CHK="[x]"; BOX="[ ]"; ARROW=">"; TICK="+"; CROSS="x"
  TL="+"; TR="+"; BL="+"; BR="+"; VT="|"
fi

term_cols() { local c; c=$(tput cols 2>/dev/null) || c=80; [ "$c" -gt 0 ] 2>/dev/null || c=80; printf '%s' "$c"; }
term_rows() { local r; r=$(tput lines 2>/dev/null) || r=24; [ "$r" -gt 0 ] 2>/dev/null || r=24; printf '%s' "$r"; }

hr() {
  local w i out=""
  w=$(term_cols); [ "$w" -gt 78 ] && w=78
  i=0; while [ "$i" -lt "$w" ]; do out="$out$LINE"; i=$((i + 1)); done
  printf '%s%s%s\n' "$GRY" "$out" "$R"
}

say()  { printf '%s\n' "$*"; }
info() { printf '  %s%s%s %s\n' "$CYN" "$ARROW" "$R" "$*"; }
ok()   { printf '  %s%s%s %s\n' "$GRN" "$TICK" "$R" "$*"; }
bad()  { printf '  %s%s%s %s\n' "$RED" "$CROSS" "$R" "$*" >&2; }

banner() {
  local w; w=$(term_cols)
  printf '\n'
  if [ "$w" -ge 70 ]; then
    printf '%s' "$BLU"
    cat <<'EOF'
███████╗██╗   ██╗██████╗  █████╗  ██████╗ ███████╗███╗   ██╗████████╗
██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝
███████╗██║   ██║██████╔╝███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║
╚════██║██║   ██║██╔══██╗██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║
███████║╚██████╔╝██████╔╝██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║
╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝

                        ██████╗ ██╗     ██╗
                       ██╔════╝ ██║     ██║
                       ██║      ██║     ██║
                       ██║      ██║     ██║
                       ╚██████╗ ███████╗██║
                        ╚═════╝ ╚══════╝╚═╝
EOF
    printf '%s' "$R"
  else
    printf '  %s%sSUBAGENT CLI%s\n' "$B" "$BLU" "$R"
  fi
  printf '  %sCross-agent task delegation skills%s\n' "$DIM" "$R"
  hr
}

# --------------------------------------------------------------- input -----

CURSOR_HIDDEN=0
hide_cursor() { [ -t 1 ] || return 0; printf '\033[?25l'; CURSOR_HIDDEN=1; }
show_cursor() { [ "$CURSOR_HIDDEN" -eq 1 ] && printf '\033[?25h'; CURSOR_HIDDEN=0; }

cleanup() { show_cursor; }
on_interrupt() { show_cursor; printf '\n'; bad "Cancelled."; exit 130; }
trap cleanup EXIT
trap on_interrupt INT TERM

# Reads one keypress from the terminal and echoes a symbolic name.
read_key() {
  local k a b seq=""
  IFS= read -rsn1 k <"$TTY" 2>/dev/null || { printf 'eof'; return; }
  case "$k" in
    "")   printf 'enter'; return ;;
    " ")  printf 'space'; return ;;
    $'\t') printf 'tab';  return ;;
    $'\033')
      # Escape, or the start of a CSI/SS3 sequence. Short timeout distinguishes them.
      if ! IFS= read -rsn1 -t 1 a <"$TTY" 2>/dev/null; then printf 'esc'; return; fi
      case "$a" in
        "[" | "O") ;;
        *) printf 'esc'; return ;;
      esac
      while IFS= read -rsn1 -t 1 b <"$TTY" 2>/dev/null; do
        seq="$seq$b"
        case "$b" in [A-Za-z~]) break ;; esac
      done
      case "$seq" in
        A) printf 'up' ;;    B) printf 'down' ;;
        C) printf 'right' ;; D) printf 'left' ;;
        H | "1~") printf 'home' ;;
        F | "4~") printf 'end' ;;
        "5~") printf 'pgup' ;; "6~") printf 'pgdn' ;;
        *) printf 'other' ;;
      esac
      return ;;
    *) printf '%s' "$k"; return ;;
  esac
}

# Re-draws in place: move up N lines, clearing each.
rewind() { local n=$1; [ "$n" -gt 0 ] && printf '\033[%dA\033[J' "$n"; }

# draw_button <label> <focused 0|1> <enabled 0|1> — a framed, 3-line button.
# Bold and boxed even when unfocused, so it reads as a button at a glance.
BTN_W=34
draw_button() {
  local label=$1 focused=$2 enabled=$3
  local len pad l r bar color content i=0
  len=${#label}
  if [ "$len" -gt "$BTN_W" ]; then label=${label:0:$BTN_W}; len=$BTN_W; fi
  pad=$(( (BTN_W - len) / 2 ))
  l=$(printf '%*s' "$pad" '')
  r=$(printf '%*s' $(( BTN_W - len - pad )) '')
  content="${l}${label}${r}"
  bar=""; while [ "$i" -lt "$BTN_W" ]; do bar="${bar}${LINE}"; i=$((i + 1)); done

  if [ "$focused" -eq 1 ]; then
    if [ "$enabled" -eq 1 ]; then color="$GRN$B"; else color="$YEL$B"; fi
  elif [ "$enabled" -eq 1 ]; then
    color="$B"
  else
    color="$GRY"
  fi

  printf '   %s%s%s%s%s\n' "$color" "$TL" "$bar" "$TR" "$R"
  if [ "$focused" -eq 1 ]; then
    printf ' %s %s%s%s%s%s%s%s\n' \
      "$ARROW" "$color" "$VT" "$REV" "$content" "$R$color" "$VT" "$R"
  else
    printf '   %s%s%s%s%s\n' "$color" "$VT" "$content" "$VT" "$R"
  fi
  printf '   %s%s%s%s%s\n' "$color" "$BL" "$bar" "$BR" "$R"
}

# ---------------------------------------------------------------- menus ----

# menu_single "Title" idx_default name... -> sets MENU_CHOICE (index) or -1 to cancel
# Set MENU_SUB beforehand to print a dim explanatory line under the title.
MENU_CHOICE=-1
MENU_SUB=""
menu_single() {
  local title=$1 cur=$2; shift 2
  local items=("$@") n=${#items[@]} drawn=0 i key

  hide_cursor
  while :; do
    rewind "$drawn"; drawn=0
    printf '  %s%s%s\n' "$B" "$title" "$R"; drawn=$((drawn + 1))
    if [ -n "$MENU_SUB" ]; then
      printf '  %s%s%s\n' "$DIM" "$MENU_SUB" "$R"; drawn=$((drawn + 1))
    fi
    printf '\n'; drawn=$((drawn + 1))
    i=0
    while [ "$i" -lt "$n" ]; do
      if [ "$i" -eq "$cur" ]; then
        printf '   %s%s %s %s%s\n' "$CYN$B" "$ON" "${items[$i]}" "$ARROW" "$R"
      else
        printf '   %s%s%s %s\n' "$GRY" "$OFF" "$R" "${items[$i]}"
      fi
      drawn=$((drawn + 1)); i=$((i + 1))
    done
    printf '\n'; drawn=$((drawn + 1))
    printf '   %s↑/↓ move · enter select · q cancel%s\n' "$DIM" "$R"; drawn=$((drawn + 1))

    key=$(read_key)
    case "$key" in
      up | k)   cur=$((cur - 1)); [ "$cur" -lt 0 ] && cur=$((n - 1)) ;;
      down | j) cur=$((cur + 1)); [ "$cur" -ge "$n" ] && cur=0 ;;
      home)     cur=0 ;;
      end)      cur=$((n - 1)) ;;
      enter)
        # Collapse the menu to a two-line record of the choice.
        rewind "$drawn"; show_cursor
        printf '  %s%s%s %s%s%s\n' "$GRN" "$TICK" "$R" "$DIM" "$title" "$R"
        printf '     %s%s%s\n' "$B" "${items[$cur]}" "$R"
        MENU_CHOICE=$cur; return 0 ;;
      q | esc | eof) show_cursor; MENU_CHOICE=-1; return 1 ;;
    esac
  done
}

# menu_multi <context> -> sets MULTI_SELECTED array of indices; returns 1 if cancelled.
#
# The list holds n skill rows plus one focusable Install button pinned underneath.
# Enter on a skill row TOGGLES it; only Enter on the button starts the install.
MULTI_SELECTED=()
menu_multi() {
  local context=$1
  local n=${#SKILL_NAMES[@]}
  local cur=0 top=0 drawn=0 i key win rows count
  local marks=""  # one char per item: 1 = selected

  i=0; while [ "$i" -lt "$n" ]; do marks="${marks}0"; i=$((i + 1)); done

  # Pure-bash string indexing: no subprocess per item per redraw.
  mark_get() { printf '%s' "${marks:$1:1}"; }
  mark_set() { marks="${marks:0:$1}${2}${marks:$(( $1 + 1 ))}"; }
  mark_toggle() {
    if [ "$(mark_get "$1")" = "1" ]; then mark_set "$1" 0; else mark_set "$1" 1; fi
  }
  mark_all() {
    local v=$1 j=0
    marks=""
    while [ "$j" -lt "$n" ]; do marks="${marks}${v}"; j=$((j + 1)); done
  }

  rows=$(term_rows)
  win=$((rows - 16)); [ "$win" -lt 4 ] && win=4; [ "$win" -gt "$n" ] && win="$n"

  hide_cursor
  while :; do
    # Only the skill rows scroll; cur == n is the button, which stays visible.
    if [ "$cur" -lt "$n" ]; then
      [ "$cur" -lt "$top" ] && top=$cur
      [ "$cur" -ge $((top + win)) ] && top=$((cur - win + 1))
    fi

    count=0; i=0
    while [ "$i" -lt "$n" ]; do
      [ "$(mark_get "$i")" = "1" ] && count=$((count + 1))
      i=$((i + 1))
    done

    rewind "$drawn"; drawn=0
    printf '  %sStep 3 of 3 · Select skills to install%s %s(These are the Sub-Agents)%s  %s%d/%d%s\n' \
      "$B" "$R" "$DIM" "$R" "$DIM" "$count" "$n" "$R"; drawn=$((drawn + 1))
    printf '  %s%s%s\n' "$DIM" "$context" "$R"; drawn=$((drawn + 1))
    printf '\n'; drawn=$((drawn + 1))

    i=$top
    while [ "$i" -lt $((top + win)) ] && [ "$i" -lt "$n" ]; do
      local box name hint
      if [ "$(mark_get "$i")" = "1" ]; then box="${GRN}${CHK}${R}"; else box="${GRY}${BOX}${R}"; fi
      name=${SKILL_NAMES[$i]}; hint=${SKILL_HINTS[$i]}
      if [ "$i" -eq "$cur" ]; then
        printf ' %s %s %s%-16s%s %s%s%s\n' "$ARROW" "$box" "$CYN$B" "$name" "$R" "$DIM" "$hint" "$R"
      else
        printf '   %s %-16s %s%s%s\n' "$box" "$name" "$GRY" "$hint" "$R"
      fi
      drawn=$((drawn + 1)); i=$((i + 1))
    done

    if [ "$win" -lt "$n" ]; then
      printf '   %s%d–%d of %d%s\n' "$DIM" $((top + 1)) "$i" "$n" "$R"; drawn=$((drawn + 1))
    fi

    # --- Install button, pinned at the very bottom of the list ---
    printf '\n'; drawn=$((drawn + 1))
    if [ "$count" -gt 0 ]; then
      if [ "$cur" -eq "$n" ]; then
        draw_button "Install $count skill(s)" 1 1
      else
        draw_button "Install $count skill(s)" 0 1
      fi
    else
      if [ "$cur" -eq "$n" ]; then
        draw_button "Select at least one skill" 1 0
      else
        draw_button "Install" 0 0
      fi
    fi
    drawn=$((drawn + 3))

    printf '\n'; drawn=$((drawn + 1))
    printf '   %s↑/↓ move · enter or ←/→ toggle · a all · n none%s\n' \
      "$DIM" "$R"; drawn=$((drawn + 1))
    printf '   %spast the last skill is the Install button · q cancel%s\n' \
      "$DIM" "$R"; drawn=$((drawn + 1))

    key=$(read_key)
    case "$key" in
      up | k)   cur=$((cur - 1)); [ "$cur" -lt 0 ] && cur=$n ;;
      down | j) cur=$((cur + 1)); [ "$cur" -gt "$n" ] && cur=0 ;;
      pgup)     cur=$((cur - win)); [ "$cur" -lt 0 ] && cur=0 ;;
      pgdn)     cur=$((cur + win)); [ "$cur" -gt "$n" ] && cur=$n ;;
      home)     cur=0 ;;
      end)      cur=$n ;;
      a | A)    mark_all 1 ;;
      n | N)    mark_all 0 ;;
      left | right | h | l)
        [ "$cur" -lt "$n" ] && mark_toggle "$cur" ;;
      enter)
        if [ "$cur" -lt "$n" ]; then
          # On a skill row Enter toggles. It must never start the install.
          mark_toggle "$cur"
        elif [ "$count" -gt 0 ]; then
          MULTI_SELECTED=()
          i=0; while [ "$i" -lt "$n" ]; do
            [ "$(mark_get "$i")" = "1" ] && MULTI_SELECTED[${#MULTI_SELECTED[@]}]=$i
            i=$((i + 1))
          done
          rewind "$drawn"; show_cursor
          printf '  %s%s%s %sSelected %d skill(s)%s\n' \
            "$GRN" "$TICK" "$R" "$DIM" "${#MULTI_SELECTED[@]}" "$R"
          return 0
        fi ;;
      q | esc | eof) show_cursor; MULTI_SELECTED=(); return 1 ;;
    esac
  done
}

# ------------------------------------------------------------- fetching ----

# fetch <url> <dest> — writes only on success and refuses empty/HTML bodies.
fetch() {
  local url=$1 dest=$2 tmp
  tmp="${dest}.part.$$"
  if [ "$DOWNLOADER" = "curl" ]; then
    curl -fsSL --retry 2 --connect-timeout 15 "$url" -o "$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  else
    wget -q --tries=2 --timeout=15 -O "$tmp" "$url" 2>/dev/null || { rm -f "$tmp"; return 1; }
  fi
  # Exit 0 is not proof of content: a proxy or 404 page can arrive with status 0.
  if [ ! -s "$tmp" ]; then rm -f "$tmp"; return 1; fi
  if head -c 15 "$tmp" | grep -qi '<!doctype\|<html'; then rm -f "$tmp"; return 1; fi
  mv -f "$tmp" "$dest" || { rm -f "$tmp"; return 1; }
  return 0
}

# install_skill <name> <target_dir> -> 0 installed, 1 failed
install_skill() {
  local skill=$1 base=$2 dir="$2/$1" f
  mkdir -p "$dir" 2>/dev/null || { bad "$skill — cannot create $dir"; return 1; }

  for f in SKILL.md reference.md; do
    if [ "$MODE" = "local" ]; then
      if [ ! -f "skills/$skill/$f" ]; then bad "$skill — missing skills/$skill/$f"; return 1; fi
      cp "skills/$skill/$f" "$dir/$f" 2>/dev/null || { bad "$skill — copy failed ($f)"; return 1; }
    else
      fetch "$REPO_RAW_URL/skills/$skill/$f" "$dir/$f" || { bad "$skill — download failed ($f)"; return 1; }
    fi
  done
  return 0
}

# ----------------------------------------------------------------- main ----

usage() {
  cat <<EOF
Subagent CLI Skills installer

  ./install.sh              interactive install
  ./install.sh -h|--help    this message

Interactive keys: ↑/↓ move · enter or ←/→ toggle · a all · n none · q cancel
Arrow past the last skill to reach the Install button, then press enter.
EOF
}

case "${1:-}" in
  -h | --help) usage; exit 0 ;;
  "") ;;
  *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
esac

# Local checkout or piped from curl?
if [ -d "skills" ]; then MODE="local"; else MODE="remote"; fi

# A downloader is only required in remote mode.
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then DOWNLOADER="wget"; fi
if [ "$MODE" = "remote" ] && [ -z "$DOWNLOADER" ]; then
  bad "Needs curl or wget to download skills. Install one, or clone the repo and run ./install.sh"
  exit 1
fi

# The menus need a real terminal; stdin is a pipe under curl|bash, so use /dev/tty.
TTY="/dev/tty"
if [ ! -r "$TTY" ] || [ ! -t 1 ]; then
  bad "No interactive terminal available."
  say "     This installer is interactive. Clone the repo and run ./install.sh from a terminal,"
  say "     or copy a skill folder manually:  cp -r skills/<name> ~/.claude/skills/"
  exit 1
fi

banner
if [ "$MODE" = "local" ]; then
  info "Local checkout — installing from ./skills"
else
  info "Remote install — downloading from GitHub"
fi
hr
printf '\n'

# 1. Orchestrator ------------------------------------------------------------
MENU_SUB="(This is your Main / Orchestrator Agent)"
if ! menu_single "Step 1 of 3 · Which agent will use these skills?" 0 "${TOOL_NAMES[@]}"; then
  printf '\n'; bad "Cancelled."; exit 130
fi
MENU_SUB=""
tool_idx=$MENU_CHOICE
tool_name=${TOOL_NAMES[$tool_idx]}
target=${TOOL_DIRS[$tool_idx]}

if [ -z "$target" ]; then
  printf '\n  %sEnter the skills directory:%s ' "$B" "$R"
  show_cursor
  IFS= read -r target <"$TTY" || target=""
  # Expand a leading ~ without eval.
  case "$target" in "~") target="$HOME" ;; "~/"*) target="$HOME/${target#\~/}" ;; esac
  if [ -z "$target" ]; then printf '\n'; bad "No path given."; exit 1; fi
fi
printf '\n'; hr; printf '\n'

# 2. Location ----------------------------------------------------------------
if ! menu_single "Step 2 of 3 · Where should they go?" 0 \
  "Global   $target" \
  "Project  ./.skills" \
  "Custom path…"; then
  printf '\n'; bad "Cancelled."; exit 130
fi
case "$MENU_CHOICE" in
  1) target="./.skills" ;;
  2)
    printf '\n  %sEnter the target directory:%s ' "$B" "$R"
    show_cursor
    IFS= read -r target <"$TTY" || target=""
    case "$target" in "~") target="$HOME" ;; "~/"*) target="$HOME/${target#\~/}" ;; esac
    if [ -z "$target" ]; then printf '\n'; bad "No path given."; exit 1; fi ;;
esac
printf '\n'; hr; printf '\n'

# 3. Skills ------------------------------------------------------------------
if ! menu_multi "$tool_name  ·  $target"; then
  printf '\n'; bad "Cancelled — nothing was installed."; exit 130
fi
if [ ${#MULTI_SELECTED[@]} -eq 0 ]; then
  printf '\n'; info "No skills selected — nothing to do."; exit 0
fi
printf '\n'; hr; printf '\n'
printf '  %sInstalling to%s %s\n\n' "$B" "$R" "$target"

# Install --------------------------------------------------------------------
installed=0; failed=0; failed_names=""
for i in "${MULTI_SELECTED[@]}"; do
  skill=${SKILL_NAMES[$i]}
  printf '  %s…%s %s' "$YEL" "$R" "$skill"
  if install_skill "$skill" "$target"; then
    printf '\r\033[2K'; ok "$skill"
    installed=$((installed + 1))
  else
    printf '\033[2K' # the bad() line already reported the reason
    failed=$((failed + 1)); failed_names="$failed_names $skill"
  fi
done

printf '\n'; hr
if [ "$failed" -eq 0 ]; then
  first=${SKILL_NAMES[${MULTI_SELECTED[0]}]}
  printf '  %s%s Installed %d skill(s) to %s%s\n' "$GRN$B" "$TICK" "$installed" "$target" "$R"
  printf '  %sRestart %s to pick them up.%s\n' "$DIM" "$tool_name" "$R"
  printf '\n  %sSmoke test — paste this into %s:%s\n\n' "$B" "$tool_name" "$R"
  printf '    %sUse the %s skill to ping the subagent: ask it to reply with exactly ALIVE%s\n\n' \
    "$CYN" "$first" "$R"
  exit 0
fi
printf '  %s%s %d installed, %d failed:%s%s\n' "$YEL$B" "$ARROW" "$installed" "$failed" "$failed_names" "$R"
printf '  %sRe-run to retry, or copy the folders manually from skills/.%s\n\n' "$DIM" "$R"
exit 1
