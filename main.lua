--- STEAMODDED HEADER
--- MOD_NAME: Float
--- MOD_ID: AizFloat
--- MOD_AUTHOR: [Aiz]
--- VERSION: 1.0.0
--- MOD_DESCRIPTION: Add floating sprites to playing cards. like the souls on jokers

----------------------------------------------
------------MOD CODE -------------------------

local current_mod = SMODS.current_mod
local config = current_mod.config

-- you can change this if you want to use a file with a different name
local atlas = "cards_floating"

-- config that I don't know how to put in the config tab
local float_config = {
    width = 1, -- multiplicative on default card
    height = 1, -- ^^
    shadow_height = 0,
}

-- the atlas for the floating sprites.
-- change px and py if you are using higher res sprites
SMODS.Atlas({
    key = atlas,
    path = atlas .. ".png",
    px = 71,
    py = 95,
})

-- CODE to make this work from here on
function Add_floating_sprite_atlas(card)
    if card.children.floating_sprite then
        card.children.floating_sprite:set_sprite_pos(card.config.card.pos)
        return
    end
    card.children.floating_sprite = Sprite(
        card.T.x,
        card.T.y,
        card.T.w * float_config.width,
        card.T.h * float_config.height,
        G.ASSET_ATLAS[current_mod.prefix .. "_" .. atlas],
        card.config.card.pos
    )
    card.children.floating_sprite.role.draw_major = card
    card.children.floating_sprite.states.hover.can = false
    card.children.floating_sprite.states.click.can = false
end

local function draw_centered(card, shadow, ms, mr, mx, my, tilt_shadow)
    card.children.floating_sprite:draw_shader(
        "dissolve",
        shadow,
        nil,
        nil,
        card.children.center,
        ms or 0,
        mr or 0,
        (mx or 0) + (card.children.center.VT.w - card.children.floating_sprite.VT.w) / 2,
        (my or 0) + (card.children.center.VT.h - card.children.floating_sprite.VT.h) / 2,
        nil,
        tilt_shadow
    )
end

function Draw_floating_sprite_playing_card(card)
    if card.ability.effect == "Stone Card" and config.hide_on_stone then return end

    local scale_mod = 0.07
    local rotate_mod = 0.05
    local shadow_y_mod = 0.1
    if config.soul_animation then
        scale_mod = scale_mod + 0.02 * math.sin(1.8 * G.TIMERS.REAL)
        rotate_mod = rotate_mod * math.sin(1.219 * G.TIMERS.REAL)
        shadow_y_mod = shadow_y_mod + 0.03 * math.sin(1.8 * G.TIMERS.REAL)
    end
    if config.shadow then
        draw_centered(
            card,
            float_config.shadow_height,
            scale_mod,
            rotate_mod,
            0,
            shadow_y_mod,
            0.6 -- idk same as vanilla
        )
    end
    draw_centered(card, nil, scale_mod, rotate_mod)
end

-- Config

---create a toggle for a config setting followed by a text description
---@param key string
---@return table node
local function create_toggle_wrapper(key)
    return {
        n = G.UIT.R,
        config = { align = "cl", padding = 0 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cl", padding = 0.05 },
                nodes = {
                    create_toggle({
                        col = true,
                        label = "",
                        scale = 0.85,
                        w = 0,
                        shadow = true,
                        ref_table = config,
                        ref_value = key,
                    }),
                },
            },
            {
                n = G.UIT.C,
                config = { align = "c", padding = 0 },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_" .. current_mod.prefix .. "_" .. key),
                            scale = 0.35,
                            colour = G.C.UI.TEXT_LIGHT,
                        },
                    },
                },
            },
        },
    }
end
current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            r = 0.1,
            align = "t",
            padding = 0.1,
            colour = G.C.BLACK,
            minw = 8,
            minh = 6,
        },
        nodes = {
            create_toggle_wrapper("hide_on_stone"),
            create_toggle_wrapper("soul_animation"),
            create_toggle_wrapper("shadow"),
        },
    }
end
sendInfoMessage("Loaded Float~~~ :3")
