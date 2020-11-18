(local f (require "fun"))
(require-macros :awesome-macros)
;; standard awesome library
(local gears (require "gears"))
(local awful (require "awful"))
(require "awful.autofocus")
;; wiget and layout library
(local wibox (require "wibox"))
;; theme handling library
(local beautiful (require "beautiful"))
;; Notification library
(local naughty (require "naughty"))
;; Declarative object managment
(local ruled (require "ruled"))
(local menubar (require "menubar"))
(local hotkeys_popup (require "awful.hotkeys_popup"))
;;Enable hotkeys help widget for VIM and other apps
;; when client with a matching name is opened:
(require "awful.hotkeys_popup.keys")

;; {{{ Handling error and fallback to default config
(naughty.connect_signal
  "request::display-error"
  (fn [message startup]
      (naughty.notification
        { :urgency "critical"
          :title (.. "Oops, an error happened huhu"
                      (or
                        (and startup "during startup!")
                        "!"))
          :message message})))
;;}}}

;{{{ Debug
(local debug (fn [message] (naughty.notification {
                                                  :urgency "critical"
                                                  :title "heleo"
                                                  :message message})))
;}}}

;;{{{ Variable definations

;; Theme define colours, icons, font and wallpaper
(beautiful.init "/home/violeine/.config/awesome/theme.lua")
;; This is used later as the default terminal and editor to turn.
(set beautiful.useless_gap 2)
(global terminal "st")
(global editor (or (os.getenv "EDITOR") "nvim"))
(global editor_cmd (.. terminal "-e" editor))
(global modkey "Mod4")
(set beautiful.wallpaper "/home/violeine/Downloads/wall.png")
(local title-toggle-rule ((fn []
                            (var title-bar-state false)
                            (fn []
                              ((ruled.client.append_rule {}
                                 :id          "titlebars"
                                 :rule_any    { :type  [ "normal" "dialog"]}
                                 :properties  { :titlebars_enabled title-bar-state}))))))
;;;}}}

;;{{{ Menu
;; Create a laucher widget and a main menu

(global myawesomemenu [
                       [:hotkey (fn []
                                    (hotkeys_popup.show_help
                                      nil
                                      (awful.screen.focused)))]
                       [:manual (.. terminal "-e man awesome")]
                       ["edit config" (.. editor_cmd " " awesome.conffile)]
                       [:restart awesome.restart]
                       [:quit (fn [] (awesome.quit))]])

(global mymainmenu (awful.menu
                     {:items [
                              [:awesome myawesomemenu beautiful.awesome_icon]
                              ["open terminal" terminal]]}))

(global mylauncher (awful.widget.launcher {
                                           :image beautiful.awesome_icon
                                           :menu mymainmenu}))

;; Menubar configuration
(set menubar.utils.terminal terminal) ;; Set the terminal for applications that require it
;;}}}

;; {{{Tag
;; Table of layouts to cover with awful.layout.inc, order matters
(tag.connect_signal
  "request::default_layouts"
  (fn []
    (awful.layout.append_default_layouts
      [awful.layout.suit.tile
       awful.layout.suit.max
       awful.layout.suit.floating])))
;;}}}

;;{{{ Wibar
;; keyboard map indicator and switcher
(global mykeyboardlayout (awful.widget.keyboardlayout))

;; Create a textclock widget
(global mytextclock (wibox.widget.textclock))

(screen.connect_signal
  "request::wallpaper"
  (fn [s]
    ;;wallpaper
    (if beautiful.wallpaper
       (do (var wallpaper beautiful.wallpaper)
           (if (= (type wallpaper) "function")
               (set wallpaper (wallpaper s)))
           (gears.wallpaper.maximized wallpaper s true)))))

(screen.connect_signal
  "request::desktop_decoration"
  (fn [s]
    (awful.tag ["1" "2" "3" "4" "5"] s (. awful.layout.layouts 1))
    ;;create a prompt box for each screen
    (set s.mypromptbox (awful.widget.prompt))

    (set s.mylayoutbox
         (awful.widget.layoutbox
           {
            :screen s
            :buttons [(awful.button [] 1 (fn [] (awful.layout.inc 1)))
                      (awful.button [] 3 (fn [] (awful.layout.inc -1)))
                      (awful.button [] 4 (fn [] (awful.layout.inc -1)))
                      (awful.button [] 5 (fn [] (awful.layout.inc 1)))]}))
    ;; Create a tag list widget
    (set s.mytaglist
         (awful.widget.taglist
           {
            :screen s
            :filter awful.widget.taglist.filter.all
            :buttons [(awful.button [] 1 (fn [t] (t:view_only)))
                      (awful.button [modkey] 1
                                    (fn [t]
                                      (if client.focus
                                        (client.focus:move_to_tag t))))
                      (awful.button [] 3 awful.tag.viewtoggle)
                      (awful.button [modkey] 3
                                      (fn [t]
                                        (if client.focus
                                          (client.focus:toggle_tag t))))
                      (awful.button [] 4
                                      (fn [t]
                                        (awful.tag.viewprev t.screen)))
                      (awful.button [] 5
                                      (fn [t]
                                        (awful.tag.viewnext t.screen)))]}))
    ;; Create a task list widget
    (set s.mytasklist
         (awful.widget.tasklist
           {
            :screen s
            :filter awful.widget.tasklist.filter.currenttags
            :buttons [
                      (awful.button
                        [] 1 (fn [c]
                               (c:activate {:context "tasklist"
                                            :action "toggle_minimization"})))
                      (awful.button [] 3
                                    (fn [] (awful.menu.client_list
                                             {:theme { :width 300}})))
                      (awful.button [] 4
                                    (fn [] (awful.client.focus.byidx 1)))
                      (awful.button [] 5
                                    (fn [] (awful.client.focus.byidx -1)))]}))
    (set s.mywibox (awful.wibar {
                                 :position "top"
                                 :screen s}))
    (set s.mywibox.widget (
                           /<
                           :layout wibox.layout.align.horizontal
                           (/< ; left
                             :layout wibox.layout.fixed.horizontal
                             mylauncher
                             s.mypromptbox
                             s.mytaglist)
                           s.mytasklist ; middle
                           (/< ;right
                            :layout wibox.layout.fixed.horizontal
                            mykeyboardlayout
                            (wibox.widget.systray)
                            mytextclock
                            s.mylayoutbox)))))
;;}}}

;; {{{Key bindings

;; General Awesome keys
(awful.keyboard.append_global_keybindings
  [(awful.key [modkey ] "s" hotkeys_popup.show_help
              {:description "show help"
               :group "awesome"})
   (awful.key [modkey "Mod1"] "r" awesome.restart
              {:description "reload awesome"
               :group "awesome"})
   (awful.key [modkey "Shift"] "esc" awesome.quit
              {:description "quit awesome"
               :group "awesome"})
   (awful.key [modkey] "x"
              (fn [] (awful.prompt.run
                       {
                        :prompt "Run Lua code: "
                        :textbox (. (awful.screen.focused) :mypromptbox :widget)
                        :exe_call_back awful.util.eval
                        :history_path (.. (awful.util.get_cache_dir) "/history_eval")}))
             {:description "lua execute prompt"
              :group "awesome"})
   (awful.key [modkey ] "Return" (fn [] (awful.spawn terminal))
              {:description "open a terminal"
               :group "launcher"})
   (awful.key [modkey ] "r" (fn []
                               (: (. (awful.screen.focused) :mypromptbox) :run))
              {:description "run prompt"
               :group "launcher"})
   (awful.key [modkey] "p" (fn [] (menubar.show)))])

;; Tags related keybindings
(awful.keyboard.append_global_keybindings
  [(awful.key [modkey "Mod1"] "k" awful.tag.viewprev
              {:description "view previous"
               :group "tag"})
   (awful.key [modkey "Mod1"] "j" awful.tag.viewnext
              {:description "view next"
               :group "tag"})
   (awful.key [modkey] "Escape" awful.tag.history.restore
              {:description "go back"
               :group "tag"})])

;; Focus related keybindings
(awful.keyboard.append_global_keybindings
  [(awful.key [modkey ] "j" (fn [] (awful.client.focus.byidx 1))
              {:description "focus next by index"
               :group "client"})
   (awful.key [modkey ] "k" (fn [] (awful.client.focus.byidx -1))
              {:description "focus previous by index"
               :group "client"})
   (awful.key [modkey ] "Tab" (fn [] ((awful.client.focus.history.previous
                                       (if client.focus
                                         (client.focus:raise)))))
              {:description "go back"
               :group "client"})
   (awful.key [modkey "Control" ] "j" (fn [] (awful.screen.focus_relative 1))
              {:description "focus the next screen"
               :group "screen"})
   (awful.key [modkey "Control" ] "k" (fn [] (awful.screen.focus_relative -1))
              {:description "focus the previous"
               :group "screen"})
   (awful.key [modkey "Control" ] "n"
              (fn []
                ((let [c (awful.client.restore)]
                  (if c (c:activate {:raise true
                                     :context "key.unminimize"})))))
              {:description "restore minimized"
               :group "client"})
   (awful.key [modkey] "b"
              (fn []
                ;; get all client
                (f.each (fn [c] (awful.titlebar.toggle c))
                        (client.get))
                (title-toggle-rule))
              {:description "toggle titlebar"
               :group "title"})
   (awful.key [modkey] "t" (fn [] (each [s screen]
                                    (set s.mywibox.visible
                                         (not s.mywibox.visible)))))])

;; Layout related keybindings

(awful.keyboard.append_global_keybindings
  [
   (awful.key [ modkey "Shift" ] "j" (fn [] (awful.client.swap.byidx  1))
              {:description "swap with next client by index"
               :group "client"})
   (awful.key [ modkey "Shift" ] "k" (fn [] (awful.client.swap.byidx -1))
              {:description "swap with previous client by index"
               :group "client"})
   (awful.key [ modkey ] "u" awful.client.urgent.jumpto
              {:description "jump to urgent client"
               :group "client"})
   (awful.key [ modkey ] "l"     (fn [] (awful.tag.incmwfact 0.05))
              {:description "increase master width factor"
               :group "layout"})
   (awful.key [ modkey ] "h"     (fn [] (awful.tag.incmwfact -0.05))
              {:description "decrease master width factor"
               :group "layout"})
   (awful.key [ modkey "Shift" ] "h" (fn [] (awful.tag.incnmaster 1 nil true))
              {:description "increase the number of master clients"
               :group "layout"})
   (awful.key [ modkey "Shift" ] "l" (fn [] (awful.tag.incnmaster -1 nil true))
              {:description "decrease the number of master clients"
               :group "layout"})
   (awful.key [ modkey "Control" ] "h" (fn [] (awful.tag.incncol 1 nil true))
              {:description "increase the number of columns"
               :group "layout"})
   (awful.key [ modkey "Control" ] "l" (fn [] (awful.tag.incncol -1 nil true))
              {:description "decrease the number of columns"
               :group "layout"})
   (awful.key [ modkey ] "space" (fn [] (awful.layout.inc 1))
              {:description "select next"
               :group "layout"})
   (awful.key [ modkey "Shift" ] "space" (fn [] (awful.layout.inc -1))
              {:description "select previous"
               :group "layout"})])


(awful.keyboard.append_global_keybindings
  [
   (awful.key {
               :modifiers    [modkey]
               :keygroup     "numrow"
               :description  "only view tag"
               :group        "tag"
               :on_press     (fn [index]
                              (local screen  (awful.screen.focused))
                              (local tag  (. screen.tags index))
                              (if tag
                                (tag:view_only)))})
   (awful.key {
               :modifiers    ["Mod1"]
               :keygroup     "numrow"
               :description  "toggle tag"
               :group        "tag"
               :on_press     (fn [index]
                              (local screen  (awful.screen.focused))
                              (local tag  (. screen.tags index))
                              (if tag
                                (awful.tag.viewtoggle tag)))})
   (awful.key
     {
      :modifiers  [modkey "Shift"]
      :keygroup     "numrow"
      :description  "move focused client to tag"
      :group        "tag"
      :on_press     (fn [index]
                       (if client.focus
                         (do (local tag  (. client.focus.screen.tags index))
                             (if tag
                               (client.focus:move_to_tag tag)))))})
   (awful.key
     {
      :modifiers  [modkey "Mod1"]
      :keygroup     "numrow"
      :description  "toggle focused client to tag"
      :group        "tag"
      :on_press     (fn [index]
                       (if client.focus
                         (do (local tag  (. client.focus.screen.tags index))
                             (if tag
                               (client.focus:toggle_tag tag)))))})
   (awful.key
     {
      :modifiers    [modkey]
      :keygroup     "numpad"
      :description  "select layout directly"
      :group        "layout"
      :on_press     (fn [index]
                      (local t (. (awful.screen.focused) :selected_tag))
                      (if t
                        (set t.layout
                             (or ( . t.layouts index)
                                 t.layout))))})])
(client.connect_signal
  "request::default_mousebindings"
  (fn []
    (awful.mouse.append_client_mousebindings
      [
       (awful.button [ ] 1
                     (fn [c]
                       (c:activate { :context  "mouse_click"})))
       (awful.button [ modkey ] 1
                     (fn [c]
                       (c:activate { :context  "mouse_click"
                                     :action  "mouse_move"})))
       (awful.button [ modkey ] 3
                     (fn [c]
                       (c:activate { :context  "mouse_click"
                                     :action  "mouse_resize"})))])))

(awful.mouse.append_global_mousebindings
  [ (awful.button [ ] 3 (fn [c] (mymainmenu:toggle)))
    (awful.button [ ] 4 (fn [c] (awful.tag.viewprev)))
    (awful.button [ ] 5 (fn [c] (awful.tag.viewnext)))])


(client.connect_signal
  "request::default_keybindings"
  (fn []
    (awful.keyboard.append_client_keybindings
      [
       (awful.key [ modkey ] "f"
                  (fn [c]
                    (set c.fullscreen  (not c.fullscreen))
                    (c:raise))
                  {:description  "toggle fullscreen"
                   :group  "client"})
       (awful.key [ modkey ] "q"      (fn [c] (c:kill))
                  {:description  "close"
                   :group  "client"})
       (awful.key [ modkey "Control" ] "space"  awful.client.floating.toggle
                  {:description  "toggle floating"
                   :group  "client"})
       (awful.key [ modkey "Control" ] "Return"
                  (fn [c] (c:swap ( awful.client.getmaster)))
                  {:description  "move to master"
                   :group  "client"})
       (awful.key [ modkey ] "o" (fn [c] (c:move_to_screen))
                  {:description  "move to screen"
                   :group  "client"})
       (awful.key [modkey] "w" (fn []
                                 ;;TODO move other screen logic to separte function
                                 (let [focused (awful.screen.focused)]
                                  (if (= focused (. screen 1))
                                      (: (. focused :selected_tag) :swap (. screen 2 :selected_tag))
                                      (: (. focused :selected_tag) :swap (. screen 1 :selected_tag))))))
       (awful.key [ modkey "Shift" ] "t" (fn [c] (set c.ontop  (not c.ontop)))
                  {:description  "toggle keep on top"
                   :group  "client"})
       (awful.key [ modkey ] "n"
                  (fn [c]
                    ;; The client currently has the input focus, so it cannot be
                    ;; minimized, since minimized clients can't have the focus.
                    (set c.minimized  true))
                  {:description  "minimize"
                   :group  "client"})
       (awful.key [ modkey ] "m"
                  (fn [c]
                    (set c.maximized  (not c.maximized))
                    (c:raise))
                  {:description  "(un)maximize"
                   :group  "client"})
       (awful.key [ modkey "Control" ] "m"
                  (fn [c]
                    (set c.maximized_vertical  (not c.maximized_vertical))
                    (c:raise))
                  {:description  "(un)maximize vertically"
                   :group  "client"})
       (awful.key [ modkey "Shift" ] "m"
                   (fn [c]
                     (set c.maximized_horizontal  (not c.maximized_horizontal))
                     (c:raise))
                   {:description  "(un)maximize horizontally"
                    :group  "client"})])))
;;}}}

;; {{{ Rules
;; Rules to apply to new clients.
(ruled.client.connect_signal
  "request::rules"
  (fn []
   ;; All clients will match this rule.
      (ruled.client.append_rule
       {
        :id          "global"
        :rule        {}
        :properties {
                     :focus      awful.client.focus.filter
                     :raise      true
                     :screen     awful.screen.preferred
                     :placement  (+ awful.placement.no_overlap
                                    awful.placement.no_offscreen)}})
      ;; Floating clients.
      (ruled.client.append_rule
        {
          :id        "floating"
          :rule_any  {
                      :instance  [ "copyq" "pinentry"]
                      :class     [
                                  "Arandr" "Blueman-manager"
                                  "Gpick" "Kruler" "Sxiv"
                                  "Tor Browser" "Wpa_gui"
                                  "veromix" "xtightvncviewer"]
                      ;; Note that the name property shown in xprop might be set
                      ;; slightly after creation of the client and the name shown
                      ;; there might not match defined rules here.
                        :name     [ "Event Tester"]  ;; xev.
                        :role     [ "AlarmWindow"    ;; Thunderbird's calendar.
                                    "ConfigManager"  ;; Thunderbird's about:config.
                                    "pop-up"]}       ;; e.g. Google Chrome's
                                                      ;(detached) Developer Tools.
           :properties  { :floating true}})
        ;; Add titlebars to normal clients and dialogs
      (title-toggle-rule)))

  ;;}}}

;; {{{ Titlebars
;; Add a titlebar if titlebars_enabled is set to true in the rules.
(client.connect_signal
  "request::titlebars"
  (fn [c]
    ;; buttons for the titlebar
    (local buttons
      [
        (awful.button { } 1
                       (fn []
                          (c:activate { :context  "titlebar"
                                       :action "mouse_move"})))
        (awful.button {} 3
                       (fn []
                          (c:activate {:context  "titlebar"
                                       :action "mouse_resize"})))])
    (tset (awful.titlebar c ) :widget
          (/<
            ( ;; Left
                /<
                (awful.titlebar.widget.iconwidget c)
                :buttons  buttons
                :layout   wibox.layout.fixed.horizontal)
            ( ;; Middle
                 /<
                { ;; Title
                    :align   "center"
                    :widget  (awful.titlebar.widget.titlewidget c)}
                :buttons  buttons
                :layout   wibox.layout.flex.horizontal)

            ( ;; Right
                /<
                (awful.titlebar.widget.floatingbutton c)
                (awful.titlebar.widget.maximizedbutton c)
                (awful.titlebar.widget.stickybutton   c)
                (awful.titlebar.widget.ontopbutton    c)
                (awful.titlebar.widget.closebutton    c)
                :layout  (wibox.layout.fixed.horizontal))
            :layout  wibox.layout.align.horizontal))))
;; rules for titlebar toggle

;; }}}

; {{{ Notifications
(ruled.notification.connect_signal
  "request::rules"
  (fn []
    ;; All notifications will match this rule.
    (ruled.notification.append_rule
        { :rule        {}
          :properties  {}
          :screen      awful.screen.preferred
          :implicit_timeout  5})))

(naughty.connect_signal
  "request::display"
  (fn [n]
    (naughty.layout.box {:notification n})))

;;}}}

;; Enable sloppy focus so that focus follows mouse.
(client.connect_signal "mouse::enter"
                       (fn [c]
                        (c:activate
                          { :context "mouse_enter"
                            :raise false})))

;;; vim:set fdm=marker:

