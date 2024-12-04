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
---@field default_project_key string

---@type Config
M._config = {
    default_project_key = ""
}

---@return Config
function M.get_config()
    return M._config
end

---@param c Config
function M.set_config(c)
    M._config = vim.tbl_extend("force", M._config, c)
end

return M
