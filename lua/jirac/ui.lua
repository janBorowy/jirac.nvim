local nui = require("nui-components")
local ProjectSubmitPanel = require("jirac.ui.project_submit_panel").ProjectSubmitPanel

local M = {}

M.JiraWindow = {
    width = 90,
    height = 30,
}

function M.JiraWindow:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)

    self.renderer = nui.create_renderer({
        width = o.width,
        height = o.height
    })

    self.panels = { ProjectSubmitPanel:new {parent = self, renderer = self.renderer} }

    return o
end

function M.JiraWindow:show()
    self.renderer:render(self.panels[1].panel)
end

function M.JiraWindow:pop()
    self.panels[#self.panels] = nil
    if #self.panels ~= 0 then
        self:show()
    else
        self:close()
    end
end

function M.JiraWindow:close()
    self.renderer:close()
end

M.JiraWindowInstance = M.JiraWindow:new()
M.JiraWindowInstance:show()

return M
