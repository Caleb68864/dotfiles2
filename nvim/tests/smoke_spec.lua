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
