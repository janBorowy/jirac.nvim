local nui = require("nui-components")
local proj_service = require("jirac.jira_project_service")

local M = {}

M.JiraWindow = {
    width = 90,
    height = 40,
}

local search_result_box = function (projects)
    local transform_to_button = function (p)
        return nui.button {
            label = table.concat({p.id, p.name, p.id}, " | ")
        }
    end

    local project_rows = vim.tbl_map(transform_to_button, projects.values)
    project_rows[#project_rows + 1] = nui.gap({ flex = 1 })
    return nui.rows(unpack(project_rows))
end

local create_project_panel = function (renderer)

    local search_sig = nui.create_signal({
        search_phrase = "",
        is_loading = false,
        search_result = proj_service.get_projects()
    })
    local search_phrase_input_id = "search-phrase-input"

    return nui.rows(
        nui.gap(1),
        nui.paragraph {
            lines = "Project search",
            align = "center",
            is_focusable = false
        },
        nui.gap(1),
        nui.columns(
            { flex = 0 },
            nui.gap(1),
            nui.text_input {
                id = search_phrase_input_id,
                autofocus = true,
                flex = 1,
                max_lines = 1,
                placeholder = "Input search phrase...",
                border_label = "Search phrase"
            },
            nui.gap(1),
            nui.button {
                label = "Search",
                padding = {
                    top = 1,
                    right = 1
                },
                on_press = function ()
                    print("searching")
                end
            }
        ),
        nui.columns(
            nui.gap(3),
            search_result_box(search_sig:get_value().search_result)
        )
    )
end

function M.JiraWindow:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)

    self.renderer = nui.create_renderer({
        width = o.width,
        height = o.height
    })

    self.panels = { create_project_panel(self.renderer) }

    return o
end

function M.JiraWindow:show()
    self.renderer:render(self.panels[1])
end

M.JiraWindowInstance = M.JiraWindow:new()
M.JiraWindowInstance:show()

return M
