local curl = require("plenary.curl")
local credentials = require("jirac.storage")._credentials
local M = {}

---@alias resource
---| '"project"'
---| '"issue"'
function M.get_jira_url(resource, suffix)
    suffix = suffix or ""
    return "https://" .. credentials.domain .. "/rest/api/3/" .. resource .. "/" .. suffix
end

function M.get_base_opts()
    local opts = {
        accept = "application/json"
    }
    opts.auth = credentials.email .. ":" .. credentials.key
    return opts
end

function M.post_base_opts()
    local opts = {
        headers = {
            ["Content-Type"] = "application/json; charset=UTF-8"
        }
    }
    opts.auth = credentials.email .. ":" .. credentials.key
    return opts
end

-- function M.get_jira_issue(issue_key)
    -- P(get_jira_url(issue_key))
    -- P(get_base_opts())
    -- return curl.get(get_jira_url(issue_key), get_base_opts())
-- end

return M
