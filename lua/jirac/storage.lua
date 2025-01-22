local M = {}

---@class Credentials
---@field api_key string
---@field email string
---@field jira_domain string

---@type Credentials
M._credentials = nil

---@return Credentials
function M.get_credentails()
    return M._credentials
end

---@param c Credentials
function M.set_credentials(c)
    M._credentials = c
end

---@class Config
---@field default_project_key string?
---@field keymaps table?
---@field show_keymaps boolean
---@field window_width integer
---@field window_height integer

---@type Config
M._config = {
    default_project_key = "",
    show_keymaps = true,
    window_width = 150,
    window_height = 50,
    keymaps = {}
}

local default_keymaps = {
    --- default general mappings
    ["close-window"] = {
        mode = 'n',
        key = 'q'
    },
    ["previous-tab"] = {
        mode = 'n',
        key = 'H'
    },
    ["refresh-window"] = {
        mode = 'n',
        key = "<F5>"
    },

    -- Issue panel default mappings
    ["focus-description"] = {
        mode = 'n',
        key = 'd'
    },
    ["focus-comments"] = {
        mode = 'n',
        key = 'c'
    },
    ["focus-open-jira"] = {
        mode = 'n',
        key = 'o'
    },
    ["focus-status"] = {
        mode = 'n',
        key = 's'
    },
    ["focus-assignee"] = {
        mode = 'n',
        key = 'a'
    },
    ["focus-parent"] = {
        mode = 'n',
        key = 'p'
    },
    ["focus-reporter"] = {
        mode = 'n',
        key = 'r'
    },
    ["yank-issue-key"] = {
        mode = 'n',
        key = 'yk'
    }
}

---@return Config
function M.get_config()
    return M._config
end

---@param c Config
function M.set_config(c)
    M._config = vim.tbl_extend("force", M._config, c)
    if (c.keymaps) then
        M._config.keymaps = vim.tbl_extend("force", default_keymaps, c.keymaps)
    else
        M._config.keymaps = {}
    end
end

M._window = nil

function M.get_window()
    return M._window
end

function M.set_window(window)
    M._window = window
    return M._window
end

return M
