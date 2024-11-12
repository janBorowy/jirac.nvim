local nui = require("nui-components")
local ProjectSubmitPanel = require("jirac.ui.project_submit_panel").ProjectSubmitPanel
local PromptPanel = require("jirac.ui.prompt_panel").PromptPanel
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel

local M = {}

---@class Size
---@field width integer
---@field height integer

---@class Panel
---@field size Size
---@field build_nui_panel function

-- TODO: make configurable in plugin setup
M.JiraWindow = {
    width = 90,
    height = 30,
}

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
    self.panels[#self.panels + 1] = panel
    self:update_nui()
end

function M.JiraWindow:pop()
    self.panels[#self.panels] = nil
    if #self.panels ~= 0 then
        self:update_nui()
    else
        self.renderer:close()
    end
end

function M.JiraWindow:update_nui()
    self.renderer:close()
    self.renderer:set_size(self:peek().size)
    self.renderer:render(self:peek():build_nui_panel())
end

function M.JiraWindow:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)

    o.renderer = nui.create_renderer({
        width = o.width,
        height = o.height
    })

    self.panels = { PromptPanel:new {
        renderer = o.renderer,
        title = "Echo panel",
        form_id = "echo_form_id",
        border_label = "Text",
        placeholder = "Enter input",
        button_label = "echo",
        on_submit = function (v) print(v) end
    }}

    return o
end

M.JiraWindowInstance = M.JiraWindow:new()
M.JiraWindowInstance:show()

return M
