local ObjectSearchPrompt = require("jirac.ui.object_search_prompt").ObjectSearchPrompt
local M = {}

---@class SearchPromptParams
---@field parent any
---@field renderer any
---@field header string?
---@field initial_query string?
---@field callback function

---@param params SearchPromptParams
function M.create_project(params)
    return ObjectSearchPrompt:new {
            renderer = params.renderer,
            parent = params.parent,
            header = params.header or "Search project",
            label_factory = function (v) return v.key .. " " .. v.name end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query)
                return require("jirac.jira_project_service").search_projects {
                    maxResults = 10,
                    query = query
                }.values
            end
    }
end

---@param params SearchPromptParams
function M.create_assignee(params)
    return ObjectSearchPrompt:new {
            renderer = params.renderer,
            parent = params.parent,
            header = params.header or "Search assignee",
            label_factory = function (v) return v.displayName end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query)
                return require("jirac.jira_user_service").search_users {
                    maxResults = 10,
                    query = query
                }
            end
    }
end

return M
