-- __        ___           _                                     
-- \ \      / (_)_ __   __| | _____      __                      
--  \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / /                      
--   \ V  V / | | | | | (_| | (_) \ V  V /                       
--  __\_/\_/  |_|_| |_|\__,_|\___/ \_/\_/                    _   
-- |  \/  | __ _ _ __   __ _  __ _  ___ _ __ ___   ___ _ __ | |_ 
-- | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '_ ` _ \ / _ \ '_ \| __|
-- | |  | | (_| | | | | (_| | (_| |  __/ | | | | |  __/ | | | |_ 
-- |_| _|_|\__,_|_|_|_|\__,_|\__, |\___|_| |_| |_|\___|_| |_|\__|
-- | |/ /___ _   _| |__ (_)_ |___/__| (_)_ __   __ _ ___         
-- | ' // _ \ | | | '_ \| | '_ \ / _` | | '_ \ / _` / __|        
-- | . \  __/ |_| | |_) | | | | | (_| | | | | | (_| \__ \        
-- |_|\_\___|\__, |_.__/|_|_| |_|\__,_|_|_| |_|\__, |___/        
--           |___/                             |___/             

-- Vertical split with Alt + \
vim.api.nvim_set_keymap("n", "<A-\\>", ":vsplit<CR>", { noremap = true, silent = true })
-- Horizontal split with Alt + -
vim.api.nvim_set_keymap("n", "<A-->", ":split<CR>", { noremap = true, silent = true })
-- Close window with Alt + W
vim.api.nvim_set_keymap("n", "<A-w>", ":q<CR>", { noremap = true, silent = true })

-- Keybinding for copying to the system clipboard
vim.keymap.set("v", "<C-c>", '"+y')                                    -- Visual mode, Ctrl+c to copy
-- Keybinding for cutting to the system clipboard
vim.keymap.set("v", "<C-x>", '"+d')                                    -- Visual mode, Ctrl+x to cut
-- Keybinding for pasting from the system clipboard
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true }) -- Normal mode, Ctrl+v to paste
vim.keymap.set("v", "<C-v>", '"+p', { noremap = true, silent = true }) -- Visual mode, Ctrl+v to paste
-- Start selection and extend down with Shift + j
vim.keymap.set("n", "<S-j>", "vjj")                                    -- Start selection and extend down
-- Start selection and extend up with Shift + k
vim.keymap.set("n", "<S-k>", "vkk")                                    -- Start selection and extend up
-- Start selection and extend left with Shift + h
vim.keymap.set("n", "<S-h>", "vh")                                     -- Start selection and extend left
-- Start selection and extend right with Shift + l
vim.keymap.set("n", "<S-l>", "vl")                                     -- Start selection and extend right

-- Keybinding for selecting everything in the buffer
vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
