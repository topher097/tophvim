# Zellij + Neovim Integration Guide

This document covers how to use Zellij as a terminal multiplexer alongside Neovim, and how the `smart-splits.nvim` and `vim-zellij-navigator` plugins provide seamless navigation between the two.

---

## What is Zellij?

Zellij is a modern terminal multiplexer (like tmux) written in Rust. It lets you split your terminal into panes, tabs, and sessions. Key advantages over tmux:

- **Discoverable UI** — on-screen keybind hints in the status bar
- **Mode-based keybinds** — avoids conflicting with programs like Neovim
- **Floating panes** — overlay terminals for quick tasks
- **Built-in layout system** — KDL config files for reproducible workspaces
- **Session persistence** — detach and reattach, sessions survive SSH drops

### Installation

```bash
# NixOS (already configured in your flake)
nix profile install nixpkgs#zellij

# macOS
brew install zellij

# Cargo
cargo install --locked zellij
```

### Starting Zellij

```bash
zellij              # new session (random name)
zellij -s dev       # named session "dev"
zellij ls           # list active sessions
zellij a dev        # attach to existing session "dev"
zellij a -c dev     # attach if exists, create if not
```

---

## The Zellij UI

```
┌─ tab-bar ───────────────────────────────────────────────┐
│ [session-name]  1:Code  2:Tests  3:Git                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│             Your terminal panes live here                 │
│                                                          │
├─────────────────────────────────────────────────────────┤
│ Ctrl p:Pane  Ctrl t:Tab  Ctrl s:Session  Alt f:Float    │
└─────────────────────────────────────────────────────────┘
```

- **Tab bar** (top): shows session name and tabs
- **Status bar** (bottom): shows available modes and immediate actions

---

## Mode System

Zellij uses modes to avoid conflicting with terminal applications like Neovim. In **Normal mode** (the default), all keys pass through to the running program. You only enter a Zellij mode when you explicitly want to manage panes/tabs/etc.

| Mode     | Enter      | Purpose                            | Exit          |
|----------|------------|------------------------------------|---------------|
| Normal   | Default    | Keys pass through to programs      | —             |
| Pane     | `Ctrl p`   | Split, close, focus panes          | `Esc`/`Enter` |
| Tab      | `Ctrl t`   | Create, switch, close tabs         | `Esc`/`Enter` |
| Resize   | `Ctrl r`   | Resize panes with h/j/k/l          | `Esc`/`Enter` |
| Session  | `Ctrl s`   | Detach, manage sessions            | `Esc`/`Enter` |
| Move     | `Ctrl m`   | Move floating panes                 | `Esc`/`Enter` |
| Scroll   | `Ctrl [`   | Enter scroll/copy mode             | `Esc`/`Enter` |

**Press `Esc` or `Enter` to return to Normal mode from any mode.**

---

## Default Keybinds

### Normal mode (no prefix needed)

| Key        | Action                         |
|------------|--------------------------------|
| `Alt n`    | New pane (auto-placement)      |
| `Alt h/j/k/l` | *(overridden — see below)*  |
| `Alt f`    | Toggle floating pane           |
| `Alt +`/`-`| Resize pane                    |
| `Ctrl q`   | Close focused pane             |

### Pane mode (`Ctrl p` then...)

| Sub-key | Action              |
|---------|----------------------|
| `r`     | Split right          |
| `d`     | Split down           |
| `s`     | Stack pane (vertical)|
| `n`     | New pane             |
| `f`     | Toggle fullscreen    |
| `w`     | Floating pane        |
| `q`     | Close pane           |
| `z`     | Toggle pane frames   |

### Tab mode (`Ctrl t` then...)

| Sub-key | Action              |
|---------|----------------------|
| `n`     | New tab              |
| `h`/`l` | Previous/next tab    |
| `1`–`9` | Jump to tab number   |
| `q`     | Close tab            |
| `s`     | Swap active tab      |

### Resize mode (`Ctrl r` then...)

| Sub-key | Action              |
|---------|----------------------|
| `h`     | Resize left          |
| `j`     | Resize down          |
| `k`     | Resize up            |
| `l`     | Resize right         |
| `+`/`=` | Increase resize step |
| `-`     | Decrease resize step |

### Session mode (`Ctrl s` then...)

| Sub-key | Action              |
|---------|----------------------|
| `d`     | Detach from session  |
| `e`     | Edit scrollback in $EDITOR |
| `s`     | Save session         |

---

## Neovim Integration

### How it works

Three components work together:

1. **Zellij config** (`~/.config/zellij/config.kdl`) — uses the `vim-zellij-navigator` WASM plugin to intercept `Ctrl h/j/k/l` and `Alt h/j/k/l`, routing them intelligently based on whether the current pane is running Neovim.

2. **smart-splits.nvim** (Neovim plugin) — handles directional movement and resizing within Neovim splits, and hands off to the multiplexer (Zellij) when the cursor reaches the edge of the Neovim window.

3. **vim-zellij-navigator** (Zellij WASM plugin) — the Zellij-side plugin that detects whether the focused pane is running Neovim and either sends the keystroke through or performs the Zellij action directly.

### Navigation flow

```
You press Ctrl-h
        │
        ▼
  Zellij intercepts
        │
        ├── Focused pane is Neovim? ──► Send Ctrl-h to Neovim
        │                                    │
        │                                    ├── Another Neovim split left? ──► Move to it
        │                                    └── At edge of Neovim? ──► Tell Zellij to move left
        │
        └── Focused pane is NOT Neovim? ──► Zellij moves focus left
```

The result: you only think in terms of direction (left/right/up/down), not "am I in Vim or Zellij?"

### Configured keybinds

These keybinds work in **both** Zellij and Neovim without thinking about which one you're in:

| Key                  | Action                                    | Scope                    |
|----------------------|-------------------------------------------|--------------------------|
| `Ctrl h`            | Move focus left                           | Neovim splits → Zellij panes → Zellij tabs |
| `Ctrl j`            | Move focus down                           | Same                     |
| `Ctrl k`            | Move focus up                             | Same                     |
| `Ctrl l`            | Move focus right                          | Same                     |
| `Ctrl \`            | Jump to previous pane                     | Neovim splits → Zellij panes |
| `Alt h`             | Resize left                               | Neovim splits → Zellij panes |
| `Alt j`             | Resize down                               | Same                     |
| `Alt k`             | Resize up                                 | Same                     |
| `Alt l`             | Resize right                              | Same                     |
| `<leader><leader>h` | Swap buffer with window to the left       | Neovim only             |
| `<leader><leader>j` | Swap buffer with window below             | Neovim only             |
| `<leader><leader>k` | Swap buffer with window above             | Neovim only             |
| `<leader><leader>l` | Swap buffer with window to the right      | Neovim only             |

### Overridden defaults

The navigator keybinds override some Zellij defaults:

| Key            | Zellij default              | Now does                  | Alternate            |
|----------------|----------------------------|---------------------------|----------------------|
| `Ctrl h`       | SwitchToMode Move          | Navigate left             | `Ctrl m` for Move mode |
| `Ctrl l`       | SwitchToMode Session       | Navigate right            | `Ctrl s` for Session mode |
| `Alt h/j/k/l`  | MoveFocus between panes    | Resize panes              | `Ctrl h/j/k/l` now handles focus movement via the navigator |

---

## Recommended Workflow

### Mental model

```
Zellij Session  →  one project or repo
  Zellij Tab    →  one task context (feature, review, debug)
    Zellij Pane →  one tool (nvim, shell, tests, logs, REPL)
      Neovim Split → two files side-by-side
        Neovim Buffer → one file
```

### Rule of thumb

| Need                        | Use                        |
|-----------------------------|----------------------------|
| Another file to edit        | Neovim buffer (switch with `:b` or picker) |
| Two files visible at once   | Neovim split (`:vsplit`, `:split`) |
| Another terminal tool       | Zellij pane (`Ctrl p` → `r` or `d`) |
| Different task context      | Zellij tab (`Ctrl t` → `n`) |
| Quick one-off command       | Zellij floating pane (`Alt f`) |
| Persistent separate project | Zellij session (`zellij -s project2`) |

### Example workspace

Start a session:

```bash
zellij -s myproject
```

Open Neovim:

```bash
nvim
```

Add a shell pane below for tests:

```
Ctrl p → d
```

Add a git pane to the right of the shell:

```
Ctrl p → r
```

Result:

```
┌─────────────────────────────────┐
│                                 │
│           Neovim                │
│                                 │
├────────────────┬────────────────┤
│    shell       │    git/log     │
└────────────────┴────────────────┘
```

Now navigate between all panes with `Ctrl h/j/k/l` — no matter whether the target is a Neovim split or a Zellij pane.

### Tab layout examples

```
Ctrl t → n       (new tab)

Tab 1 "Code":    Neovim + test runner
Tab 2 "Review":  Neovim (diffview) + git shell
Tab 3 "Docs":    man pages / notes + shell
```

Switch tabs: `Ctrl t` then `h`/`l`, or `1`/`2`/`3` for direct access.

### Inside Neovim

- **Most of the time**: one window, switch buffers with your picker (`:Telescope buffers`, `:b`, etc.)
- **Side-by-side**: `:vsplit` for comparing two files or editing test + implementation
- **Close splits**: `:q` or `<C-w>c` when done — don't accumulate splits
- **Avoid Neovim tabs**: Zellij tabs already serve this role better, giving each tab its own terminal tooling alongside Neovim

### Floating panes

`Alt f` opens a floating terminal overlay. Use it for:

- Quick git commands (`git add -p`, `git rebase -i`)
- Checking a man page
- Running a one-off build or test
- Inspecting a process

Toggle away with `Alt f` again — the floating pane keeps running in the background.

---

## smart-splits.nvim Configuration

The Neovim-side config is in `nvim/plugin/smart-splits.lua`:

```lua
smart_splits.setup {
  multiplexer_integration = 'zellij',
  zellij_move_focus_or_tab = true,
}
```

Key settings:

- **`multiplexer_integration = 'zellij'`** — tells smart-splits to use Zellij as the multiplexer backend. When the cursor is at the edge of Neovim, smart-splits sends navigation/resizing commands to Zellij instead of wrapping inside Neovim.

- **`zellij_move_focus_or_tab = true`** — when moving focus past the edge of the current Zellij tab layout, continues to the next Zellij tab. Without this, movement stops at the tab boundary.

Other available options (not currently set, using defaults):

| Option                       | Default               | Description                                                    |
|-------------------------------|----------------------|----------------------------------------------------------------|
| `ignored_buftypes`           | `{'nofile','quickfix','prompt'}` | Buffer types ignored during resize calculations |
| `ignored_filetypes`          | `{'NvimTree'}`       | File types ignored during resize calculations                 |
| `default_amount`             | `3`                  | Lines/columns to resize by                                    |
| `at_edge`                    | `'wrap'`             | Behavior at Neovim edge: `'wrap'`/`'split'`/`'stop'`/function |
| `float_win_behavior`         | `'previous'`         | How to handle floating windows: `'previous'`/`'mux'`         |
| `move_cursor_same_row`       | `false`              | Keep cursor on same screen row when moving left/right         |
| `cursor_follows_swapped_bufs`| `false`              | Cursor follows buffer after swap                               |
| `disable_multiplexer_nav_when_zoomed` | `true`      | Don't navigate to multiplexer when pane is zoomed (not supported for Zellij) |
| `log_level`                  | `'info'`             | Logging level: `'trace'`/`'debug'`/`'info'`/`'warn'`/`'error'`|

---

## Zellij-side Configuration

The Zellij keybinds are configured in your NixOS flake at `modules/core/tools/zellij/default.nix` using `extraConfig`. The config adds `vim-zellij-navigator` WASM plugin bindings in a `shared_except "locked"` block.

### What `shared_except "locked"` means

The bindings apply in **all modes except locked mode**. Locked mode is a special Zellij mode where no keybinds are processed (everything passes through to the running program). This is the correct scope because:

- In Normal mode: the navigator intercepts Ctrl/Alt+hjkl for smart routing
- In Pane/Tab/Resize/Move modes: the navigator still works so you can use Ctrl-hjkl from within those modes
- In Locked mode: all keys pass through — no Zellij interception at all

### The WASM plugin

The `vim-zellij-navigator` plugin (hosted at `github.com/hiasr/vim-zellij-navigator`) is loaded via `MessagePlugin` directives. Zellij downloads the WASM plugin on first use and caches it. The plugin:

1. Detects whether the current pane is running Neovim (by checking `zellij action list-clients`)
2. If Neovim is running: forwards the keystroke to Neovim, where `smart-splits.nvim` handles it
3. If Neovim is NOT running: performs the Zellij action directly (move focus or resize)

### Troubleshooting

**Movement works in Zellij panes but not Neovim splits**: The `zellij` command may not be on the `$PATH` available to the Zellij process. The navigator plugin uses `zellij action list-clients` to detect Neovim. Check with:

```bash
zellij run -- env    # shows Zellij's PATH
```

**Movement works in Neovim but not Zellij panes**: Ensure the keybinds in `config.kdl` are present. Run:

```bash
zellij setup --check
```

**Alt key not working on macOS**: Some terminals need a config option to treat Option as Alt:
- Alacritty: set `option_as_alt` in alacritty.yml
- Ghostty: set `macos-option-as-alt`

---

## Session Management

```bash
zellij                        # new session (random name)
zellij -s myproject           # named session
zellij ls                     # list sessions
zellij a myproject            # attach to session
zellij a -c myproject         # attach or create
zellij kill-session myproject # kill a session
zellij delete-all-sessions    # clean up
```

Inside a session:
- Detach: `Ctrl s` → `d`
- Session persists after detach — reattach with `zellij a <name>`

---

## Layouts (KDL)

Zellij supports layout files for reproducible workspace setups. Generate a starter:

```bash
zellij setup --dump-layout default > ~/.config/zellij/layouts/my-layout.kdl
```

Example development layout:

```kdl
layout {
    tab name="Code" focus=true {
        pane split_direction="vertical" size="70%" {
            pane command="nvim" focus=true
        }
        pane split_direction="horizontal" {
            pane command="bash" size="50%"
            pane command="bash" size="50%"
        }
    }
    tab name="Git" {
        pane command="lazygit"
    }
}
```

Start with layout:

```bash
zellij -l my-layout
```

---

## Quick Reference Card

```
═══════════════════════════════════════════════════════
  ZELLIJ — Normal Mode
═══════════════════════════════════════════════════════
  Alt n            new pane
  Alt f            toggle floating pane
  Ctrl q           close pane

═══════════════════════════════════════════════════════
  ZELLIJ — Pane Mode (Ctrl p)
═══════════════════════════════════════════════════════
  r                split right
  d                split down
  s                stack pane
  f                fullscreen toggle
  w                floating pane
  q                close pane

═══════════════════════════════════════════════════════
  ZELLIJ — Tab Mode (Ctrl t)
═══════════════════════════════════════════════════════
  n                new tab
  h/l              prev/next tab
  1-9              jump to tab number
  q                close tab

═══════════════════════════════════════════════════════
  ZELLIJ — Other Modes
═══════════════════════════════════════════════════════
  Ctrl r           resize mode (then h/j/k/l)
  Ctrl m           move mode (floating panes)
  Ctrl s           session mode (then d=detach, e=edit scrollback)
  Ctrl [           scroll mode

═══════════════════════════════════════════════════════
  SMART-SPLITS (seamless — works everywhere)
═══════════════════════════════════════════════════════
  Ctrl h/j/k/l     move focus (nvim→zellij→tab)
  Ctrl \           jump to previous pane
  Alt h/j/k/l      resize (nvim or zellij)

═══════════════════════════════════════════════════════
  NEOVIM ONLY (buffer swap)
═══════════════════════════════════════════════════════
  <leader><leader>h/j/k/l   swap buffers between windows

═══════════════════════════════════════════════════════
  ESC or Enter     exit any Zellij mode back to Normal
═══════════════════════════════════════════════════════
```

---

## File Locations

| Component              | File                                                        |
|------------------------|-------------------------------------------------------------|
| Zellij NixOS config    | `modules/core/tools/zellij/default.nix` (NixOS flake)      |
| Zellij generated config| `~/.config/zellij/config.kdl` (auto-managed by home-manager)|
| smart-splits Neovim    | `nvim/plugin/smart-splits.lua`                              |
| Neovim keymaps         | `nvim/plugin/keymaps.lua`                                   |
| Neovim overlay         | `nix/neovim-overlay.nix`                                    |
| This guide             | `zellij-nvim.md`                                            |
