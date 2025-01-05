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
---@field get_mapping_definitions function?
---@field fetch_resources function?
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
    if self:peek().fetch_resources then
        self:peek():fetch_resources(vim.schedule_wrap(function()
            self:_recreate_renderer()
        end))
        return
    end
    self:_recreate_renderer()
end

function M.JiraWindow:_recreate_renderer()
    if self.renderer then self.renderer:close() end
    self.renderer = nui.create_renderer {
        width = self:peek().size and self:peek().size.width or require("jirac.storage").get_config().window_width,
        height = self:peek().size and self:peek().size.height or require("jirac.storage").get_config().window_height}
    self:_inject_mappings(
        vim.tbl_extend("force",
        self:_get_common_mapping_definitions(),
        self:peek().get_mapping_definitions and self:peek():get_mapping_definitions()
        or {}))
    self:_render()
end

function M.JiraWindow:_get_common_mapping_definitions()
    return {
        ["close-window"] = function () self.renderer:close() end,
        ["previous-tab"] = function () self:pop() end,
        ["refresh-window"] = function () self:update_nui() end
    }
end

function M.JiraWindow:_inject_mappings(mapping_definitions)
    local mappings = {}
    local config = require("jirac.storage").get_config()
    for k, f in pairs(mapping_definitions) do
        local keymap = config.keymaps[k] or nil
        if keymap then
            mappings[#mappings+1] = {
                mode = keymap.mode,
                key = keymap.key,
                handler = f
            }
        end
    end
    self.renderer:add_mappings(mappings)
end

---@param id string
function M.JiraWindow:get_component_by_id(id)
    return self.renderer:get_component_by_id(id)
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
