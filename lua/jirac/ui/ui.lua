local nui = require("nui-components")
local NavigationPanel = require("jirac.ui.navigation_panel").NavigationPanel
local ProjectPanel = require("jirac.ui.project_panel").ProjectPanel
local IssuePanel = require("jirac.ui.issue_panel").IssuePanel
local PromptFactory = require("jirac.ui.object_search_prompts")
local TextInputPrompt = require("jirac.ui.text_input_prompt").TextInputPrompt
local IssueCommentPanel = require("jirac.ui.issue_comment_panel").IssueCommentPanel
local ui_defaults = require("jirac.ui.ui_defaults")
local ui_utils = require("jirac.ui.ui_utils")
local ConfirmationPanel = require("jirac.ui.confirmation_panel").ConfirmationPanel

local M = {}

---@class Size
---@field width integer
---@field height integer

---@class Panel
---@field size Size
---@field init function?
---@field build_nui_panel function
---@field deinit function?
---@field parent any
---@field renderer any
---@field new function
---@field __index any

M.JiraWindow = { panels = {} }

---@return Panel
function M.JiraWindow:peek()
    return self.panels[#self.panels]
end

function M.JiraWindow:push(panel)
    local former = self:peek()
    if former and former.deinit then former:deinit() end
    self.panels[#self.panels + 1] = panel
    self:update_nui()
end

function M.JiraWindow:pop()
    local panel = self.panels[#self.panels]
    if panel.deinit then panel:deinit() end
    self.panels[#self.panels] = nil
    if #self.panels ~= 0 then
        self:update_nui()
    else
        self.renderer:close()
    end
end

function M.JiraWindow:update_nui()
    self.renderer:close()
    self.renderer:set_size(self:peek().size or ui_defaults.DEFAULT_SIZE )
    if self:peek() and self:peek().init then self:peek():init() end
    self.renderer:render(
        ui_utils.pad_component(
            self:peek():build_nui_panel()
        , ui_defaults.PADDING.vertical, ui_defaults.PADDING.horizontal)
    )
end

---@class MappingAllModes
---@field key string
---@field handler function

---@param mappings Array<MappingAllModes>
function M.JiraWindow:add_mappings(mappings)
    for _, v in ipairs(mappings) do
        self.renderer:add_mappings({{
            mode = { "n", "i", "v" },
            key = v.key,
            handler = v.handler
        }})
    end
end

---@param mappings Array<string>
function M.JiraWindow:clear_mappings(mappings)
    for _, v in ipairs(mappings) do
        self.renderer:add_mappings({{
            mode = { "n", "i", "v" },
            key = v,
            handler = function () end
        }})
    end
end

function M.JiraWindow:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)

    o.renderer = nui.create_renderer({
        keymap = {
            close = "q"
        }
    })

    o.renderer:add_mappings ({
        {
            mode = {'n', 'i', 'v'},
            key = "H",
            handler = function () o:pop() end
        }
    })

    -- o:push(NavigationPanel:new {
    --     renderer = o.renderer,
    --     parent = o
    -- })

    -- o:push(ProjectPanel:new {
    --     renderer = o.renderer,
    --     parent = o,
    --     project = require("jirac.jira_project_service").search_projects({ query = "SCRUM" }).values[1]
    -- })
    --
    o:push(IssuePanel:new {
        renderer = o.renderer,
        parent = o,
        issue_id_or_key = "SCRUM-1"
    })
    -- o:push(IssueCommentPanel:new {
    --     renderer = o.renderer,
    --     parent = o,
    --     issue = require("jirac.jira_issue_service").get_issue_detailed "SCRUM-1",
    --     page = 1
    -- })
    -- o:push(ConfirmationPanel:new {
    --     renderer = o.renderer,
    --     parent = o,
    --     title_paragraph = "Delete this comment?",
    --     message = "Once you delete, it's gone for good",
    --     yes_label = "Delete",
    --     no_label = "No",
    --     callback = function () P("deleting") end
    -- })

    return o
end

M.JiraWindowInstance = M.JiraWindow:new()
M.JiraWindowInstance:update_nui()

return M
