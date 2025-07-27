return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin"

      -- Custom background color for Normal mode
      vim.api.nvim_set_hl(0, "Normal", { bg = "#0c0014" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "#0c0014" })

      -- Ensure Neo-tree and other UI components follow the same background
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#0c0014" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#0c0014" })

      -- Transparent background for Kitty terminal
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
    end
  }
}

