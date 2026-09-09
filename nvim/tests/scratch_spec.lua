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
