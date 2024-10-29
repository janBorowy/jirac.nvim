local jira_service = require("jirac.jira_service")
local credentials = require("jirac.storage")._credentials

local M = {}

M.setup = function (opts)

    opts = opts or {}

    assert(opts.api_key, "Missing api_key option")
    assert(opts.email, "Missing email option")
    assert(opts.jira_domain, "Missing jira_domain option")

    credentials.key = opts.api_key
    credentials.email = opts.email
    credentials.domain = opts.jira_domain

end

local JiraIssue = function (opts)

    if not opts.fargs[1] then
        error "issue_key is required"
    end

    P(jira_service.get_jira_issue(opts.fargs[1]))

end

vim.api.nvim_create_user_command('JiraIssue', JiraIssue, {
    desc = "Fetches info about jira issue",
    nargs = 1
})

return M
