-- awesome_mode: api-level=6:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
--fennel
local fennel = require("fennel")
fennel.path = fennel.path .. ";.config/awesome/?.fnl"
fennel.makeSearcher({
  correlate = true,
  useMetadata = true
})
table.insert(package.loaders or package.searchers, fennel.searcher)
require("rcf")
