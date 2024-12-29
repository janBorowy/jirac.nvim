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
---@field window_width integer
---@field window_height integer

---@type Config
M._config = {
    default_project_key = "",
    window_width = 150,
    window_height = 50,
    keymaps = {}
}

local default_keymaps = {
    ["close_window"] = {
        mode = 'n',
        key = 'q'
    },
    ["previous_tab"] = {
        mode = 'n',
        key = 'H'
    },
    ["refresh_window"] = {
        mode = 'n',
        key = "<F5>"
    }
}

---@return Config
function M.get_config()
    return M._config
end

---@param c Config
function M.set_config(c)
    M._config = vim.tbl_extend("force", M._config, c)
    M._config.keymaps = vim.tbl_extend("force", default_keymaps, c.keymaps)
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
