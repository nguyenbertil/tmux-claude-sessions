# tmux-claude-sessions

A tmux sidebar that lists every Claude Code session on your tmux server, with its state. Move with `j`/`k` and press `Enter` to jump to a session.

```
▌ ! needs input
▌   Helpcenter migrationsskript
▌   story 49859
▌   kundo-frontend:1

  ● idle
    Todoist task sync workflow
    dotfiles:2

  ◌ working
    Retro since Monday
    work:2
```

- `! needs input` (red): Claude waits for a permission answer or another question.
- `● idle` (green): Claude finished its turn.
- `◌ working` (dimmed): Claude is busy.

The sessions that need input come first, then the idle sessions, then the busy ones. In each group, the session that has been in its state the longest comes first.

## How it works

The plugin has two parts, and you install both:

1. **A Claude Code plugin** with hooks. Each hook writes the session state to a tmux pane option (`@claude_state`) on the pane where Claude runs. When the session ends, the hook removes the option. When the pane closes, tmux removes the option with the pane.
2. **A tmux plugin.** The toggle key turns the sidebar on in the terminal where you press it. The sidebar sits at the right edge of that terminal's current window, and it moves with the terminal to other windows and sessions. Each terminal has its own sidebar, and terminals that show the same tmux window share one. When a sidebar closes or leaves a window, every pane in that window gets back the width it had before.

## Requirements

- tmux (tested with 3.5a)
- bash
- Claude Code

## Install

### tmux part, with [TPM](https://github.com/tmux-plugins/tpm)

Add the plugin to `~/.tmux.conf`, above the line that runs TPM:

```tmux
set -g @plugin 'nguyenbertil/tmux-claude-sessions'
```

Press `prefix + I` to install it.

### tmux part, without TPM

```sh
git clone https://github.com/nguyenbertil/tmux-claude-sessions ~/.tmux/plugins/tmux-claude-sessions
```

Add this line to `~/.tmux.conf`, then reload the config:

```tmux
run-shell '~/.tmux/plugins/tmux-claude-sessions/claude-sessions.tmux'
```

### Claude Code part

In Claude Code, run:

```
/plugin marketplace add nguyenbertil/tmux-claude-sessions
/plugin install tmux-claude-sessions@tmux-claude-sessions
```

Sessions that run while you install the plugin show up in the sidebar after their next hook event, for example your next prompt.

## Usage

| Key | Where | Action |
|---|---|---|
| `prefix + C-c` | anywhere | Turn the sidebar on or off in this terminal |
| `prefix + C-f` | anywhere | Move focus to the sidebar, and turn it on first when it is off |
| `j` / `k` (or `↓` / `↑`) | sidebar | Move to the next or previous session |
| `Enter` | sidebar | Jump to the selected session |

To leave the sidebar without a jump, use your usual keys that move between panes.

## Options

Set these in `~/.tmux.conf` before the plugin loads:

| Option | Default | Effect |
|---|---|---|
| `@claude-sessions-key` | `C-c` | The key, after the prefix, that opens and closes the sidebar |
| `@claude-sessions-focus-key` | `C-f` | The key, after the prefix, that moves focus to the sidebar and opens it when it is closed |
| `@claude-sessions-width` | `32` | The width of the sidebar, in columns |
| `@claude-sessions-focus` | `on` | `off` keeps the focus on your pane when the toggle key opens the sidebar |

## Limits

- If you change the width of a pane by hand while the sidebar is open, that pane gets its old width back when the sidebar closes.
- If you stop Claude with `Esc` while it works, Claude sends no `Stop` event, so the session shows `working` until your next prompt.
- A session that crashes, or that you stop with `kill -9`, sends no `SessionEnd` event. The sidebar hides it as soon as the pane shows a shell again.
- The sidebar lists only sessions that run inside tmux.
- Two terminals that show the same tmux window share its sidebar. If you turn the sidebar off in one of them, the sidebar stays in that window while the other terminal has it on.
- When you press `Enter` in a shared sidebar, tmux moves the terminal where you last pressed a key.

## License

MIT
