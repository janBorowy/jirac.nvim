local nui = require("nui-components")
local util = require("jirac.util")
local ui_defaults = require("jirac.ui.ui_defaults")

local M = {}

---@param h_pad integer
---@param v_pad integer
function M.pad_component(component, v_pad, h_pad)
    return nui.columns(
        nui.gap(h_pad),
        nui.rows(
            nui.gap(v_pad),
            component,
            nui.gap(v_pad)
        ),
        nui.gap(h_pad)
    )
end

function M.get_content_width(width)
    return width - 2 * ui_defaults.PADDING.horizontal
end

function M.get_content_height(height)
    return height - 2 * ui_defaults.PADDING.vertical
end

function M.create_nui_lines(text, wrap_len)
    wrap_len = wrap_len or 9999999
    return vim.iter(vim.tbl_map(function (v)
        if v == "" then
            return {nui.line()}
        end
        return vim.tbl_map(function (txt)
            return nui.line(nui.text(txt))
        end, util.wrap_string(v, wrap_len))
    end, vim.split(text, "\n"))):flatten():totable()
end

function M.transform_iso_date(iso_date)
    return string.sub(iso_date, 0, 10) .. " " .. string.sub(iso_date, 12, 16)
end

function M.get_label_with_shortcut(label, mapping_key, suffix)
    suffix = suffix or ""
    local keymaps = require("jirac.storage").get_config()
    local keymap = keymaps.keymaps[mapping_key]
    local key_label = keymap and keymap.mode == 'n' and keymap.key or nil
    return label .. " " .. (key_label and '(' .. key_label .. ')' or "") .. suffix
end

function M.get_field_label(label, mapping_key)
    if require("jirac.storage").get_config().show_keymaps then
        return M.get_label_with_shortcut(label, mapping_key)
    else
        return label
    end
end

return M
