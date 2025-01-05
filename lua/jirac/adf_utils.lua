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

local function date_str_from_epoch(epoch)
    return os.date("%Y-%m-%d", epoch)
end

local inline_node_mappers = {
    ["text"] = function (n) return map_with_tab(n.depth, n.text) end,
    ["hardBreak"] = function () return "\n" end,
    ["media"] = function (n) return map_with_tab(n.depth, "(image)[" .. n.attrs.alt .. "]") end,
    ["emoji"] = function (n) return map_with_tab(n.depth, n.attrs.text) end,
    ["mention"] = function (n) return map_with_tab(n.depth, n.attrs.text) end,
    ["date"] = function (n) return map_with_tab(n.depth, date_str_from_epoch()) end,
    ["status"] = function (n) return map_with_tab(n.depth, n.attrs.text) end,
}

---@param node AdfNodeWithContext
local function map_sequential(node, append_newlines)
    return table.concat(
        vim.tbl_map(function (child_node)
            child_node.depth = node.depth
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
    ["heading"] = function (n)
        return string.rep(TAB_STR, n.depth) .. string.rep("#", n.attrs.level)
            .. map_sequential(n)
    end,
    ["codeBlock"] = function (n)
        return "'''" .. n.attrs.language .. "\n" ..
            map_sequential(n)
        .. "\n'''\n"
    end,
    ["rule"] = function () return "\n" .. string.rep("-", 50) .. "\n" end,
    ["expand"] = function (n)
        return "..." .. (n.attrs.title or "") .. "\n" .. map_sequential(n) .. "\n"
    end,
    ["mediaGroup"] = function (n) return map_sequential(n, true) end,
    ["mediaSingle"] = function (n) return map_sequential(n, true) end,
    ["orderedList"] = function (n) return map_sequential(n, true) end,
}

---@param node AdfNodeWithContext
---@return string
map_node = function (node)
    if inline_node_mappers[node.type] then
        return inline_node_mappers[node.type](node)
    elseif block_node_mappers[node.type] then
        return block_node_mappers[node.type](node)
    elseif child_block_node_mappers[node.type] then
        return child_block_node_mappers[node.type](node)
    end
    return "JiraC: UNPROCESSABLE ADF NODE: " .. node.type
end

---@class AdfNode
---@field version integer,
---@field type string,
---@field content Array<string>?
---@field text string?

---@class AdfNodeWithContext : AdfNode
---@field depth integer

---@param adf AdfNode
---@return string
function M.parse(adf)
    assert(adf.type == "doc")
    return table.concat(
        vim.tbl_map(function (block_node)
            block_node.depth = 0
            return map_node(block_node)
        end,
        adf.content)
    , "\n\n")
end

return M
