# tmux-beacons

A beacon lights on a tmux pane when Claude Code finishes a response or waits for you. Open the list, pick a pane, and jump to it. A beacon clears when you visit its pane.

| Label | Lit by |
|---|---|
| `done` | Claude finished a response (`Stop`) |
| `permission` | Claude waits for a tool permission (`Notification: permission_prompt`) |
| `question` | Claude asks you a question (`Notification: elicitation_dialog`) |

A beacon is not lit when you already look at the pane. It clears when the pane gets focus, when you submit a prompt in it, or when the pane closes.

## Requirements

- tmux 3.2 or later
- fzf
- Claude Code with plugin support

## Install

### tmux side

Clone the repo and load it from `~/.tmux.conf`:

```sh
git clone https://github.com/amiraminb/tmux-beacons ~/.config/tmux/plugins/tmux-beacons
```

```tmux
run-shell ~/.config/tmux/plugins/tmux-beacons/beacons.tmux
```

Load it after other plugins that call `set-hook -g` without an index on `window-unlinked`, `pane-exited`, `after-kill-pane`, `session-closed` or `pane-focus-in`. An unindexed `set-hook -g` replaces every entry of that hook.

### Claude Code side

```sh
claude plugin marketplace add amiraminb/tmux-beacons
claude plugin install tmux-beacons@tmux-beacons
```

## Usage

| Key | Action |
|---|---|
| `prefix b` | Open the beacons list (full-screen fzf in a temporary window) |
| `prefix B` | Jump to the first beacon in the list |

In the list:

| Key | Action |
|---|---|
| `enter` | Jump to the pane and clear its beacon |
| `ctrl-x` | Clear the beacon, do not jump |
| `ctrl-r` | Clear all beacons |
| `esc` | Close |

## Status bar

Put `#{E:@beacons_status}` in `status-right`:

```tmux
set -g status-right "#{E:@beacons_status}%H:%M"
```

It shows the number of lit beacons, with a trailing space, and hides when no beacon is lit:

```
[✳ 2] 14:15
```

For a custom segment, use `@beacons_count`, the number of lit beacons.

## Options

| Option | Default | Meaning |
|---|---|---|
| `@beacons-key` | `b` | Prefix key for the list |
| `@beacons-jump-key` | `B` | Prefix key to jump to the first beacon |
| `@beacons-icon` | `✳` | Icon in the status segment |
| `@beacons-color` | `default` | Status segment color; `default` uses the `status-style` color |
| `@beacons-order` | `oldest` | List order: `oldest` or `newest` first |
| `@beacons-hook-index` | `42` | Index for the tmux hooks this plugin registers |

Set options before the `run-shell` line.

## Development

```sh
ln -s ~/dev/personal/tmux-beacons ~/.config/tmux/plugins/tmux-beacons
claude --plugin-dir ~/dev/personal/tmux-beacons
```
