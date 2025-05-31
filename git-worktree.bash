#!/bin/bash
# NOTE: shellcheck needs shebang

### get worktree directory
__gw-get-worktree-dir() {
  command echo -n "${__GW_DIR:-$HOME/.git-worktrees}"
}

### get repository slug
__gw-get-slug() {
  local -r origin="$(command git config --local --get remote.origin.url 2>/dev/null)"
  local slug=

  if [[ "$origin" =~ ^(https|ssh)://[^/]+/([^/]+)/([^/]+) ]]
  then
    slug="${BASH_REMATCH[2]}/${BASH_REMATCH[3]%.git}"
  elif [[ "$origin" =~ ^git@[^:]+:([^/]+)/([^/]+) ]]
  then
    slug="${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
  else
    # local repository is not remote
    local -r repo="$(command basename "$(command git rev-parse --show-toplevel)")"
    slug="local/${repo}"
  fi

  command echo -n "$slug"
}

### add worktree
__gw-add() {
  local -r refs="$1"

  local -r worktree_dir="$(__gw-get-worktree-dir)"
  local -r slug="$(__gw-get-slug)"

  command git worktree add "${worktree_dir}/${slug}/${refs}" "$refs"
}

### back to previous worktree
__gw-back() {
  command popd
}

### change directory to worktree
__gw-cd() {
  local -r refs="$1"

  if [ "$refs" == '-' ]
  then
    __gw-back
  else
    local -r worktree_dir="$(__gw-get-worktree-dir)"
    local -r slug="$(__gw-get-slug)"
    local -r dir="$(command git worktree list | command grep -o "${worktree_dir}/${slug}/${refs}")"
    [ -d "$dir" ] && command pushd "$dir"
  fi
}

### list worktrees
__gw-list() {
  local -r worktree_dir="$(__gw-get-worktree-dir)"
  local -r slug="$(__gw-get-slug)"

  local all=
  [[ "$1" == "--all" || "$1" == "-a" ]] && all=1

  if [ -n "$all" ]
  then
    command git worktree list
  else
    command git worktree list | command grep "${worktree_dir}/${slug}"
    true
  fi
}

### remove worktree
__gw-remove() {
  local -r refs="$1"

  local -r worktree_dir="$(__gw-get-worktree-dir)"
  local -r slug="$(__gw-get-slug)"

  command git worktree remove "${worktree_dir}/${slug}/${refs}"
}

### help for git-worktree
__gw-option-help() {
  # NOTE: Don't remove leading tabs
  cat <<-EOB
		Usage: ${__GW_CMD:-gw} <subcommand> [args...]
		
		  add <branch>         Add a new worktree for the specified branch
		  back                 Go back to the previous worktree
		  cd <branch>|-        Change directory to the specified worktree branch
		  list, ls [--all]     List all worktrees (use --all to show all branches)
		  remove, rm <branch>  Remove the specified worktree branch
		
		Usage: ${__GW_CMD:-gw} [option]
		
		  -h, --help           Show this help message
		  -v, --version        Show version information
	EOB
}

### version of git-worktree
__gw-version() {
  echo 'git-worktree 0.1.0'
}

### main
__gw() {
  local -r subcommand="$1"

  if ! git rev-parse --git-dir >/dev/null 2>&1
  then
    echo 'not a git repository.' >&2
    return 3
  fi

  case "$subcommand" in
    add)
      shift
      __gw-add "$@"
      return $?
      ;;
    back)
      shift
      __gw-back "$@"
      return $?
      ;;
    cd)
      shift
      __gw-cd "$@"
      return $?
      ;;
    list|ls)
      shift
      __gw-list "$@"
      return $?
      ;;
    remove|rm)
      shift
      __gw-remove "$@"
      return $?
      ;;
    -h|--help)
      __gw-option-help "$@"
      return $?
      ;;
    -v|--version)
      __gw-version "$@"
      return $?
      ;;
    *)
      __gw-option-help "$@"
      return 4
      ;;
  esac
}

### completion function for git-worktree
__gw-completion() {
  local cur prev words cword

  # alternative processing if bash-completion is not available
  if ! declare -F _init_completion >/dev/null 2>&1
  then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
  else
    _init_completion || return
  fi

  if ! git rev-parse --git-dir >/dev/null 2>&1
  then
    return 0
  fi

  # completion for subcommands
  if [[ $cword -eq 1 ]]
  then
    COMPREPLY=($(compgen -W "add back cd list ls remove rm" -- "$cur"))
    return 0
  fi

  # completion for subcommand arguments
  case "${words[1]}" in
    add)
      # add - show remote and local branches
      local branches
      branches=$(git branch -a 2>/dev/null | \
        sed 's/^[* ] //' | \
        sed 's|^remotes/||' | \
        grep -v '^HEAD' | \
        grep -v '^origin/HEAD' | \
        sort -u)
      COMPREPLY=($(compgen -W "$branches" -- "$cur"))
      ;;
    cd|remove|rm)
      # cd/remove/rm - worktree's branch names
      local worktrees
      worktrees=$(git worktree list 2>/dev/null | \
        awk 'NR>1 {print $NF}' | \
        sed 's/^\[//' | \
        sed 's/\]$//' | \
        grep -v '^(bare)$')
      COMPREPLY=($(compgen -W "$worktrees" -- "$cur"))
      ;;
  esac
}
complete -F __gw-completion __gw

# shellcheck disable=SC2139
alias "${__GW_CMD:-gw}"='__gw'

# vim:list:ts=2:
