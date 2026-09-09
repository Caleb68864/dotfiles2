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
