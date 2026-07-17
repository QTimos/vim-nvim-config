# vim-nvim-config

**Plugin-free, standalone configurations for Vim and Neovim**

A carefully crafted pair of init files that provide a modern, consistent editing experience without any external plugins.

- `init.lua` — for **Neovim** (Lua-based, modern API)
- `vim.vim` (or `.vimrc`) — for **classic Vim** (Vim9script, feature-rich)

Both configurations are maintained together and share the same philosophy: **lightweight, fast, self-contained, and distraction-free**.

They rely only on built-in features—no plugin managers and no third-party dependencies (except optional tools like `ctags`, `xclip`, etc. for enhanced functionality).

---

# Features

- 🌑 **Midnight Nexus colorscheme**
  - A dark, carefully tuned theme with consistent highlighting for Treesitter (Neovim) and legacy syntax (Vim).

- 📝 **Smart file skeletons**
  - Insert Python, CSS, or HTML boilerplate with a single command.
  - `:PYskell`
  - `:CSSskell`
  - `:HTMLskell`

- 🎓 **42 School header generator**
  - Automatically insert or update the classic 42 header for C files.
  - `<Leader><Esc>`

- 💻 **Built-in terminal**
  - Floating terminal in Neovim.
  - Popup terminal in Vim.
  - Toggle with:
    ```
    <Leader>ter
    ```

- 📁 **Enhanced Netrw file explorer**
  - Create, open, and navigate files using custom keymaps.

- ⚡ **LSP & autocompletion (Neovim only)**
  - Automatically bootstraps language servers for:
    - Python (`pyright`)
    - C/C++ (`clangd`)
    - Lua (`lua-language-server`)
  - Completion uses Neovim's built-in LSP client.

- 🏷 **Automatic tag generation**
  - `:Cctags`
  - `:Pyctags`

- 🔗 **Smart auto-pairing**
  - Automatically inserts matching brackets, quotes, and parentheses.
  - Backspace removes matching pairs.

- ⌨️ **Convenient keymaps**
  - Window navigation
  - Clipboard integration
  - Comment toggling
  - Quick save/reload
  - And much more

---

# Installation

Clone the repository:

```bash
git clone https://github.com/your-username/vim-nvim-config.git ~/vim-nvim-config
```

## Neovim

```bash
ln -sf ~/vim-nvim-config/init.lua ~/.config/nvim/init.lua
```

> **Note:** If you already have a Neovim configuration, back it up first.

## Vim

```bash
ln -sf ~/vim-nvim-config/vim.vim ~/.vimrc
```

Or, if you prefer a separate `.vim` directory:

```bash
ln -sf ~/vim-nvim-config/vim.vim ~/.vim/vimrc
```

---

# Optional Dependencies

The configuration works out of the box, but some features require external tools.

| Tool | Purpose |
|------|---------|
| `ctags` | Tag generation (`:Cctags`, `:Pyctags`) |
| `xclip` / `wl-clipboard` | System clipboard integration |
| `git` | Clone language servers automatically |
| `curl` | Download external tools |
| `unzip` | Extract downloaded archives |
| `Node.js` + `npm` | Install `pyright` |

Missing dependencies are detected automatically and will simply disable the related feature while printing a helpful message.

---

# Usage

## Basic Keymaps

| Keymap | Action |
|---------|--------|
| `<C-h/j/k/l>` | Move between windows |
| `<Leader>n` | Next buffer |
| `<Leader>p` | Previous buffer |
| `<Leader>o` | Close all other windows |
| `<Leader>qa` | Quit all |
| `<Leader>sc` | Reload configuration |
| `<Leader>ft` | Open file explorer |
| `<Leader>ter` | Toggle terminal |
| `<Leader>y` | Copy to system clipboard |
| `<Leader><Esc>` | Insert/update 42 header |
| `<CR>` | Toggle fold |
| `gcc` | Toggle comments (normal or visual mode) |

Supports:

- C
- Python
- Lua
- HTML
- CSS

---

## File Explorer (Netrw)

Inside the explorer (`<Leader>ft`):

| Key | Action |
|-----|--------|
| `<CR>` | Open file while keeping explorer |
| `<Leader><CR>` | Open file and close explorer |
| `<Leader>s<CR>` | Open in vertical split |
| `%` | Create file or directory (`/` for directory) |
| `<C-h/j/k/l>` | Navigate windows |

---

## Terminal

| Key | Action |
|-----|--------|
| `<Leader>ter` | Open floating/popup terminal |
| `<Leader>q` | Close terminal |
| `<Esc>` | Enter normal mode inside terminal |

---

## Skeleton Commands

| Command | Description |
|---------|-------------|
| `:PYskell` | Python `main()` template |
| `:CSSskell` | Modern CSS reset |
| `:HTMLskell` | HTML5 boilerplate |

---

## Tag Generation

| Command | Description |
|---------|-------------|
| `:Cctags` | Generate C project tags (including system headers) |
| `:Pyctags` | Generate Python project tags (including standard library) |

---

# Customization

The configurations are intentionally readable and easy to modify.

You can customize:

- **Colorscheme**
  - Edit the `MidnightNexus()` function.

- **Skeletons**
  - Modify the `*_skeleton` functions.

- **Terminal**
  - Adjust `Config.width`, `Config.height`, etc. (Neovim)
  - Modify popup dimensions in `Popup_terminal` (Vim)

- **Keymaps**
  - Add, remove, or remap bindings in the keymap section.

---

# Why Plugin-Free?

This project intentionally avoids plugins.

### Portability

Runs anywhere without installing dozens of plugins.

### Simplicity

Easy to understand, debug, and extend.

### Performance

Starts instantly with no plugin-loading overhead.

### Stability

No plugin updates means fewer breaking changes.

Despite being plugin-free, Neovim still takes advantage of its built-in **LSP** and **Treesitter**, providing many IDE-like features without relying on external plugin ecosystems.

---

# Contributing

Bug reports, suggestions, and pull requests are welcome.

Contributions that preserve the plugin-free philosophy are especially appreciated.

---

# License

This project is licensed under the **MIT License**.

Feel free to use, modify, and share it.
