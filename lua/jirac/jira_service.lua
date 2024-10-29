local curl = require("plenary.curl")
local credentials = require("jirac.storage")._credentials
local M = {}

local function get_jira_url(suffix)
    return "https://" .. credentials.domain .. "/rest/api/3/issue/" .. suffix
end

local function get_base_opts()
    local opts = {
        accept = "application/json"
    }
    opts.auth = credentials.email .. ":" .. credentials.key
    return opts
end

function M.get_jira_issue(issue_key)
    P(get_jira_url(issue_key))
    P(get_base_opts())
    return curl.get(get_jira_url(issue_key), get_base_opts())
end

return M
