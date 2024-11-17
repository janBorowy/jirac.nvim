local nui = require("nui-components")
local IssueSubmitPanel = require("jirac.ui.issue_submit_panel").IssueSubmitPanel
local NavigationPanel = require("jirac.ui.navigation_panel").NavigationPanel
local ProjectPanel = require("jirac.ui.project_panel").ProjectPanel
local ui_utils     = require("jirac.ui.ui_utils")

local M = {}

---@class Size
---@field width integer
---@field height integer

---@class Panel
---@field size Size
-- JiraWindow calls these panel methods in this order: init -> build_nui_panel -> deinit
---@field init function?
---@field build_nui_panel function
---@field deinit function?
---@field parent any
---@field renderer any

M.JiraWindow = { panels = {} }

function M.JiraWindow:show()
    if not self.is_shown then
        self.is_shown = true
        self.renderer:set_size(self:peek().size)
        self.renderer:render(self:peek():build_nui_panel())
    end
end

---@return Panel
function M.JiraWindow:peek()
    return self.panels[#self.panels]
end

function M.JiraWindow:push(panel)
    if panel.init then panel:init() end
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
    self.renderer:set_size(self:peek().size or { width = 150, height = 45 } )
    self.renderer:render(
        ui_utils.pad_component(
            self:peek():build_nui_panel()
        , 1, 3)
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
            close = "q",
            focus_next = {"<Tab>", "j"},
            focus_prev = {"<S-Tab>", "k"}
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
    --
    o:push(ProjectPanel:new {
        renderer = o.renderer,
        parent = o,
        project = require("jirac.jira_project_service").search_projects({ query = "SCRUM" }).values[1]
    })

    -- o:push(IssueSubmitPanel:new {
    --     renderer = o.renderer,
    --     parent = o,
    --     project = require("jirac.jira_project_service").search_projects({ query = "SCRUM" }).values[1]
    -- })

    return o
end

M.JiraWindowInstance = M.JiraWindow:new()
M.JiraWindowInstance:show()

return M
