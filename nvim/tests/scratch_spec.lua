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

  it("names a collided path that exists as a directory", function()
    -- filereadable() is false for a directory, so a candidate name that is
    -- already a directory used to look free and would then be written to.
    local dir = fresh_root()
    local t = os.time({ year = 2026, month = 9, day = 8, hour = 14, min = 32 })
    scratch.ensure_root()
    vim.fn.mkdir(dir .. "/2026-09-08-1432.md", "p")
    assert.is_truthy(scratch.new_path(t):match("2026%-09%-08%-1432%-2%.md$"))
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

  it("refuses a relative path that resolves to the quick pad", function()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "pad" })
    -- Change to the scratch root so "quick.md" resolves to the quick pad
    local old_cwd = vim.fn.getcwd()
    vim.fn.chdir(dir)
    local ok = scratch.delete("quick.md")
    vim.fn.chdir(old_cwd)
    assert.is_false(ok)
    assert.are.equal(1, vim.fn.filereadable(scratch.quick_path()))
  end)
end)

describe("scratch promote failure reasons", function()
  -- Make the scratch directory read-only so the copy cannot be written, run
  -- promote(), then restore the permissions whatever happened.
  -- vim.loop.fs_chmod takes mode as decimal; 0o500 = r-x------, no write.
  local function promote_into_readonly_root()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "keep me", "important" })

    local old_mode = vim.loop.fs_stat(dir).mode
    vim.loop.fs_chmod(dir, tonumber("500", 8))
    local path, reason, code = scratch.promote()
    vim.loop.fs_chmod(dir, old_mode)

    return path, reason, code
  end

  it("distinguishes a failed write from an empty pad", function()
    -- Both used to return a bare nil, so the <leader>np keymap told the user
    -- "quick pad is empty" when in fact the write had failed and their text
    -- was still sitting in the pad -- the opposite of what happened.
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "", "  " })
    local empty_path, empty_reason, empty_code = scratch.promote()

    local fail_path, fail_reason, fail_code = promote_into_readonly_root()

    assert.is_nil(empty_path)
    assert.is_nil(fail_path)
    assert.are.equal("empty", empty_code)
    assert.are.equal("write_failed", fail_code)
    assert.are_not.equal(empty_reason, fail_reason)
  end)

  it("leaves the pad intact when the copy cannot be written", function()
    local _, _, code = promote_into_readonly_root()
    assert.are.equal("write_failed", code)
    assert.are.same({ "keep me", "important" }, vim.fn.readfile(scratch.quick_path()))
  end)
end)

describe("scratch promote with write failure", function()
  it("returns nil and leaves the pad intact when copy cannot be written", function()
    local dir = fresh_root()
    scratch.ensure_root()
    write_file(scratch.quick_path(), { "keep me", "important" })

    -- Make the scratch directory read-only to prevent writing the target file.
    -- vim.loop.fs_chmod takes mode as decimal; 0o500 = r-x------, no write.
    local stat = vim.loop.fs_stat(dir)
    local old_mode = stat.mode
    vim.loop.fs_chmod(dir, tonumber("500", 8))

    -- Call promote() safely: writefile will fail (either return -1 or throw
    -- an error depending on the Neovim version). Our fix is that promote()
    -- checks the return value and does NOT truncate the pad on failure.
    local ok, result = pcall(function() return scratch.promote() end)

    -- Restore permissions so the test can clean up the directory
    vim.loop.fs_chmod(dir, old_mode)

    -- Whether pcall caught an error or writefile returned -1, the key
    -- invariant is: the pad must NOT be truncated. The fix is that we check
    -- writefile's return value before truncating.
    assert.are.same({ "keep me", "important" }, vim.fn.readfile(scratch.quick_path()))
  end)
end)

describe("scratch default root normalization", function()
  it("normalizes the default root even without calling setup()", function()
    -- The default root must be normalized at declaration, not lazily in setup().
    -- On Windows, an unnormalized root causes silent autosave failure later
    -- (Task 4's is_scratch_file predicate won't match). Test the default path
    -- on a fresh module instance to avoid fresh_root()'s override.
    local old_loaded = package.loaded["config.scratch"]
    package.loaded["config.scratch"] = nil

    local fresh = require("config.scratch")
    local root = fresh.root()

    -- Restore the original module for the rest of the test suite
    package.loaded["config.scratch"] = old_loaded

    -- A normalized path is idempotent under normalization. This assertion
    -- catches unnormalized roots on any platform: Linux (expand returns
    -- forward slashes, so the bug was invisible) and Windows (backslashes
    -- would not be normalized, breaking the equality).
    assert.are.equal(vim.fs.normalize(root), root)
  end)

  it("absolutizes a relative root passed to setup()", function()
    -- The root is one half of every path comparison this module makes. If
    -- setup() stored "tmp/scratch" verbatim while inputs were absolutized,
    -- nothing would ever be recognised as a scratch file: autosave would
    -- stop, silently, and the quick-pad delete guard would stop matching.
    local base = vim.fn.tempname()
    vim.fn.mkdir(base, "p")
    local old_cwd = vim.fn.getcwd()
    vim.fn.chdir(base)
    -- Read the cwd back rather than trusting `base`: on some systems the
    -- temp directory is reached through a symlink and getcwd() resolves it.
    local cwd = vim.fs.normalize(vim.fn.getcwd())

    scratch.setup({ root = "tmp/scratch" })
    local root = scratch.root()

    vim.fn.chdir(old_cwd)
    assert.are.equal(cwd .. "/tmp/scratch", root)
  end)
end)

describe("scratch delete guards", function()
  it("refuses a file outside the scratch root", function()
    fresh_root()
    local outsider = vim.fn.tempname() .. ".md"
    write_file(outsider, { "somebody else's file" })

    local ok, reason = scratch.delete(outsider)

    assert.is_false(ok)
    assert.is_truthy(reason:match("^not a scratch file: "))
    assert.are.equal(1, vim.fn.filereadable(outsider))
    vim.fn.delete(outsider)
  end)

  it("reports a missing scratch differently from a non-scratch", function()
    local dir = fresh_root()
    scratch.ensure_root()

    local ok, reason = scratch.delete(dir .. "/never-existed.md")

    assert.is_false(ok)
    assert.is_truthy(reason:match("^no such scratch: "))
  end)
end)

describe("scratch delete_current", function()
  it("does not let autosave recreate the file it just deleted", function()
    fresh_root()
    scratch.ensure_root()
    scratch.enable_autosave()

    scratch.new_scratch()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(buf)
    -- The ordinary state of a scratch: typed into, never saved by hand.
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved text" })
    assert.is_true(vim.bo[buf].modified)
    assert.are.equal(1, vim.fn.filereadable(path))

    scratch.delete_current()

    -- Before the fix the file came straight back: closing the float fired
    -- BufLeave on a still-modified buffer and autosave wrote it out again.
    assert.are.equal(0, vim.fn.filereadable(path))
    -- Wiped, not just hidden -- otherwise the deleted scratch lingers in the
    -- buffer list and as a bufferline tab.
    assert.is_false(vim.api.nvim_buf_is_valid(buf))
  end)

  it("leaves ordinary autosave working", function()
    fresh_root()
    scratch.ensure_root()
    scratch.enable_autosave()

    scratch.toggle_quick()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "parked text" })
    scratch.toggle_quick()   -- close the float; BufLeave should write the pad

    assert.are.same({ "parked text" }, vim.fn.readfile(scratch.quick_path()))
  end)
end)
