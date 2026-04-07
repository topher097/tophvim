# Agent Operating Guide

This repository is a Neovim + Nix configuration template (`kickstart-nix.nvim`–style). Python files exist mainly to exercise and validate the Neovim derivation; the primary focus for agents is the Nix and Neovim/Lua configuration.

The goal is:

- Keep the Nix/Neovim config working, reproducible, and pleasant to use.
- Treat Python code as support tooling for the Neovim build, not as an application.
- Respect existing tooling (Nix, pre-commit, Ruff, Stylua, nbstripout).

This file is written for non-interactive agents; prefer commands that succeed in a clean checkout without extra flags or prompts.

## 1. Tooling And Environment

- Nix is the primary way to build and run Neovim from this repo.
- Neovim configuration lives under `nvim/**` and is pure Lua.
- Lua formatting is configured via `.stylua.toml`.
- Python and notebooks at the repo root are primarily there to test the Neovim/LSP experience; they are not a production application.
- Pre-commit, Ruff, and nbstripout enforce basic hygiene for Python and notebooks so they do not break the Neovim tooling experience.

If you are unsure which language a change touches, assume Neovim/Lua first: look under `nvim/**` before adding new Python.

## 2. Build, Lint, And Test Commands (Neovim‑first)

Run all commands from the repository root (`/home/topher/Documents/tophvim`) unless stated otherwise.

### 2.1 Nix / Neovim Build

- Build Neovim package:

  ```bash
  nix build .#nvim
  ```

- Run the packaged Neovim once it is built:

  ```bash
  nix run .#nvim
  ```

- Install Neovim into the current profile:

  ```bash
  nix profile install .#nvim
  ```

These commands validate that the Nix flake still evaluates and the Neovim configuration is syntactically valid.

### 2.2 Dev Shell

- Enter the dev shell (recommended before touching Lua or running Neovim tooling):

  ```bash
  nix develop
  ```

Inside the shell, a `nvim-dev` wrapper is usually available and the Lua language server configuration is wired up. Use `nvim-dev` when iterating quickly on `nvim/**` without rebuilding the Nix derivation.

### 2.3 Lua Format

Lua code (especially under `nvim/**`) should be formatted with Stylua using `.stylua.toml`.

- Format all Lua files:

  ```bash
  stylua .
  ```

- Format a single Lua file:

  ```bash
  stylua path/to/file.lua
  ```

### 2.4 Python / Notebook Hygiene (supporting Neovim)

Python code and notebooks are mainly used to validate that the Neovim derivation and LSP setup work correctly.

- Run all pre-commit hooks on changed files:

  ```bash
  pre-commit run
  ```

- Run all hooks on the whole repo (useful before larger config edits):

  ```bash
  pre-commit run --all-files
  ```

- Run Ruff lint + auto-fix directly (matches the pre-commit config):

  ```bash
  ruff check --fix .
  ruff format .
  ```

- Notebooks (e.g. `sample.ipynb`) are stripped by nbstripout; after editing one, run:

  ```bash
  pre-commit run nbstripout --files sample.ipynb
  ```

There is currently no dedicated Python test suite configured; only add one if it clearly improves validation of the Neovim build.

## 3. Code Style Guidelines – Lua / Neovim

Lua config is under `nvim/**` and is formatted with Stylua (`.stylua.toml`). Key settings:

- Unix line endings, 2-space indentation, prefer single quotes where possible, and `NoSingleTable` parentheses style.

Follow these conventions:

- Imports / Requires
  - Use `local` for all module-scoped variables: `local M = {}` or `local lsp = require('user.lsp')`.
  - Use `require('module.name')` with single-quoted module names.
  - Avoid global variables; if you must set `vim.g.*`, do it in `nvim/init.lua`.

- Formatting
  - Let Stylua decide indentation and wrapping.
  - Keep tables and function calls readable; break long tables across lines rather than deeply nesting inline.

- Types / Table Shapes
  - Document non-trivial table shapes with short comments where it aids readability.
  - Prefer returning a single module table from `lua/user/*.lua` files.

- Naming
  - Local variables and functions: `snake_case`.
  - Modules: `user.lsp`, `user.<feature>` style.
  - Keep Neovim keymaps and commands in their dedicated plugin files (`nvim/plugin/keymaps.lua`, `nvim/plugin/commands.lua`).

- Error Handling
  - Use `pcall(require, 'mod')` when loading optional plugins; handle failure gracefully.
  - Prefer non-throwing configuration code; misconfigured plugins should not crash Neovim startup if avoidable.

- LSP Configuration
  - `nvim/ftplugin/python.lua` and `nvim/ftplugin/lua.lua` start language servers based on executables on `$PATH`; respect this pattern when adding other languages.
  - Use `require('user.lsp').make_client_capabilities()` (or similar helpers) to keep client configs consistent.

## 4. Diagnostics And UX

`nvim/init.lua` configures diagnostics with icons and virtual text. When changing diagnostic behavior:

- Preserve severity-aware formatting (different icons for error/warn/info/hint).
- Avoid overly verbose virtual text; keep messages concise.
- Keep signs enabled with meaningful symbols; assume Nerd Fonts are available.

## 5. Pre-Commit Hooks And Repo Hygiene

From `.pre-commit-config.yaml`:

- General hooks from `pre-commit-hooks` ensure valid syntax for Python, YAML, and TOML and prevent merge conflicts.
- Ruff hooks (`ruff` with `--fix` and `ruff-format`) enforce Python and notebook style on `*.py` and `*.ipynb` files.
- `nbstripout` removes outputs from notebooks before commit.

Agents should:

- Run `pre-commit run --all-files` before large changes or before suggesting a final commit.
- Never commit notebook outputs or large binary data.
- Avoid changing pre-commit configuration unless explicitly asked.

## 6. Cursor / Copilot Rules

There are currently no `.cursor/rules` or `.cursorrules` files, and no `.github/copilot-instructions.md` file in this repository. If such guidance is added later, integrate it into this document and follow it when generating code.

## 7. When Editing As An Agent

- Prefer small, focused changes; do not refactor unrelated areas without instruction.
- Use existing patterns in nearby code as templates.
- Keep configuration comments concise and only where they clarify non-obvious behavior.
- After significant Lua changes, validate with `stylua .` and a `nix build .#nvim`.
- After Python or notebook changes, run `pre-commit run --all-files` to keep the supporting files clean.

If you introduce new tools (test runners, linters, or formatters), update this file so future agents can use them correctly.
