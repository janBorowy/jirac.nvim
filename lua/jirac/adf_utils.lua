local M = {}

function M.format_to_adf(text)
    local paragraphs = {}
    for _, paragraph in ipairs(vim.split(text, "\n\n")) do
        local lines = {}
        for _, line in ipairs(vim.split(paragraph, "\n")) do
            lines[#lines+1] = line
            lines[#lines+1] = "\n"
        end
        lines[#lines] = nil
        paragraphs[#paragraphs+1] = lines
    end
    return {
        version = 1,
        type = "doc",
        content = vim.tbl_map(function (paragraph)
            return {
                type = "paragraph",
                content = vim.tbl_map(function (line)
                    return line ~= "\n" and {
                        type = "text",
                        text = line
                    } or {
                        type = "hardBreak"
                    }
                end, paragraph)
            }
        end, paragraphs)
    }
end

local map_node

local TAB_STR = "  "

local function map_with_tab(depth, txt)
    return string.rep(TAB_STR, depth) .. txt
end

local inline_node_mappers = {
    ["text"] = function (n) return map_with_tab(n.depth, n.text) end,
    ["hardBreak"] = function () return "\n" end,
    ["media"] = function (n) return map_with_tab(n.depth, "(image)[" .. n.attrs.alt .. "]") end,
    ["emoji"] = function (n) return map_with_tab(n.depth, n.attrs.text) end,
}

---@param node AdfNodeWithContext
local function map_sequential(node, append_newlines)
    return table.concat(
        vim.tbl_map(function (child_node)
            child_node.depth = node.depth
            child_node.prefix = node.prefix
            return map_node(child_node) .. (append_newlines and "\n" or "")
        end, node.content)
    )
end

local child_block_node_mappers = {
    ["listItem"] = function (n) return map_with_tab(n.depth, '- ' .. map_sequential(n)) end
}

local block_node_mappers = {
    ["paragraph"] = function (n)
            return map_sequential(n)
        end,
    ["blockquote"] = function (n)
        return "'''\n" ..
            map_sequential(n)
        .. "\n'''\n"
    end,
    ["bulletList"] = function (n)
        return map_sequential(n, true)
    end,
    -- ["codeBlock"] = function (n) return map_node(n.content) end,
    -- ["expand"] = function (n) return map_node(n.content) end,
    ["heading"] = function (n)
        return string.rep(TAB_STR, n.depth) .. string.rep("#", n.attrs.level)
            .. map_sequential(n)
    end,
    -- ["mediaGroup"] = function (n) return map_node(n.content) end,
    -- ["mediaSingle"] = function (n) return map_node(n.content) end,
    -- ["orderedList"] = function (n) return map_node(n.content) end,
    -- ["panel"] = function (n) return map_node(n.content) end,
    -- ["rule"] = function (n) return map_node(n.content) end,
    -- ["table"] = function (n) return map_node(n.content) end,
    -- ["multiBodiedExtension"] = function (n) return map_node(n.content) end,
}

---@param node AdfNodeWithContext
---@return string
map_node = function (node)
    if inline_node_mappers[node.type] then
        return node.prefix .. inline_node_mappers[node.type](node)
    elseif block_node_mappers[node.type] then
        return node.prefix .. block_node_mappers[node.type](node)
    elseif child_block_node_mappers[node.type] then
        return node.prefix .. child_block_node_mappers[node.type](node)
    end
    return node.prefix .. "JiraC: UNPROCESSABLE ADF NODE: " .. node.type
end

---@class AdfNode
---@field version integer,
---@field type string,
---@field content Array<string>?
---@field text string?

---@class AdfNodeWithContext : AdfNode
---@field depth integer
---@field prefix string

---@param adf AdfNode
---@return string
function M.parse(adf)
    assert(adf.type == "doc")
    return table.concat(
        vim.tbl_map(function (block_node)
            block_node.depth = 0
            block_node.prefix = ""
            return map_node(block_node)
        end,
        adf.content)
    , "\n\n")
end

return M
