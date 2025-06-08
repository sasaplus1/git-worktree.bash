# git-worktree.bash

easy git-worktree

## Installation

```bash
$ curl -o git-worktree.bash https://raw.githubusercontent.com/sasaplus1/git-worktree.bash/main/git-worktree.bash
$ source git-worktree.bash
```

## Usage

```bash
$ gw --help
Usage: gw <subcommand> [args...]

  add <branch>         Add a new worktree for the specified branch
  back                 Go back to the previous worktree
  cd <branch>|-        Change directory to the specified worktree branch
  completion           Show completion script for Bash
  list, ls [--all]     List all worktrees (use --all to show all branches)
  remove, rm <branch>  Remove the specified worktree branch

Usage: gw [option]

  -h, --help           Show this help message
  -v, --version        Show version information
```

## Bash completion

Enable bash completion for the `gw` command:

```bash
# Load completion
source <(gw completion)

# Or add to your .bashrc for permanent setup
echo 'source <(gw completion)' >> ~/.bashrc
```

## Configuration

You can customize the behavior of git-worktree.bash by setting the following environment variables:

### `__GW_DIR`

Directory where worktrees will be created (default: `$HOME/.git-worktrees`)

```bash
export __GW_DIR="/path/to/your/worktrees"
source git-worktree.bash
```

### `__GW_CMD`

Command name alias for the git-worktree tool (default: `gw`)

```bash
export __GW_CMD="worktree"
source git-worktree.bash
# Now you can use 'worktree' instead of 'gw'
```

## License

The MIT license
