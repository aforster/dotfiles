# Sapling (sl) prompt info - shows commit hash, dirty state, and title in RPROMPT
#
# This hooks into the sorin theme by replacing prompt_sorin_precmd to append
# Sapling info after sorin sets RPROMPT.

function prompt_sapling_info {
  # Only run in Sapling repos
  sl root &>/dev/null || return

  local sl_hash sl_title sl_dirty=""

  sl_hash=$(sl log -r . -T '{node|short}' 2>/dev/null) || return
  sl_title=$(sl log -r . -T '{desc|firstline}' 2>/dev/null)

  # Truncate title to 50 chars
  if [[ ${#sl_title} -gt 50 ]]; then
    sl_title="${sl_title[1,47]}..."
  fi

  # Check for uncommitted changes
  if [[ -n "$(sl status 2>/dev/null)" ]]; then
    sl_dirty="%B%F{3}*%f%b"
  fi

  echo -n "%F{6}${sl_hash}%f${sl_dirty} %F{7}${sl_title}%f"
}

# Wrap the original sorin precmd to append sapling info to RPROMPT
if (( ! ${+functions[_original_prompt_sorin_precmd]} )); then
  functions[_original_prompt_sorin_precmd]="${functions[prompt_sorin_precmd]}"
fi

function prompt_sorin_precmd {
  # Run the original sorin precmd (sets RPROMPT, kicks off async git-info)
  _original_prompt_sorin_precmd

  # Append Sapling info to RPROMPT
  local sl_info
  sl_info="$(prompt_sapling_info)"
  if [[ -n "$sl_info" ]]; then
    RPROMPT="${sl_info} ${RPROMPT}"
  fi
}
