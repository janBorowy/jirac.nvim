local nui = require("nui-components")
local ui_defaults = require("jirac.ui.ui_defaults")
local ui_utils = require("jirac.ui.ui_utils")

local M = {}

---@class Size
---@field width integer
---@field height integer

---@class Panel
---@field size Size
---@field build_nui_panel function
---@field handle_signal function?
---@field parent any
---@field new function
---@field __index any

M.JiraWindow = {}

---@return Panel
function M.JiraWindow:peek()
    return self.panels[#self.panels]
end

function M.JiraWindow:push(panel)
    panel.parent = self
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

function M.JiraWindow:swap(panel)
    self.panels[#self.panels] = nil
    self:push(panel)
end

function M.JiraWindow:update_nui()
    if self.renderer then self.renderer:close() end
    self.renderer = nui.create_renderer {
        width = self:peek().size and self:peek().size.width or ui_defaults.DEFAULT_SIZE.width,
        height = self:peek().size and self:peek().size.height or ui_defaults.DEFAULT_SIZE.height
    }
    self:_inject_default_mappings()
    self:_render()
end

function M.JiraWindow:_inject_default_mappings()
    self.renderer:add_mappings({
        {
            mode = 'n',
            key = 'q',
            handler = function () self.renderer:close() end
        },
        {
            mode = 'n',
            key = "H",
            handler = function () self:pop() end
        }
    })
end

---@param signal JiracWindowSignal
function M.JiraWindow:handle_signal(signal)
    if self:peek().handle_signal then
        self:peek():handle_signal(signal)
    end
end

function M.JiraWindow:_render()
    self.renderer:render(
        ui_utils.pad_component(
            self:peek():build_nui_panel()
        , ui_defaults.PADDING.vertical, ui_defaults.PADDING.horizontal)
    )
    self.renderer:redraw()
end

function M.JiraWindow:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    o.panels = {}
    return o
end

return M
