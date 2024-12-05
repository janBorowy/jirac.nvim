local storage = require("jirac.storage")
local jira_issue_service = require("jirac.jira_issue_service")
local prompt_factory = require("jirac.ui.prompt_factory")

local JiraWindow = require("jirac.ui.ui").JiraWindow
local IssuePanel = require("jirac.ui.issue_panel").IssuePanel
local ProjectPanel = require("jirac.ui.project_panel").ProjectPanel

local M = {}

---@class SetupOptions
---@field api_key string
---@field email string
---@field jira_domain string
---@field config Config?

function M.setup(opts)

    opts = opts or {}

    assert(opts.api_key, "Missing api_key option")
    assert(opts.email, "Missing email option")
    assert(opts.jira_domain, "Missing jira_domain option")

    storage.set_credentials {
        api_key = opts.api_key,
        email = opts.email,
        jira_domain = opts.jira_domain
    }

    storage.set_config(opts.config or {})

end

---@param issue_id string
---@param project_key string
local function create_issue_panel(issue_id, project_key)
    local window = JiraWindow:new()
    window:push(IssuePanel:new {
        issue_id_or_key = issue_id,
        project_key = project_key
    })
end

---@param search_phrase string
---@param project_key string
local function create_issue_prompt(search_phrase, project_key)
    local window = JiraWindow:new()
    window:push(prompt_factory.create_issue {
        project_key = project_key,
        initial_query = search_phrase,
        callback = function (issue)
            window:push(IssuePanel:new {
                issue_id_or_key  = issue.id,
                project_key = project_key
            })
        end
    })
end

local function handle_jirac_issue(opts)
    local args = opts.fargs or {}
    local project_key = args[2] or storage.get_config().default_project_key

    local success, obj = pcall(create_issue_panel, args[1], project_key)
    if not success then
        error (vim.inspect(obj))
    end
end

vim.api.nvim_create_user_command('JiracIssue', handle_jirac_issue, {
    nargs = "+"
})

local function handle_jirac_issue_search(opts)
    local args = opts.fargs or {}
    local project_key = args[2] or storage.get_config().default_project_key

    local success, obj = pcall(create_issue_prompt, args[1] or "", project_key)
    if not success then
        error (vim.inspect(obj))
    end
end

vim.api.nvim_create_user_command('JiracIssueSearch', handle_jirac_issue_search, {
    nargs = "?"
})

local function create_project_panel(project_key)
    local window = JiraWindow:new()
    window:push(ProjectPanel:new {
        project_id_or_key = project_key
    })
end

local function handle_jirac_project(opts)
    local args = opts.fargs or {}
    local project_key = args[1] or storage.get_config().default_project_key
    local success, obj = pcall(create_project_panel, project_key)
    if not success then
        error (vim.inspect(obj))
    end
end

vim.api.nvim_create_user_command('JiracProject', handle_jirac_project, {
    nargs = "?"
})

local function create_project_prompt(search_phrase)
    local window = JiraWindow:new()
    window:push(prompt_factory.create_project {
        initial_query = search_phrase,
        callback = function (project)
            window:push(ProjectPanel:new {
                project_id_or_key = project.key
            })
        end
    })
end

local function handle_jirac_project_search(opts)
    local search_phrase = opts.fargs[1] or ""

    local success, obj = pcall(create_project_prompt, search_phrase)
    if not success then
        error (vim.inspect(obj))
    end
end

vim.api.nvim_create_user_command('JiracProjectSearch', handle_jirac_project_search, {
    nargs = "?"
})
return M
