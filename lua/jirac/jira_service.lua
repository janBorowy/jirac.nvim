local M = {}

function M.get_jira_url(resource, suffix)
    local credentials = require("jirac.storage").get_credentails()
    suffix = suffix or ""
    return "https://" .. credentials.jira_domain .. "/rest/api/3/" .. resource .. "/" .. suffix
end

function M.get_jira_browse_url(issue_id_or_key)
    local credentials = require("jirac.storage").get_credentails()
    return "https://" .. credentials.jira_domain .. "/browse/" .. issue_id_or_key
end

function M.get_base_opts()
    local credentials = require("jirac.storage").get_credentails()
    local opts = {
        accept = "application/json"
    }
    opts.auth = vim.trim(credentials.email) .. ":" .. vim.trim(credentials.api_key)
    return opts
end

function M.post_base_opts()
    local credentials = require("jirac.storage").get_credentails()
    local opts = {
        headers = {
            ["Content-Type"] = "application/json; charset=UTF-8"
        }
    }
    opts.auth = vim.trim(credentials.email) .. ":" .. vim.trim(credentials.api_key)
    return opts
end

return M
