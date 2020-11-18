(local theme_assets (require "beautiful.theme_assests"))
(local xresources (require "beautiful.xresources"))
(local dpi (xresources.apply_dpi))
(local gfs (require "gears.filesystem"))
(local themes_path (gfs.get_themes_dir))

(local xrdb (beautiful.xresources.get_current_theme))

(local xcolors {
                :bg xrdb.background
                :fg xrdb.foreground
                :black xrdb.color0
                :red xrdb.color1
                :green xrdb.color2
                :yellow xrdb.color3
                :blue xrdb.color4
                :magenta xrdb.color5
                :cyan xrdb.color6
                :white xrdb.color7
                :bblack xrdb.color8
                :bred xrdb.color9
                :bgreen xrdb.color10
                :byellow xrdb.color11
                :bblue xrdb.color12
                :bmagenta xrdb.color13
                :bcyan xrdb.color14
                :bwhite xrdb.color15})

(local font "Source Sans Pro 11")


(local bg_normal      xrdb.bg)
(local bg_focus       xrdb.bg)
(local bg_urgent      xrdb.bg)
(local bg_minimize    xrdb.bblack)
(local bg_systray     bg_normal)

(local fg_normal      xrdb.white)
(local fg_focus       xrdb.white)
(local fg_urgent      xrdb.yellow)
(local fg_minimize    xrdb.bwhite)

(local useless_gap          (dpi 0))
(local border_width         (dpi 1))
(local border_color_normal  xrdb.bblack)
(local border_color_active  xrdb.cyan)
(local border_color_marked  xrdb.magenta)

(local taglist_square_size (dpi 3))
(local taglist_squares_sel (theme_assets.taglist_squares_sel
                                                            taglist_square_size
                                                            theme.fg_normal))
(local taglist_squares_unsel (theme_assets.taglist_squares_unsel
                               taglist_square_size theme.fg_normal))
(theme.menu_submenu_icon ( .. themes_path "default/submenu.png"))
(theme.menu_height = (dpi 15))
(theme.menu_width  = (dpi 100))


