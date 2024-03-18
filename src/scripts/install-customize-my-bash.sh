#!/usr/bin/env bash

# Checks the minium version of bash (v3.2) installed,
# stops the installation if check fails
if [ -z "${BASH_VERSION-}" ]; then
  printf "Error: Bash 3.2 or higher is required for Customize My Bash.\n"
  printf "Error: Install Bash and try running this installation script with Bash.\n"
  if command -v bash >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    printf 'Example: \033[31;1mbash\033[0;34m -c "$(curl -fsSL https://raw.githubusercontent.com/niteshy/dev-env-setup/master/src/scripts/install.sh)"\n'
  fi
  # shellcheck disable=SC2317
  return 1 >/dev/null 2>&1 || exit 1
fi

if [[ ! ${BASH_VERSINFO[0]-} ]] || ((BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] < 2)); then
  printf "Error: Bash 3.2 required for Customize My Bash.\n" >&2
  printf "Error: Upgrade Bash and try again.\n" >&2
  # shellcheck disable=SC2317
  return 2 &>/dev/null || exit 2
elif ((BASH_VERSINFO[0] < 4)); then
  printf "Warning: Why don't you upgrade your Bash to 4 or higher?\n" >&2
fi

#####
# print_run bash command
#####
function _cmb_install_print_run {
  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$BOLD$GREEN[dryrun]$NORMAL $BOLD$*$NORMAL" >&5
  else
    printf '%s\n' "$BOLD\$ $*$NORMAL" >&5
    command "$@"
  fi
}



#####
# Main function
# - To clone the dev-env-setup repository into local
# -
#####
function _cmb_install_main {

  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  local ncolors=
  if type -P tput &>/dev/null; then
    ncolors=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
  fi

  local RED GREEN YELLOW BLUE BOLD NORMAL
  if [[ -t 1 && $ncolors && $ncolors -ge 8 ]]; then
    RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
    GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
    YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
    BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
    BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
    NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  if [[ ! $DES_REPOSITORY ]]; then
    DES_REPOSITORY=https://github.com/niteshy/dev-env-setup.git
  fi

  if [[ ! $LOCAL_DES_DIR ]]; then
    LOCAL_DES_DIR=~/.des
  fi

  set -e

  if [[ -d $LOCAL_DES_DIR ]]; then
    printf '%s\n' "${YELLOW}You already have Oh My Bash installed.${NORMAL}" >&2
    printf '%s\n' "You'll need to remove '$LOCAL_DES_DIR' if you want to re-install it." >&2
    return 1
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf '%s\n' "${BLUE}Cloning Dev Env Setup...${NORMAL}"
  type -P git &>/dev/null || {
    echo "Error: git is not installed"
    return 1
  }

  # clone the repo
  _cmb_install_print_run git clone --depth=1 "$DES_REPOSITORY" "$LOCAL_DES_DIR" || {
    printf "Error: git clone of dev-env-setup repo failed\n"
    return 1
  }
}


_cmb_install_main "$@" 5>&2
