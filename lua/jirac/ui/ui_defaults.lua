local M = {}

M.PADDING = { vertical = 1, horizontal = 3 }

function M.window_width()
    return require("jirac.storage").get_config().window_width - 2 * M.PADDING.horizontal
end

function M.window_height()
    return require("jirac.storage").get_config().window_height - 2 * M.PADDING.vertical
end

return M
