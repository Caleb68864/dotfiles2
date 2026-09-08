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
