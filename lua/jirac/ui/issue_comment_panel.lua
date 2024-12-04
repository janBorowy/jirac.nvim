local nui = require("nui-components")
local comment_service = require("jirac.jira_comment_service")
local ui_utils = require("jirac.ui.ui_utils")
local ui_defaults = require("jirac.ui.ui_defaults")
local ConfirmationPanel = require("jirac.ui.confirmation_panel").ConfirmationPanel
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel
local TextInputPrompt = require("jirac.ui.text_input_prompt").TextInputPrompt

local M = {}

local PAGE_SIZE = 3

M.IssueCommentPanel = {
    issue = {},
    page = 1
}

function M.IssueCommentPanel:_handle_error_response(obj)
    self.parent:push(ErrorPanel:new {
        errors = obj.errors,
        parent = self.parent
    })
end

function M.IssueCommentPanel:_handle_add_comment()
    self.parent:push(TextInputPrompt:new {
        parent = self.parent,
        border_label = "Comment content",
        initial_value = "",
        callback = function (text)
            local success, obj = pcall(comment_service.post_comment, {
                issue_id_or_key = self.issue.key,
                text = text
            })
            if success then
                self.parent:pop()
            else
                self:_handle_error_response(obj)
            end
        end
    })
end

function M.IssueCommentPanel:_handle_edit_comment(c)
    self.parent:push(TextInputPrompt:new {
        parent = self.parent,
        border_label = "New comment content",
        initial_value = c.text,
        callback = function (new_text)
            if c.text == new_text then
                self.parent:pop()
                return
            end
            local success, obj = pcall(comment_service.edit_comment, {
                issue_id_or_key = self.issue.key,
                comment_id = c.id,
                text = new_text
            })
            if success then
                self.parent:pop()
            else
                self:_handle_error_response(obj)
            end
        end
    })
end

function M.IssueCommentPanel:_handle_delete_comment(comment)
    self.parent:push(ConfirmationPanel:new {
        parent = self.parent,
        title_paragraph = "Delete this comment?",
        message = "Once you delete, it's gone for good",
        yes_label = "Delete",
        no_label = "No",
        callback = function ()
            local success, obj = pcall(comment_service.delete_comment, {
                issue_id_or_key = self.issue.id,
                comment_id = comment.id
            })

            if success then
                self.parent:update_nui()
                if #self.api_response.values == 0 then
                    self.page = self.page - 1
                    self.parent:update_nui()
                end
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssueCommentPanel:_get_max_page()
    if self.api_response.total == 0 then return 1 end
    return math.ceil(self.api_response.total / PAGE_SIZE)
end

function M.IssueCommentPanel:_handle_next_page()
    if self.page < self:_get_max_page() then
        self.parent:swap(M.IssueCommentPanel:new {
            parent = self.parent,
            issue = self.issue,
            page = self.page + 1
        })
    end
end

function M.IssueCommentPanel:_handle_previous_page()
    if self.page > 1 then
        self.parent:swap(M.IssueCommentPanel:new {
            parent = self.parent,
            issue = self.issue,
            page = self.page - 1
        })
    end
end

function M.IssueCommentPanel:_is_user_comment(c)
    local credentials = require("jirac.storage")._credentials
    return c.author.emailAddress == credentials.email
end

function M.IssueCommentPanel:_fetch_comments()
    return comment_service.get_comments {
        issue_id_or_key = self.issue.id,
        max_results = PAGE_SIZE,
        start_at = (self.page - 1) * PAGE_SIZE,
        order_by = "-created"
    }
end

function M.IssueCommentPanel:_create_comment_components()
    return vim.tbl_map(function (c)
        return nui.rows(
            nui.paragraph {
                lines = c.author.displayName .. " " .. ui_utils.transform_iso_date(c.created),
                align = "left",
                is_focusable = false
            },
            nui.gap(1),
            nui.paragraph {
                flex = 1,
                lines = ui_utils.create_nui_lines(c.text, ui_defaults.window_width()),
            },
            nui.gap(1),
            unpack(self:_is_user_comment(c) and { nui.columns(
                { flex = 0 },
                nui.button {
                    label = "Edit",
                    on_press = function () self:_handle_edit_comment(c) end
                },
                nui.gap(4),
                nui.button {
                    label = "Delete",
                    on_press = function () self:_handle_delete_comment(c) end
                },
                nui.gap { flex = 1 }
            )} or {})
        )
    end, self.api_response.values)
end

function M.IssueCommentPanel:build_nui_panel()
    self.api_response = self:_fetch_comments()
    local components = {}
    table.insert(components, nui.paragraph {
            align = "center",
            lines = "Comments for " .. self.issue.key,
            autofocus = true
        })
    local comment_components = self:_create_comment_components()
    if #comment_components > 0 then
        for _, comment in ipairs(comment_components) do
            table.insert(components, comment)
        end
    else
        table.insert(components, nui.gap { flex = 1 })
        table.insert(components, nui.paragraph {
            lines = "Issue has no comments yet"
        })
        table.insert(components, nui.gap { flex = 1 })
    end
    table.insert(components,
        nui.columns(
            { flex = 0 },
            nui.button {
                label = "Previous page",
                on_press = function () self:_handle_previous_page() end
            },
            nui.gap(1),
            nui.paragraph {
                lines = tostring(self.page) .. " / " .. tostring(self:_get_max_page()),
                is_focusable = false
            },
            nui.gap(1),
            nui.button {
                label = "Next page",
                on_press = function () self:_handle_next_page() end
            },
            nui.gap { flex = 1 },
            nui.button {
                label = "Add comment",
                on_press = function () self:_handle_add_comment() end
            }
        )
    )
    table.insert(components, nui.gap(1))
    return nui.rows(unpack(components))
end
---@class IssueCommentPanelParams : Panel
---@field issue IssueDetailed
---@field page integer
---@field api_response GetCommentsResponse?

---@param o IssueCommentPanelParams
function M.IssueCommentPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
