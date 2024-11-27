local M = {}

function M.format_to_adf(text)
    local paragraphs = {}
    for _, paragraph in ipairs(vim.split(text, "\n\n")) do
        local lines = {}
        for _, line in ipairs(vim.split(paragraph, "\n")) do
            lines[#lines+1] = line
        end
        paragraphs[#paragraphs+1] = lines
    end
    return {
        version = 1,
        type = "doc",
        content = vim.tbl_map(function (paragraph)
            return {
                type = "paragraph",
                content = vim.tbl_map(function (line)
                    return {
                        type = "text",
                        text = line .. "\n"
                    }
                end, paragraph)
            }
        end, paragraphs)
    }
end

function M.format_to_text(adf)
    return table.concat(
        vim.tbl_map(function (paragraph)
            return table.concat(
                vim.tbl_map(function (line)
                    return line.text
                end, paragraph.content)
            , "\n")
        end,
        adf.content)
    , "\n\n")
end

return M
