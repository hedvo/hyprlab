--   ____                                      
--  / ___|___  _ __ ___  _ __ ___   ___  _ __  
-- | |   / _ \| '_ ` _ \| '_ ` _ \ / _ \| '_ \ 
-- | |__| (_) | | | | | | | | | | | (_) | | | |
--  \____\___/|_| |_| |_|_| |_| |_|\___/|_| |_|
--  / _ \ _ __ | |_(_) ___  _ __  ___          
-- | | | | '_ \| __| |/ _ \| '_ \/ __|         
-- | |_| | |_) | |_| | (_) | | | \__ \         
--  \___/| .__/ \__|_|\___/|_| |_|___/         
--       |_|                       
            
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

vim.wo.number = true
