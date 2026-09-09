# Cross-Platform Neovim Daily Driver — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Neovim config a daily driver on both Linux and native Windows, adding a persistent scratchpad and mouse affordances.

**Architecture:** A shared config with runtime platform detection (`lua/config/platform.lua`) rather than a per-platform fork. A hand-rolled scratch module (`lua/config/scratch.lua`) backed by real files under `~/scratch`, which autosaves so aggressively it never prompts. Mouse support comes from bufferline, an extended built-in `PopUp` menu, an nvim-tree `on_attach`, and Neovide GUI settings.

**Tech Stack:** Neovim 0.12, Lua, lazy.nvim, plenary.nvim (tests via `PlenaryBustedDirectory`), Telescope, bufferline.nvim, Neovide, PowerShell 7 + scoop (Windows).

**Spec:** `docs/specs/2026-09-08-neovim-cross-platform-design.md`

## Global Constraints

- Branch: all work on `nvim-crossplatform` in `~/dotfiles`. Never commit to `main`.
- Comment style: this config is heavily commented for a reader who does not know Vim. Match that density and tone in every new file. Explain *why*, not just *what*.
- `~/scratch` is **machine-local**. Never add sync, git, or vault integration.
- **The user is never shown a filename prompt or a save dialog, in any scratch flow.** This is the defining property of the feature.
- **No auto-trim, no rotation, no size cap** on the quick pad. Never auto-delete parked content.
- Scratch autosave fires only when the buffer is **modified**.
- Existing `PDA_MODE` convention: `vim.env.PDA_MODE` disables heavy plugins. New code must not assume Telescope exists.
- Neovim's `mousemodel` already defaults to `popup_setpos` and ships a built-in `PopUp` menu — **extend it, never replace it**.
- nvim-tree `on_attach` must **extend** defaults via `api.config.mappings.default_on_attach(bufnr)`, never replace them.
- Windows target is **native Neovim + Neovide**. Not WSL.
- Font: `JetBrainsMono Nerd Font:h12` (matches existing Kitty config).
- Treesitter has `auto_install = true`, so a missing C compiler on Windows errors on every new filetype. `zig` is non-negotiable in the Windows install.

---

## File Structure

| File | Responsibility | Status |
|---|---|---|
| `nvim/lua/config/platform.lua` | Platform/GUI detection and executable probing. Pure, no side effects. | Create |
| `nvim/lua/config/scratch.lua` | Scratch paths, file ops, float window, picker, autosave. | Create |
| `nvim/lua/config/neovide.lua` | Neovide-only GUI settings. Inert elsewhere. | Create |
| `nvim/lua/plugins/bufferline.lua` | Clickable buffer tabs. | Create |
| `nvim/tests/minimal_init.lua` | Headless test bootstrap. | Create |
| `nvim/tests/platform_spec.lua` | Tests for platform.lua. | Create |
| `nvim/tests/scratch_spec.lua` | Tests for scratch.lua. | Create |
| `nvim/init.lua` | Require platform, scratch, neovide. | Modify |
| `nvim/lua/config/options.lua` | `showtabline`, `mousemoveevent`, Windows shell. | Modify |
| `nvim/lua/config/keymaps.lua` | Rebind `<S-l>`/`<S-h>`; scratch keymaps. | Modify |
| `nvim/lua/plugins/editor.lua` | nvim-tree `on_attach`; tmux-navigator guard; fzf-native build. | Modify |
| `nvim/lua/plugins/ui.lua` | which-key `<leader>n` group. | Modify |
| `nvim/lua/plugins/treesitter.lua` | Windows compiler list. | Modify |
| `nvim/lua/plugins/git.lua` | lazygit executable guard (lazygit lives here, NOT tools.lua). | Modify |
| `install.ps1` | Windows deploy + scoop deps. | Create |
| `docs/neovim-windows-setup-notes.md` | Stale. | Delete |

---

# STAGE 1 — Linux, features only

Goal: daily-drivable improvement on the machine where iteration is fast. No platform code yet.

---

### Task 1: Test harness

**Files:**
- Create: `nvim/tests/minimal_init.lua`
- Create: `nvim/tests/smoke_spec.lua`

**Interfaces:**
- Produces: a working `just test-nvim` / headless busted runner that all later tasks depend on.

- [ ] **Step 1: Create the minimal init**

`nvim/tests/minimal_init.lua`:

```lua
-- Minimal Neovim init used ONLY by the headless test runner.
-- It loads plenary (the test framework) and puts our own lua/ directory on
-- the runtime path, so tests can `require("config.scratch")` etc.
-- It deliberately does NOT load lazy.nvim or any plugins -- tests must be
-- fast and must not depend on the full plugin set being installed.

local here = vim.fn.fnamemodify(vim.fn.expand("<sfile>:p"), ":h")   -- nvim/tests
local nvim_root = vim.fn.fnamemodify(here, ":h")                    -- nvim/

vim.opt.rtp:append(nvim_root)
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
vim.cmd("runtime plugin/plenary.vim")
```

- [ ] **Step 2: Write a smoke test that proves the harness runs**

`nvim/tests/smoke_spec.lua`:

```lua
describe("test harness", function()
  it("runs assertions", function()
    assert.are.equal(2, 1 + 1)
  end)

  it("puts our lua/ directory on the runtime path", function()
    -- If this fails, minimal_init.lua did not resolve the repo layout and no
    -- other spec will be able to require("config.*").
    local found = vim.api.nvim_get_runtime_file("lua/config/options.lua", false)
    assert.is_true(#found > 0, "nvim/lua is not on the runtime path")
  end)
end)
```

- [ ] **Step 3: Run it to confirm the harness works**

Run from `~/dotfiles`:

```bash
nvim --headless -u nvim/tests/minimal_init.lua \
  -c "PlenaryBustedDirectory nvim/tests/ {minimal_init='nvim/tests/minimal_init.lua'}"
```

Expected: `Success: 2`, exit code 0. If plenary is not found, install it first with `nvim --headless "+Lazy! sync" +qa`.

- [ ] **Step 4: Add a justfile target**

Append to `~/dotfiles/justfile`:

```make
# Run the Neovim Lua test suite headlessly
test-nvim:
    nvim --headless -u nvim/tests/minimal_init.lua \
      -c "PlenaryBustedDirectory nvim/tests/ {minimal_init='nvim/tests/minimal_init.lua'}"
```

- [ ] **Step 5: Verify the just target**

Run: `just test-nvim`
Expected: same success output, exit code 0.

- [ ] **Step 6: Commit**

```bash
git add nvim/tests/minimal_init.lua nvim/tests/smoke_spec.lua justfile
git commit -m "test: add headless plenary test harness for nvim config"
```

---

### Task 2: Scratch module — paths and titles

**Files:**
- Create: `nvim/lua/config/scratch.lua`
- Create: `nvim/tests/scratch_spec.lua`

**Interfaces:**
- Produces:
  - `M.setup(opts)` where `opts.root` is a string path. Defaults to `~/scratch`.
  - `M.root()` returns the normalized root path string.
  - `M.ensure_root()` creates the root directory if missing. Returns the root.
  - `M.quick_path()` returns `<root>/quick.md`.
  - `M.new_path(timestamp)` returns a unique `<root>/YYYY-MM-DD-HHMM.md`, suffixing `-2`, `-3`, ... on collision. `timestamp` is an optional os.time() value for testability.
  - `M.title_of(path)` returns the first non-empty trimmed line, truncated to 60 chars, or `"(empty)"`.

- [ ] **Step 1: Write the failing tests**

`nvim/tests/scratch_spec.lua`:

```lua
local scratch = require("config.scratch")

-- Each test gets its own throwaway directory so tests never touch ~/scratch.
local function fresh_root()
  local dir = vim.fn.tempname()
  scratch.setup({ root = dir })
  return dir
end

local function write_file(path, lines)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile(lines, path)
end

describe("scratch paths", function()
  it("creates the root directory on demand", function()
    local dir = fresh_root()
    assert.are.equal(0, vim.fn.isdirectory(dir))
    scratch.ensure_root()
    assert.are.equal(1, vim.fn.isdirectory(dir))
  end)

  it("puts the quick pad at quick.md inside the root", function()
    local dir = fresh_root()
    assert.are.equal(dir .. "/quick.md", scratch.quick_path())
  end)

  it("names new scratches by timestamp", function()
    fresh_root()
    local t = os.time({ year = 2026, month = 9, day = 8, hour = 14, min = 32 })
    assert.is_truthy(scratch.new_path(t):match("2026%-09%-08%-1432%.md$"))
  end)

  it("suffixes on collision instead of overwriting", function()
    local dir = fresh_root()
    local t = os.time({ year = 2026, month = 9, day = 8, hour = 14, min = 32 })
    scratch.ensure_root()
    write_file(dir .. "/2026-09-08-1432.md", { "taken" })
    assert.is_truthy(scratch.new_path(t):match("2026%-09%-08%-1432%-2%.md$"))
  end)
end)

describe("scratch titles", function()
  it("uses the first non-empty line", function()
    local dir = fresh_root()
    scratch.ensure_root()
    local p = dir .. "/a.md"
    write_file(p, { "", "   ", "az login --tenant contoso", "more" })
    assert.are.equal("az login --tenant contoso", scratch.title_of(p))
  end)

  it("reports empty files rather than returning nil", function()
    local dir = fresh_root()
    scratch.ensure_root()
    local p = dir .. "/b.md"
    write_file(p, { "", "  " })
    assert.are.equal("(empty)", scratch.title_of(p))
  end)

  it("truncates very long first lines", function()
    local dir = fresh_root()
    scratch.ensure_root()
    local p = dir .. "/c.md"
    write_file(p, { string.rep("x", 200) })
    assert.is_true(#scratch.title_of(p) <= 60)
  end)

  it("reports a missing file as empty rather than erroring", function()
    local dir = fresh_root()
    assert.are.equal("(empty)", scratch.title_of(dir .. "/nope.md"))
  end)
end)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `just test-nvim`
Expected: FAIL — `module 'config.scratch' not found`.

- [ ] **Step 3: Write the implementation**

`nvim/lua/config/scratch.lua`:

```lua
-- ============================================================================
-- Scratchpad -- a place to park temporary text that survives restarts
-- ============================================================================
-- This replaces the way Notepad++ gets used as a parking spot: you open a
-- tab, paste a command or a snippet, never save it, and it is still there
-- tomorrow.
--
-- Neovim cannot persist a truly unnamed buffer across a restart -- there is
-- nowhere to put the text. So instead these scratches ARE real files, but the
-- module saves them for you so aggressively that you never see a save prompt
-- or have to invent a filename. It should feel like nothing is ever saved,
-- while in fact everything always is.
--
-- Two kinds of scratch:
--   1. THE quick pad (~/scratch/quick.md) -- one eternal pad, one keypress.
--   2. Named scratches (~/scratch/2026-09-08-1432.md) -- for things that
--      turned out to matter.
-- ============================================================================

local M = {}

-- Where scratches live. Machine-local on purpose -- these are NOT synced.
-- Kept in a table field (not a local) so tests can point it at a temp dir.
local config = {
  root = vim.fn.expand("~/scratch"),
}

--- Configure the module. Called from init.lua, and from tests with a temp dir.
--- @param opts table|nil  { root = string }
function M.setup(opts)
  opts = opts or {}
  if opts.root then
    -- vim.fs.normalize turns backslashes into forward slashes and expands ~,
    -- so the rest of this file can assume one path style on every platform.
    config.root = vim.fs.normalize(opts.root)
  end
end

--- @return string the scratch root directory
function M.root()
  return config.root
end

--- Create the scratch directory if it does not exist yet.
--- Safe to call repeatedly. "p" means "create parent directories too".
--- @return string the root directory
function M.ensure_root()
  if vim.fn.isdirectory(config.root) == 0 then
    vim.fn.mkdir(config.root, "p")
  end
  return config.root
end

--- @return string path to THE quick pad
function M.quick_path()
  return config.root .. "/quick.md"
end

--- Build a unique path for a new named scratch.
--- If a file with that timestamp already exists (you made two in the same
--- minute), append -2, -3, and so on rather than silently overwriting.
--- @param timestamp number|nil os.time() value; defaults to now
--- @return string
function M.new_path(timestamp)
  local stamp = os.date("%Y-%m-%d-%H%M", timestamp or os.time())
  local path = config.root .. "/" .. stamp .. ".md"
  local n = 1
  while vim.fn.filereadable(path) == 1 do
    n = n + 1
    path = config.root .. "/" .. stamp .. "-" .. n .. ".md"
  end
  return path
end

--- Human-readable label for a scratch: its first non-empty line.
--- This is what makes the picker usable -- a list of timestamps tells you
--- nothing, but "az login --tenant contoso" tells you everything.
--- @param path string
--- @return string
function M.title_of(path)
  if vim.fn.filereadable(path) == 0 then
    return "(empty)"
  end
  -- Only read the first 20 lines; we just need the first non-empty one and
  -- there is no reason to pull a huge pad into memory to find it.
  for _, line in ipairs(vim.fn.readfile(path, "", 20)) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      if #trimmed > 60 then
        return trimmed:sub(1, 57) .. "..."
      end
      return trimmed
    end
  end
  return "(empty)"
end

return M
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `just test-nvim`
Expected: smoke_spec 2 successes, scratch_spec 8 successes, 0 failed, 0 errors in both. Plenary prints a separate summary per FILE -- there is no combined total.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/config/scratch.lua nvim/tests/scratch_spec.lua
git commit -m "feat(scratch): add path resolution and title extraction"
```

---

### Task 3: Scratch module — listing, promote, delete

**Files:**
- Modify: `nvim/lua/config/scratch.lua`
- Modify: `nvim/tests/scratch_spec.lua`

**Interfaces:**
- Consumes: `M.ensure_root()`, `M.quick_path()`, `M.new_path()`, `M.title_of()` from Task 2.
- Produces:
  - `M.list()` returns an array of `{ path = string, title = string, mtime = number }`, newest first, **excluding** `quick.md`.
  - `M.promote()` copies the quick pad's contents to a new named scratch, truncates the pad to empty, and returns the new path. Returns `nil` if the pad is empty or missing.
  - `M.delete(path)` deletes the file. Refuses to delete the quick pad and returns `false, reason`. Returns `true` on success.

- [ ] **Step 1: Write the failing tests**

Append to `nvim/tests/scratch_spec.lua`:

```lua
describe("scratch listing", function()
  it("lists newest first and excludes the quick pad", function()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(dir .. "/quick.md", { "the pad" })
    write_file(dir .. "/2026-09-01-1000.md", { "older" })
    write_file(dir .. "/2026-09-02-1000.md", { "newer" })
    -- Force distinct mtimes. Both files are created in the same second, so
    -- without this the sort order is undefined and the test flakes.
    -- fs_utime is used rather than shelling out to `touch -d`, because that
    -- flag is GNU-specific and this suite must also run on Windows.
    vim.loop.fs_utime(dir .. "/2026-09-01-1000.md", 1000000, 1000000)
    vim.loop.fs_utime(dir .. "/2026-09-02-1000.md", 2000000, 2000000)

    local items = scratch.list()
    assert.are.equal(2, #items)
    assert.are.equal("newer", items[1].title)
    assert.are.equal("older", items[2].title)
  end)

  it("returns an empty list when the root does not exist", function()
    fresh_root()
    assert.are.same({}, scratch.list())
  end)
end)

describe("scratch promote", function()
  it("moves pad contents to a dated file and empties the pad", function()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "keep me", "line two" })

    local new = scratch.promote()

    assert.is_truthy(new)
    assert.are.same({ "keep me", "line two" }, vim.fn.readfile(new))
    assert.are.same({}, vim.fn.readfile(scratch.quick_path()))
  end)

  it("refuses to promote an empty pad", function()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "", "   " })
    assert.is_nil(scratch.promote())
  end)

  it("refuses to promote a pad that does not exist", function()
    fresh_root()
    assert.is_nil(scratch.promote())
  end)
end)

describe("scratch delete", function()
  it("deletes a named scratch", function()
    local dir = fresh_root()
    scratch.ensure_root()
    local p = dir .. "/2026-09-08-1432.md"
    write_file(p, { "junk" })
    assert.is_true(scratch.delete(p))
    assert.are.equal(0, vim.fn.filereadable(p))
  end)

  it("refuses to delete the quick pad", function()
    fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "pad" })
    local ok = scratch.delete(scratch.quick_path())
    assert.is_false(ok)
    assert.are.equal(1, vim.fn.filereadable(scratch.quick_path()))
  end)
end)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `just test-nvim`
Expected: FAIL — `attempt to call field 'list' (a nil value)`.

- [ ] **Step 3: Write the implementation**

Insert into `nvim/lua/config/scratch.lua`, immediately before the final `return M`:

```lua
--- All named scratches, newest first. The quick pad is deliberately excluded:
--- it is always reachable by its own keypress and would otherwise always sit
--- at the top of the list as noise.
--- @return table array of { path, title, mtime }
function M.list()
  if vim.fn.isdirectory(config.root) == 0 then
    return {}
  end
  local quick = M.quick_path()
  local items = {}
  -- vim.fn.glob with the last two args as 0,1 returns a LIST of paths.
  for _, path in ipairs(vim.fn.glob(config.root .. "/*.md", 0, 1)) do
    local normalized = vim.fs.normalize(path)
    if normalized ~= quick then
      table.insert(items, {
        path = normalized,
        title = M.title_of(normalized),
        mtime = vim.fn.getftime(normalized),
      })
    end
  end
  table.sort(items, function(a, b) return a.mtime > b.mtime end)
  return items
end

--- Return true if the file has no non-whitespace content.
--- @param path string
--- @return boolean
local function is_blank(path)
  if vim.fn.filereadable(path) == 0 then
    return true
  end
  for _, line in ipairs(vim.fn.readfile(path)) do
    if vim.trim(line) ~= "" then
      return false
    end
  end
  return true
end

--- Move the quick pad's contents into a new dated scratch, leaving the pad
--- empty. This exists because you usually only realise something matters
--- AFTER you have already scribbled it into the pad.
--- @return string|nil path of the new scratch, or nil if the pad was empty
function M.promote()
  local quick = M.quick_path()
  if is_blank(quick) then
    return nil
  end
  M.ensure_root()
  local target = M.new_path()
  vim.fn.writefile(vim.fn.readfile(quick), target)
  -- Truncate the pad rather than deleting it -- it must always exist.
  vim.fn.writefile({}, quick)

  -- If the pad is currently open in a buffer, reload it so the window does
  -- not keep showing the text we just moved away.
  local buf = vim.fn.bufnr(quick)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    vim.api.nvim_buf_call(buf, function() vim.cmd("silent edit!") end)
  end
  return target
end

--- Delete a named scratch. The quick pad is protected: deleting it would
--- break the "there is always a pad" guarantee, and the user almost
--- certainly meant to clear it instead.
--- @param path string
--- @return boolean ok, string|nil reason
function M.delete(path)
  local normalized = vim.fs.normalize(path)
  if normalized == M.quick_path() then
    return false, "refusing to delete the quick pad -- clear its contents instead"
  end
  if vim.fn.filereadable(normalized) == 0 then
    return false, "not a scratch file: " .. normalized
  end
  vim.fn.delete(normalized)
  return true
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `just test-nvim`
Expected: smoke_spec 2 successes, scratch_spec 15 successes, 0 failed, 0 errors in both.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/config/scratch.lua nvim/tests/scratch_spec.lua
git commit -m "feat(scratch): add listing, promote, and guarded delete"
```

---

### Task 4: Scratch module — float window, autosave, picker

**Files:**
- Modify: `nvim/lua/config/scratch.lua`

**Interfaces:**
- Consumes: everything from Tasks 2 and 3.
- Produces:
  - `M.toggle_quick()` opens the pad in a centered float, or closes it if already open.
  - `M.new_scratch()` creates and opens a new named scratch in the float.
  - `M.pick()` opens the picker (Telescope if available, `vim.ui.select` otherwise).
  - `M.grep()` live-greps the scratch root (Telescope only; warns otherwise).
  - `M.delete_current()` deletes the scratch shown in the current buffer.
  - `M.enable_autosave()` installs the autosave autocommands. Called once from `init.lua`.

This task is UI-heavy and largely not unit-testable; it is covered by the manual checklist in Task 12. The pure logic it depends on is already tested.

- [ ] **Step 1: Add the float window and autosave**

Insert into `nvim/lua/config/scratch.lua` before `return M`:

```lua
-- Handle of the currently open scratch float, so toggling can close it.
local float_win = nil

--- Is the given path inside our scratch directory?
--- Used by autosave. We compare normalized prefixes rather than using an
--- autocmd `pattern`, because autocmd patterns and Windows backslashes
--- interact badly.
--- @param path string
--- @return boolean
local function is_scratch_file(path)
  if path == nil or path == "" then
    return false
  end
  return vim.startswith(vim.fs.normalize(path), config.root .. "/")
end

--- Open a scratch file in a centered floating window.
--- @param path string
local function open_float(path)
  M.ensure_root()
  -- Make sure the file exists so the buffer is backed by something on disk.
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({}, path)
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)

  -- markdown gives us syntax highlighting inside ``` fences, which is exactly
  -- what you want when parking shell commands.
  vim.bo[buf].filetype = "markdown"
  -- No swap file: closing a scratch by closing its window must never produce
  -- a "swap file found" recovery prompt next time.
  vim.bo[buf].swapfile = false
  -- Keep the buffer alive when the float closes, so reopening is instant.
  vim.bo[buf].bufhidden = "hide"

  local width = math.min(100, math.floor(vim.o.columns * 0.8))
  local height = math.floor(vim.o.lines * 0.8)

  float_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
    title_pos = "center",
  })

  -- q and Esc close the float. The autosave autocommand writes on the way out,
  -- so there is nothing for the user to do.
  local function close()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, false)
    end
    float_win = nil
  end
  vim.keymap.set("n", "q", close, { buffer = buf, silent = true, desc = "Close scratch" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true, desc = "Close scratch" })
end

--- Toggle THE quick pad. This is the 30-second parking spot.
function M.toggle_quick()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, false)
    float_win = nil
    return
  end
  open_float(M.quick_path())
end

--- Create and open a brand new named scratch.
function M.new_scratch()
  M.ensure_root()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, false)
    float_win = nil
  end
  open_float(M.new_path())
end

--- Delete the scratch shown in the current buffer, then close the float.
function M.delete_current()
  local path = vim.api.nvim_buf_get_name(0)
  if not is_scratch_file(path) then
    vim.notify("Not a scratch file", vim.log.levels.WARN)
    return
  end
  local ok, reason = M.delete(path)
  if not ok then
    vim.notify(reason, vim.log.levels.WARN)
    return
  end
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
  end
  vim.notify("Deleted " .. vim.fn.fnamemodify(path, ":t"))
end

--- Install autosave. Scratches are written whenever you look away, so the
--- user never types :w and never sees a prompt.
function M.enable_autosave()
  local group = vim.api.nvim_create_augroup("ScratchAutosave", { clear = true })
  vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
    group = group,
    pattern = "*",
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if is_scratch_file(name) and vim.bo[ev.buf].modified then
        vim.api.nvim_buf_call(ev.buf, function()
          vim.cmd("silent write")
        end)
      end
    end,
    desc = "Autosave scratch buffers -- the user never saves manually",
  })
end
```

- [ ] **Step 2: Add the picker with a Telescope-optional fallback**

Insert into `nvim/lua/config/scratch.lua` before `return M`:

```lua
--- Pick a scratch to open.
--- Uses Telescope when available. Telescope is disabled in PDA_MODE, so this
--- falls back to vim.ui.select rather than erroring on that profile.
function M.pick()
  local items = M.list()
  if #items == 0 then
    vim.notify("No named scratches yet -- <leader>nn makes one", vim.log.levels.INFO)
    return
  end

  local has_telescope, pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    vim.ui.select(items, {
      prompt = "Scratches",
      format_item = function(item) return item.title end,
    }, function(choice)
      if choice then vim.cmd.edit(vim.fn.fnameescape(choice.path)) end
    end)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Scratches",
    finder = finders.new_table({
      results = items,
      -- display is what you see; ordinal is what fuzzy matching searches.
      entry_maker = function(item)
        return {
          value = item,
          display = string.format("%-60s  %s", item.title,
            os.date("%Y-%m-%d %H:%M", item.mtime)),
          ordinal = item.title .. " " .. item.path,
          path = item.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local entry = action_state.get_selected_entry()
        if entry then vim.cmd.edit(vim.fn.fnameescape(entry.path)) end
      end)
      return true
    end,
  }):find()
end

--- Live-grep across every scratch. Telescope-only; there is no sensible
--- built-in fallback for interactive grep.
function M.grep()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available -- scratch grep is disabled", vim.log.levels.WARN)
    return
  end
  M.ensure_root()
  builtin.live_grep({ search_dirs = { config.root }, prompt_title = "Grep scratches" })
end
```

- [ ] **Step 3: Verify the existing tests still pass**

Run: `just test-nvim`
Expected: smoke_spec 2 successes, scratch_spec 15 successes, 0 failed, 0 errors in both. (Plenary prints a separate summary per FILE -- there is no combined total. No new unit tests here — this is UI code.)

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/scratch.lua
git commit -m "feat(scratch): add float window, autosave, and picker"
```

---

### Task 5: Wire the scratchpad into the config

**Files:**
- Modify: `nvim/init.lua`
- Modify: `nvim/lua/config/keymaps.lua`
- Modify: `nvim/lua/plugins/ui.lua:73` (which-key group list)

**Interfaces:**
- Consumes: `M.setup`, `M.enable_autosave`, `M.toggle_quick`, `M.new_scratch`, `M.pick`, `M.grep`, `M.promote`, `M.delete_current`.

- [ ] **Step 1: Require and initialise the module**

In `nvim/init.lua`, change the config-loading block from:

```lua
require("config.options")      -- Editor settings (line numbers, tabs, etc.)
require("config.keymaps")      -- Custom keyboard shortcuts
require("config.autocommands") -- Automatic actions (trim whitespace on save, etc.)
```

to:

```lua
require("config.options")      -- Editor settings (line numbers, tabs, etc.)
require("config.keymaps")      -- Custom keyboard shortcuts
require("config.autocommands") -- Automatic actions (trim whitespace on save, etc.)

-- Scratchpad: persistent parking spot for temporary text.
-- setup() with no arguments uses the default root of ~/scratch.
local scratch = require("config.scratch")
scratch.setup()
scratch.enable_autosave()
```

- [ ] **Step 2: Add the keymaps**

Append to `nvim/lua/config/keymaps.lua`:

```lua
-- ============================================================================
-- Scratchpad -- park temporary text that survives a restart
-- ============================================================================
-- Space+Space is THE quick pad: one eternal note, one keypress. Use it the
-- way you would use an unsaved Notepad++ tab -- paste a command, come back
-- to it tomorrow. Nothing here ever asks you to save or name a file.
local scratch = require("config.scratch")

vim.keymap.set("n", "<leader><leader>", scratch.toggle_quick, { desc = "Scratch: toggle quick pad" })
vim.keymap.set("n", "<leader>nn", scratch.new_scratch, { desc = "Scratch: [n]ew [n]amed scratch" })
vim.keymap.set("n", "<leader>nf", scratch.pick, { desc = "Scratch: [f]ind scratches" })
vim.keymap.set("n", "<leader>ng", scratch.grep, { desc = "Scratch: [g]rep scratches" })
vim.keymap.set("n", "<leader>nd", scratch.delete_current, { desc = "Scratch: [d]elete this scratch" })

-- Promote moves the quick pad's contents into a dated file and clears the
-- pad, for when something you scribbled turns out to be worth keeping.
vim.keymap.set("n", "<leader>np", function()
  local path = scratch.promote()
  if path then
    vim.notify("Promoted to " .. vim.fn.fnamemodify(path, ":t"))
  else
    vim.notify("Quick pad is empty -- nothing to promote", vim.log.levels.INFO)
  end
end, { desc = "Scratch: [p]romote quick pad" })
```

- [ ] **Step 3: Register the which-key group**

In `nvim/lua/plugins/ui.lua`, inside the `wk.add({ ... })` call, add this line after the `<leader>h` entry:

```lua
        { "<leader>n", group = "Notes/Scratch" }, -- Space+n = Scratchpad
```

- [ ] **Step 4: Verify by hand**

```bash
nvim
```

Then: press `<Space><Space>`, type `hello scratch`, press `q`, run `:qa`, reopen `nvim`, press `<Space><Space>`.
Expected: `hello scratch` is still there. No save prompt was ever shown. `~/scratch/quick.md` exists.

- [ ] **Step 5: Verify tests still pass**

Run: `just test-nvim`
Expected: smoke_spec 2 successes, scratch_spec 15 successes, 0 failed, 0 errors in both. Plenary prints a separate summary per FILE -- there is no combined total.

- [ ] **Step 6: Commit**

```bash
git add nvim/init.lua nvim/lua/config/keymaps.lua nvim/lua/plugins/ui.lua
git commit -m "feat(scratch): wire scratchpad keymaps and which-key group"
```

---

### Task 6: Clickable buffer tabs

**Files:**
- Create: `nvim/lua/plugins/bufferline.lua`
- Modify: `nvim/lua/config/options.lua`
- Modify: `nvim/lua/config/keymaps.lua:31-32`

- [ ] **Step 1: Add the required options**

In `nvim/lua/config/options.lua`, in the "UI" section after the `opt.laststatus = 3` line, add:

```lua
-- Always show the tab bar at the top, even with only one file open.
-- bufferline draws our clickable file tabs there; without this the tabs
-- appear and disappear as you open files, which makes the layout jump.
opt.showtabline = 2

-- Report mouse MOVEMENT (not just clicks) to Neovim. Required for bufferline
-- to highlight the tab you are hovering over, and for the close "x" on each
-- tab to light up. Without it the tabs are clickable but feel dead.
opt.mousemoveevent = true
```

- [ ] **Step 2: Create the bufferline plugin spec**

`nvim/lua/plugins/bufferline.lua`:

```lua
-- ============================================================================
-- Bufferline -- clickable file tabs across the top, like VSCode
-- ============================================================================
-- Neovim tracks open files as "buffers", which are invisible by default --
-- you switch between them with commands. Bufferline draws them as tabs you
-- can actually see and click:
--   left-click   switch to that file
--   middle-click close that file
--   drag         reorder the tabs
--
-- This is the single biggest change that makes Neovim behave the way a
-- mouse-driven editor is expected to behave.
-- ============================================================================

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },  -- File type icons on each tab
  event = "VeryLazy",  -- Load after startup so it never slows opening a file
  opts = {
    options = {
      mode = "buffers",                 -- Show buffers as tabs (not vim "tab pages")
      diagnostics = "nvim_lsp",         -- Show an error/warning count on each tab
      separator_style = "slant",
      show_buffer_close_icons = true,   -- The little x on each tab
      show_close_icon = false,          -- No global close button in the corner
      always_show_bufferline = true,

      -- Mouse behaviour. %d is filled in with the buffer number by bufferline.
      left_mouse_command = "buffer %d",     -- Click a tab to switch to it
      middle_mouse_command = "bdelete! %d", -- Middle-click a tab to close it
      -- bufferline DEFAULTS right-click to "bdelete! %d" -- i.e. closing the
      -- file. We disable it, because Task 7 puts a real context menu on right
      -- click and because closing a file by accident is a nasty surprise.
      -- It must be `false`, NOT `nil`: assigning nil in a Lua table constructor
      -- creates no key at all, so the plugin's default would survive untouched.
      right_mouse_command = false,

      -- Reserve space on the left for the nvim-tree file explorer, so the
      -- tabs start BESIDE the tree instead of running underneath it. Without
      -- this the whole thing looks broken whenever the tree is open.
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        },
      },
    },
  },
}
```

- [ ] **Step 3: Rebind the buffer cycling keys**

In `nvim/lua/config/keymaps.lua`, replace lines 31-32:

```lua
vim.keymap.set("n", "<S-l>", ":bnext<CR>")      -- Shift+L = next buffer (file)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")  -- Shift+H = previous buffer (file)
```

with:

```lua
-- Shift+L / Shift+H cycle through open files.
-- These use BufferLineCycle rather than :bnext/:bprevious so that keyboard
-- cycling follows the order the tabs are DISPLAYED in. Plain :bnext follows
-- internal buffer numbers, which stop matching the visible order as soon as
-- you close a file or drag a tab -- very disorienting.
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- Space+b+p = PIN a tab so it stays at the left and is not closed by
-- "close others". Space+b+c = pick a tab to close by pressing its letter.
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "[b]uffer [p]in" })
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "[b]uffer pick [c]lose" })
```

- [ ] **Step 4: Install and verify**

```bash
nvim --headless "+Lazy! sync" +qa
```
Expected: exit code 0, bufferline appears in the lockfile.

Then open `nvim` with two files:
```bash
nvim nvim/init.lua nvim/lua/config/options.lua
```
Expected: two tabs at the top. Left-click the second switches to it. Middle-click closes it. `<S-l>`/`<S-h>` cycle in display order. Open the tree with `<Space>e` — the tabs shift right rather than hiding behind it.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/plugins/bufferline.lua nvim/lua/config/options.lua nvim/lua/config/keymaps.lua nvim/lazy-lock.json
git commit -m "feat(ui): add clickable buffer tabs via bufferline"
```

---

### Task 7: Single-click file tree and right-click menus

**Files:**
- Modify: `nvim/lua/plugins/editor.lua:22-32` (nvim-tree `config` function)
- Modify: `nvim/lua/config/autocommands.lua`

- [ ] **Step 1: Add the nvim-tree on_attach**

In `nvim/lua/plugins/editor.lua`, replace the nvim-tree `config` function body:

```lua
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = {
          group_empty = true,
          icons = { show = { git = true } },
        },
        filters = { dotfiles = false },
      })
    end,
```

with:

```lua
    config = function()
      local api = require("nvim-tree.api")

      -- on_attach runs once per file-explorer buffer and sets up its keymaps.
      -- We call default_on_attach FIRST so every stock nvim-tree binding still
      -- works, then add our mouse bindings on top. Never skip that call --
      -- doing so silently removes every default key.
      local function on_attach(bufnr)
        api.config.mappings.default_on_attach(bufnr)

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Single click opens a file / expands a folder, matching VSCode.
        -- nvim-tree needs a DOUBLE click by default.
        --
        -- We bind LeftRelease rather than LeftMouse, and check that the
        -- release landed on an actual node. Without that check, dragging to
        -- select text inside the tree would open whatever file you released
        -- the button over.
        vim.keymap.set("n", "<LeftRelease>", function()
          if api.tree.get_node_under_cursor() then
            api.node.open.edit()
          end
        end, opts("Open on single click"))

        -- Right click moves the cursor to the node under the POINTER before
        -- opening the menu. Without this the menu acts on wherever the cursor
        -- happened to be, which is a classic and infuriating bug.
        vim.keymap.set("n", "<RightMouse>", function()
          vim.cmd.exe('"normal! \\<LeftMouse>"')
          vim.cmd.popup("PopUpNvimTree")
        end, opts("Context menu"))
      end

      require("nvim-tree").setup({
        view = { width = 35 },            -- The tree panel is 35 characters wide
        renderer = {
          group_empty = true,              -- Collapse folders that only contain one subfolder
          icons = { show = { git = true } },  -- Show git status icons
        },
        filters = { dotfiles = false },    -- Show hidden files
        on_attach = on_attach,
      })

      -- The right-click menu shown inside the file explorer.
      -- Defined here because it only makes sense alongside nvim-tree.
      vim.cmd([[
        silent! aunmenu PopUpNvimTree
        nnoremenu PopUpNvimTree.New\ File     <cmd>lua require("nvim-tree.api").fs.create()<CR>
        nnoremenu PopUpNvimTree.New\ Folder   <cmd>lua require("nvim-tree.api").fs.create()<CR>
        nnoremenu PopUpNvimTree.-sep1-        <Nop>
        nnoremenu PopUpNvimTree.Rename        <cmd>lua require("nvim-tree.api").fs.rename()<CR>
        nnoremenu PopUpNvimTree.Delete        <cmd>lua require("nvim-tree.api").fs.remove()<CR>
        nnoremenu PopUpNvimTree.-sep2-        <Nop>
        nnoremenu PopUpNvimTree.Copy\ Path    <cmd>lua require("nvim-tree.api").fs.copy.absolute_path()<CR>
      ]])
    end,
```

- [ ] **Step 2: Extend the buffer right-click menu**

Append to `nvim/lua/config/autocommands.lua`:

```lua
-- ============================================================================
-- Right-click context menu
-- ============================================================================
-- Neovim already ships a small right-click menu (its "PopUp" menu) and
-- already defaults `mousemodel` to popup_setpos, which is what makes right
-- click open it. We EXTEND that menu rather than replacing it, so the stock
-- Cut/Copy/Paste entries survive.
--
-- The LSP entries (Go to Definition and friends) are rebuilt every time the
-- menu opens, and only added when a language server is actually attached to
-- this buffer. A menu that offers "Go to Definition" in a plain text file and
-- then silently does nothing is worse than not offering it at all.
vim.api.nvim_create_autocmd("MenuPopup", {
  group = vim.api.nvim_create_augroup("ContextMenu", { clear = true }),
  pattern = "*",
  callback = function()
    -- Remove anything we added last time so entries never accumulate.
    vim.cmd([[silent! aunmenu PopUp.Go\ to\ Definition]])
    vim.cmd([[silent! aunmenu PopUp.Find\ References]])
    vim.cmd([[silent! aunmenu PopUp.Rename\ Symbol]])
    vim.cmd([[silent! aunmenu PopUp.Format]])
    vim.cmd([[silent! aunmenu PopUp.-lspsep-]])

    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      return  -- No language server here; leave the stock menu alone.
    end

    -- "10." forces these to the TOP of the menu, above Cut/Copy/Paste.
    vim.cmd([[
      nnoremenu 10.100 PopUp.Go\ to\ Definition <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremenu 10.110 PopUp.Find\ References   <cmd>lua vim.lsp.buf.references()<CR>
      nnoremenu 10.120 PopUp.Rename\ Symbol     <cmd>lua vim.lsp.buf.rename()<CR>
      nnoremenu 10.130 PopUp.Format             <cmd>lua vim.lsp.buf.format()<CR>
      nnoremenu 10.140 PopUp.-lspsep-           <Nop>
    ]])
  end,
  desc = "Add LSP actions to the right-click menu when a server is attached",
})
```

- [ ] **Step 3: Verify by hand**

```bash
nvim nvim/init.lua
```

Expected:
- `<Space>e` opens the tree; a single left-click on a file opens it; a single click on a folder expands it.
- Right-click a *different* file in the tree than the cursor is on — the menu appears and Rename targets the file you clicked.
- Right-click inside `init.lua` (Lua LSP attached) — Go to Definition appears at the top.
- Right-click inside a scratch pad (`<Space><Space>`, markdown, no LSP) — only the stock Cut/Copy/Paste entries appear.

- [ ] **Step 4: Verify tests still pass**

Run: `just test-nvim`
Expected: smoke_spec 2 successes, scratch_spec 15 successes, 0 failed, 0 errors in both. Plenary prints a separate summary per FILE -- there is no combined total.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/plugins/editor.lua nvim/lua/config/autocommands.lua
git commit -m "feat(ui): single-click file tree and LSP-aware right-click menus"
```

---

# STAGE 2 — Platform layer

Goal: add platform detection and guards. On Linux, behaviour must be **identical** to Stage 1.

---

### Task 8: Platform detection module

**Files:**
- Create: `nvim/lua/config/platform.lua`
- Create: `nvim/tests/platform_spec.lua`

**Interfaces:**
- Produces:
  - `M.is_windows` boolean
  - `M.is_wsl` boolean
  - `M.is_linux` boolean
  - `M.is_neovide` boolean
  - `M.has(exe)` returns boolean

- [ ] **Step 1: Write the failing tests**

`nvim/tests/platform_spec.lua`:

```lua
local platform = require("config.platform")

describe("platform detection", function()
  it("exposes exactly one primary OS as true", function()
    -- On any machine we run on, is_windows and is_linux cannot both be true.
    assert.is_false(platform.is_windows and platform.is_linux)
  end)

  it("agrees with Neovim's own has('win32')", function()
    assert.are.equal(vim.fn.has("win32") == 1, platform.is_windows)
  end)

  it("detects an executable that definitely exists", function()
    -- Every platform we target has one of these on PATH.
    assert.is_true(platform.has("nvim"))
  end)

  it("reports a nonexistent executable as absent", function()
    assert.is_false(platform.has("definitely-not-a-real-binary-xyzzy"))
  end)

  it("is not running under Neovide in a headless test", function()
    assert.is_false(platform.is_neovide)
  end)

  it("only reports WSL when it also reports Linux", function()
    if platform.is_wsl then
      assert.is_true(platform.is_linux)
    end
  end)
end)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `just test-nvim`
Expected: FAIL — `module 'config.platform' not found`.

- [ ] **Step 3: Write the implementation**

`nvim/lua/config/platform.lua`:

```lua
-- ============================================================================
-- Platform detection
-- ============================================================================
-- This config runs on two machines: Linux (EndeavourOS/Hyprland) and native
-- Windows with the Neovide GUI. Rather than keeping two copies of the config
-- -- which always rot, because every improvement has to be made twice --
-- there is ONE config that asks at runtime where it is running.
--
-- Everything here is computed once when this file is first required, so
-- checking these flags is free.
-- ============================================================================

local M = {}

--- True on native Windows. Note this is TRUE for Neovim built for Windows and
--- FALSE for Neovim running inside WSL, which is Linux as far as it knows.
M.is_windows = vim.fn.has("win32") == 1

--- True on Linux, including WSL.
M.is_linux = vim.fn.has("linux") == 1

--- True when this Linux is actually WSL.
--- WSL is a non-goal for this setup -- Windows uses native Neovim -- but the
--- flag costs one line and is what you would branch on to disable clipboard
--- and GUI assumptions if the config is ever opened under WSL by accident.
M.is_wsl = (function()
  if not M.is_linux then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, "/proc/version")
  if not ok or not lines or not lines[1] then
    return false
  end
  return lines[1]:lower():find("microsoft") ~= nil
end)()

--- True when running inside the Neovide GUI rather than a terminal.
--- Neovide sets vim.g.neovide before any config is read.
M.is_neovide = vim.g.neovide ~= nil

--- Is this program available on PATH?
--- Used to enable plugins only when the tool they wrap is actually installed,
--- so a missing `lazygit` produces no plugin rather than a broken keybinding.
--- @param exe string
--- @return boolean
function M.has(exe)
  return vim.fn.executable(exe) == 1
end

return M
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `just test-nvim`
Expected: smoke_spec 2, scratch_spec 15, platform_spec 6 successes, 0 failed, 0 errors in all three. Plenary prints a separate summary per FILE -- there is no combined total.

- [ ] **Step 5: Commit**

```bash
git add nvim/lua/config/platform.lua nvim/tests/platform_spec.lua
git commit -m "feat(platform): add cross-platform detection module"
```

---

### Task 9: Apply platform guards

**Files:**
- Modify: `nvim/init.lua`
- Modify: `nvim/lua/config/options.lua`
- Modify: `nvim/lua/plugins/editor.lua` (tmux-navigator, fzf-native build)
- Modify: `nvim/lua/plugins/git.lua` (lazygit). Note: yazi and tmux-navigator both live in editor.lua.
- Modify: `nvim/lua/plugins/treesitter.lua`

- [ ] **Step 1: Require platform first in init.lua**

In `nvim/init.lua`, immediately before `require("config.options")`, add:

```lua
-- Platform detection must load before anything else, because options and
-- plugin specs both branch on it.
require("config.platform")
```

- [ ] **Step 2: Set the Windows shell**

Append to `nvim/lua/config/options.lua`:

```lua
-- ============================================================================
-- Windows: use PowerShell instead of cmd.exe
-- ============================================================================
-- Native Windows Neovim shells out to cmd.exe by default. cmd.exe cannot
-- handle the quoting that Telescope's grep and plain `:!` commands generate,
-- so searches silently return nothing and `:!` commands fail in confusing
-- ways. Pointing `shell` at PowerShell 7 (`pwsh`) fixes both.
--
-- The shellredir and shellpipe values below (and shellcmdflag) look like line
-- noise. They are the documented incantation from `:help shell-powershell` and
-- should be copied exactly rather than reasoned about. In particular the
-- DOUBLED percent signs are deliberate, not a typo -- "correcting" them is the
-- most likely way a future reader breaks this block.
-- shellquote and shellxquote are deliberately set to empty strings, which is
-- what that same help topic prescribes for PowerShell.
local platform = require("config.platform")

if platform.is_windows then
  local powershell = platform.has("pwsh") and "pwsh" or "powershell"
  opt.shell = powershell
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  opt.shellquote = ""
  opt.shellxquote = ""
end

-- ============================================================================
-- Windows: pin the Python interpreter
-- ============================================================================
-- Neovim finds a Python for its plugin host by searching PATH. On Windows
-- that search frequently lands on the Microsoft Store stub, or on whichever
-- virtualenv happened to be active when Neovim launched -- which means Mason
-- and the debugger resolve a DIFFERENT Python than the one the packages were
-- installed into, and fail in ways that look random.
--
-- Pinning it removes the guesswork. We only pin if the file actually exists,
-- so a machine without this exact layout falls back to the default search
-- rather than breaking outright.
if platform.is_windows then
  local candidates = {
    vim.fn.expand("~/scoop/apps/python/current/python.exe"),
    vim.fn.expand("~/AppData/Local/Programs/Python/Python312/python.exe"),
    vim.fn.expand("~/AppData/Local/Programs/Python/Python311/python.exe"),
  }
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      vim.g.python3_host_prog = candidate
      break
    end
  end
end
```

- [ ] **Step 3: Guard the Linux-only plugins**

In `nvim/lua/plugins/editor.lua`, in the `christoomey/vim-tmux-navigator` spec (around line 306), add a `cond` immediately after the plugin name line:

```lua
    "christoomey/vim-tmux-navigator",
    -- There is no tmux on native Windows, so this plugin and its keymaps
    -- would just be dead weight there.
    cond = not require("config.platform").is_windows,
```

In `nvim/lua/plugins/git.lua` (NOT tools.lua -- lazygit lives in git.lua), add to the `kdheepak/lazygit.nvim` spec:

```lua
    -- Only load if the lazygit binary is actually installed. Without this the
    -- keybinding exists but fails with a confusing error.
    cond = require("config.platform").has("lazygit"),
```

In `nvim/lua/plugins/editor.lua`, add to the `mikavilpas/yazi.nvim` spec:

```lua
    cond = require("config.platform").has("yazi"),
```

- [ ] **Step 4: Fix the Telescope fzf-native build for Windows**

In `nvim/lua/plugins/editor.lua`, replace the fzf-native dependency line:

```lua
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
```

with:

```lua
      -- fzf-native is a small C program that makes Telescope's fuzzy matching
      -- dramatically faster. It has to be COMPILED after download.
      -- On Linux that is a plain `make`. Native Windows has no `make`, so it
      -- needs the cmake invocation instead -- without this the build fails
      -- silently on Windows and Telescope quietly falls back to slow matching.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = require("config.platform").is_windows
            and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
            or "make",
      },
```

- [ ] **Step 5: Set the treesitter compiler order**

In `nvim/lua/plugins/treesitter.lua`, inside `config = function()`, immediately before the `require("nvim-treesitter.configs").setup({` line, add:

```lua
    -- Treesitter COMPILES a small C parser for each language. Linux always has
    -- a C compiler; Windows usually does not, and because `auto_install` is on
    -- below, a missing compiler means an error popup on every new filetype you
    -- open. `zig` is listed first because `scoop install zig` is the easiest
    -- way to get a working compiler on Windows.
    require("nvim-treesitter.install").compilers = { "zig", "clang", "cl", "gcc", "cc" }
```

- [ ] **Step 6: Verify no Linux regression**

```bash
nvim --headless "+Lazy! sync" +qa; echo "EXIT=$?"
just test-nvim
```
Expected: both exit 0.

Then open `nvim` and confirm: `<Space>lg` still opens lazygit, `<Space>y` still opens yazi, `<C-h>`/`<C-l>` still navigate splits, and `<Space>ff` still finds files quickly.

- [ ] **Step 7: Commit**

```bash
git add nvim/init.lua nvim/lua/config/options.lua nvim/lua/plugins/editor.lua nvim/lua/plugins/git.lua nvim/lua/plugins/treesitter.lua
git commit -m "feat(platform): guard Linux-only plugins and fix Windows shell, compiler, and fzf build"
```

---

# STAGE 3 — Windows

---

### Task 10: Neovide GUI settings

**Files:**
- Create: `nvim/lua/config/neovide.lua`
- Modify: `nvim/init.lua`

- [ ] **Step 1: Create the Neovide config**

`nvim/lua/config/neovide.lua`:

```lua
-- ============================================================================
-- Neovide -- GUI-only settings
-- ============================================================================
-- Neovide is a standalone graphical window that runs Neovim, instead of
-- Neovim running inside a terminal emulator.
--
-- This exists because Windows Terminal cannot pass many key combinations
-- through to Neovim at all -- Ctrl+Shift+anything, most Alt combinations, and
-- it cannot even tell Ctrl+I apart from Tab. That is a limitation of the
-- terminal, not something a config can fix. Removing the terminal from the
-- picture removes the whole class of problem, and gives real mouse support,
-- font ligatures and smooth scrolling as a bonus.
--
-- Every line here is inert unless we are actually inside Neovide.
-- ============================================================================

if not vim.g.neovide then
  return
end

-- ---------------------------------------------------------------------------
-- Font
-- ---------------------------------------------------------------------------
-- Matches the Kitty terminal config on Linux so both look identical.
vim.o.guifont = "JetBrainsMono Nerd Font:h12"

-- ---------------------------------------------------------------------------
-- Animations -- SET THIS TO false IF YOU EVER USE THIS MACHINE OVER RDP
-- ---------------------------------------------------------------------------
-- Smooth scrolling and the cursor particle trail look great on a local
-- display and are genuinely unpleasant over a remote desktop connection,
-- where every animated frame becomes network traffic. One switch kills them.
local animations = true

if animations then
  vim.g.neovide_cursor_animation_length = 0.06   -- Seconds for the cursor to glide
  vim.g.neovide_cursor_trail_size = 0.4          -- How long the trail behind it is
  vim.g.neovide_cursor_vfx_mode = "railgun"      -- Particle effect; "" disables
  vim.g.neovide_scroll_animation_length = 0.25   -- Smooth scrolling
else
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_scroll_animation_length = 0
end

-- ---------------------------------------------------------------------------
-- Window behaviour
-- ---------------------------------------------------------------------------
vim.g.neovide_remember_window_size = true   -- Reopen at the size you left it
vim.g.neovide_hide_mouse_when_typing = true -- Pointer gets out of the way

-- Frames per second to render at. This is a FIXED value, not auto-detected --
-- set it to match your monitor if yours is not 60Hz. `idle` drops the rate down
-- when nothing is happening, so an open-but-unused window is not burning GPU.
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_padding_top = 4
vim.g.neovide_padding_left = 4
vim.g.neovide_padding_right = 4
vim.g.neovide_padding_bottom = 4

-- ---------------------------------------------------------------------------
-- Zoom -- Ctrl+= / Ctrl+- / Ctrl+0, and Ctrl+scroll
-- ---------------------------------------------------------------------------
-- Neovide scales the whole window by a factor rather than changing the font
-- size, so this zooms everything crisply.
vim.g.neovide_scale_factor = 1.0

local function change_scale(delta)
  -- Clamp so you cannot zoom to something unusable and get stuck.
  local new = vim.g.neovide_scale_factor + delta
  vim.g.neovide_scale_factor = math.min(math.max(new, 0.5), 3.0)
end

vim.keymap.set({ "n", "i" }, "<C-=>", function() change_scale(0.1) end, { desc = "Zoom in" })
vim.keymap.set({ "n", "i" }, "<C-->", function() change_scale(-0.1) end, { desc = "Zoom out" })
vim.keymap.set({ "n", "i" }, "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Zoom reset" })
vim.keymap.set({ "n", "i" }, "<C-ScrollWheelUp>", function() change_scale(0.1) end, { desc = "Zoom in" })
vim.keymap.set({ "n", "i" }, "<C-ScrollWheelDown>", function() change_scale(-0.1) end, { desc = "Zoom out" })
```

- [ ] **Step 2: Load it from init.lua**

In `nvim/init.lua`, after the scratch setup block, add:

```lua
-- Neovide GUI settings. This file returns immediately when not in Neovide,
-- so it is safe (and free) to load on every platform.
require("config.neovide")
```

- [ ] **Step 3: Verify it is inert in the terminal**

```bash
nvim --headless "+lua require('config.neovide')" +qa; echo "EXIT=$?"
just test-nvim
```
Expected: both exit 0, no errors.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/config/neovide.lua nvim/init.lua
git commit -m "feat(neovide): add GUI settings with a single animations switch"
```

---

### Task 11: Windows installer

**Files:**
- Create: `install.ps1`

- [ ] **Step 1: Write the installer**

> **The listing below is the ORIGINAL draft and is now superseded.** Review of
> Task 11 found two Important defects in it, both since fixed in the real file:
> the font install wrote to `%WINDIR%\Fonts` via COM `CopyHere`, which silently
> no-ops on the non-elevated Developer-Mode path the preflight itself permits
> (now a per-user install under `%LOCALAPPDATA%\Microsoft\Windows\Fonts` with
> HKCU registration); and `scoop bucket add extras 2>$null` suppressed only the
> stderr text, not the exit code, so on PowerShell 7.4+ an already-added bucket
> aborted the whole script on any second run (now wrapped in try/catch).
>
> **`install.ps1` in the repo root is authoritative.** Read that, not this.

`~/dotfiles/install.ps1`:

```powershell
#Requires -Version 7.0
<#
.SYNOPSIS
    Deploy this dotfiles repo's Neovim config on native Windows.

.DESCRIPTION
    The Linux side of this repo uses GNU Stow to symlink configs into place.
    Stow does not exist on Windows, and Windows Neovim reads its config from
    %LOCALAPPDATA%\nvim rather than ~/.config/nvim, so this script does the
    equivalent job: install the external tools, then link the config.

    Creating a symlink on Windows requires EITHER Developer Mode to be enabled
    OR an elevated shell. This script checks up front and tells you which is
    missing, rather than failing later with an opaque access-denied error.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$NvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$NvimSource = Join-Path $RepoRoot "nvim"

function Test-CanSymlink {
    # Developer Mode lets a non-elevated process create symlinks.
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $devMode = (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $elevated = ([Security.Principal.WindowsPrincipal]$identity).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)

    return @{ DevMode = $devMode; Elevated = $elevated; Ok = ($devMode -or $elevated) }
}

# --- Preflight ---------------------------------------------------------------

$symlink = Test-CanSymlink
if (-not $symlink.Ok) {
    Write-Host "Cannot create symlinks." -ForegroundColor Red
    Write-Host "Fix ONE of these, then re-run:"
    Write-Host "  1. Enable Developer Mode:  Settings > System > For developers > Developer Mode"
    Write-Host "  2. Or re-run this script from an Administrator PowerShell"
    exit 1
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop is not installed. Install it first with:" -ForegroundColor Red
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Host "  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
    exit 1
}

# --- External tools ----------------------------------------------------------
#
# neovim  - the editor itself
# neovide - the GUI front end; the whole point of the Windows setup
# zig     - a C compiler for treesitter. NOT optional: auto_install is on, so
#           without a compiler every new filetype throws an error popup.
# ripgrep - Telescope's grep backend
# fd      - Telescope's file finder backend
# cmake   - needed to build telescope-fzf-native on Windows
# lazygit - git TUI (the nvim plugin is skipped if this is absent)
# yazi    - file manager (likewise)

Write-Host "Installing tools via scoop..." -ForegroundColor Cyan
scoop bucket add extras 2>$null
scoop install neovim neovide zig ripgrep fd cmake git gh lazygit yazi fzf

# --- Fonts -------------------------------------------------------------------

Write-Host "Installing JetBrainsMono Nerd Font..." -ForegroundColor Cyan
$fontDir = Join-Path $RepoRoot "fonts"
$shell = New-Object -ComObject Shell.Application
$fonts = $shell.Namespace(0x14)
Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
    $installed = Join-Path $env:WINDIR "Fonts\$($_.Name)"
    if (-not (Test-Path $installed)) {
        $fonts.CopyHere($_.FullName, 0x10)
    }
}

# --- Link the Neovim config --------------------------------------------------

if (Test-Path $NvimTarget) {
    $backup = "$NvimTarget.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Existing config found. Moving it to $backup" -ForegroundColor Yellow
    Move-Item -Path $NvimTarget -Destination $backup
}

Write-Host "Linking $NvimTarget -> $NvimSource" -ForegroundColor Cyan
New-Item -ItemType SymbolicLink -Path $NvimTarget -Target $NvimSource | Out-Null

# --- Done --------------------------------------------------------------------

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  1. Run: nvim --headless `"+Lazy! sync`" +qa"
Write-Host "  2. Run: nvim --headless `"+checkhealth`" +qa   (review any ERRORs)"
Write-Host "  3. Launch the GUI with: neovide"
```

- [ ] **Step 2: Lint it on Linux**

```bash
pwsh -NoProfile -Command "\$null = [System.Management.Automation.Language.Parser]::ParseFile('$HOME/dotfiles/install.ps1', [ref]\$null, [ref]\$errs); \$errs"
```
Expected: no parse errors. If `pwsh` is not installed on the Linux box, skip this step and rely on the Windows run in Task 12.

- [ ] **Step 3: Commit**

```bash
git add install.ps1
git commit -m "feat(windows): add install.ps1 for native Windows deployment"
```

---

### Task 12: Windows verification and doc cleanup

**Files:**
- Delete: `docs/neovim-windows-setup-notes.md`
- Modify: `docs/specs/2026-09-08-neovim-cross-platform-design.md` (mark implemented)

- [ ] **Step 1: Run the installer on the Windows machine**

From a PowerShell 7 prompt in the cloned dotfiles repo:

```powershell
git checkout nvim-crossplatform
./install.ps1
nvim --headless "+Lazy! sync" +qa
```
Expected: exit code 0. If treesitter reports compile errors, `zig` did not install — fix that before continuing.

- [ ] **Step 2: Check health**

```powershell
nvim --headless "+checkhealth" "+w! health.txt" +qa
Select-String -Path health.txt -Pattern "ERROR"
```
Expected: no ERROR lines. Warnings about optional providers (perl, ruby, node) are fine and expected.

- [ ] **Step 3: Run the manual checklist in Neovide**

Launch `neovide` and confirm each item. These cannot be automated — mouse input and GUI rendering have no headless equivalent.

- [ ] Left-click a tab switches buffer; middle-click closes it; dragging reorders
- [ ] `<S-l>`/`<S-h>` cycle in the same order the tabs are displayed
- [ ] Single-click in nvim-tree opens a file; single-click toggles a folder
- [ ] Right-click in a code buffer shows LSP entries at the top
- [ ] Right-click in a markdown scratch shows only stock entries (no dead LSP items)
- [ ] Right-click in nvim-tree acts on the node under the pointer, not the cursor
- [ ] `<Space><Space>` opens the pad; type text; `:qa`; relaunch; text is still there
- [ ] `<Space>np` produces a dated file and leaves the pad empty
- [ ] `<Space>nf` lists scratches labelled by their first line, not by filename
- [ ] `Ctrl+ScrollWheel` zooms; window size is remembered across restarts
- [ ] `<Space>ff` (Telescope) returns results quickly — proves fzf-native built
- [ ] `:!echo hi` prints `hi` — proves the PowerShell shell settings work
- [ ] Icons render as glyphs, not boxes. **If they are boxes, log out and back
      in before investigating anything else.** `install.ps1` registers the Nerd
      Font per-user, which does not broadcast `WM_FONTCHANGE`, so apps launched
      in the same session may not see it until the next logon. The font is
      installed correctly; only the running session's font cache is stale.

- [ ] **Step 4: Run the same checklist on Linux**

Everything above except the Neovide-specific items must also pass in Kitty on Linux. This is the no-regression gate for Stage 2.

- [ ] **Step 5: Delete the superseded doc**

```bash
git rm docs/neovim-windows-setup-notes.md
```

- [ ] **Step 6: Mark the spec implemented**

In `docs/specs/2026-09-08-neovim-cross-platform-design.md`, change the status line:

```markdown
**Status:** Approved design, not yet implemented
```

to:

```markdown
**Status:** Implemented on branch `nvim-crossplatform`
```

- [ ] **Step 7: Commit**

```bash
git add -A docs/
git commit -m "docs: retire superseded Windows notes, mark spec implemented"
```

- [ ] **Step 8: Merge**

Use the `superpowers:finishing-a-development-branch` skill to decide how to integrate `nvim-crossplatform` into `main`.

---

## Notes for the executor

- **Do not run `stow` during Stage 1 or 2.** `~/.config/nvim` is already symlinked to `~/dotfiles/nvim`, so edits are live immediately. Restart Neovim to pick them up.
- **If a task's verification fails, stop.** Do not proceed to the next task with a failing check — Stage 2's whole purpose is proving Stage 1 did not regress, which is meaningless if Stage 1 was never green.
- **The `~/scratch` directory currently holds one unrelated file** (`install-davinci-resolve.sh`). Leave it. `M.list()` only globs `*.md`, so it will not appear in the picker.
