local popup = require("plenary.popup")
local M = {}

M.SelectionPopup = {
    opts = {}
}

---@class Array<T>: { [integer]: T }

---@class SelectionPopupParams
---@field title string
---@field options Array<string>
---@field width integer?
---@field height integer?
---@field callback function

---@param o SelectionPopupParams
function M.SelectionPopup:new(o)
    o = o or {}
    o.width = o.width or 30
    o.height = o.height or 20
    self.__index = self
    setmetatable(o, self)
    return o
end

function M.SelectionPopup:show()
    if self.window_id then
        vim.api.nvim_win_close(self.window_id, true)
    end
    self.window_id = popup.create(self.options, {
        title = self.title,
        borderchars = { "-", "|", "-", "|", "╭", "╮", "╯", "╰" },
        line = math.floor((vim.o.lines - self.height) / 2 - 1),
        col = math.floor((vim.o.columns - self.width) / 2),
        minwidth = self.width,
        minheight = self.height,
        callback = self.callback
    })

    local buf_nr = vim.api.nvim_win_get_buf(self.window_id)
    vim.api.nvim_buf_set_keymap(buf_nr, "n", "<Esc>", "lua vim.api.nvim_win_close(self.window_id, true)<CR>", { desc = "Close selection window"})
end
return M
