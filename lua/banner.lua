-- @responsible SHA
-- Simple Lua code snippet for a GUI Element. The banner is used to hold a group of Market Depth GUIs.
-- Moreover, there is a functionality to show and hide all assigned Market Depths.

local e		= require 'easygui'
local futas	= require 'futas'

local assert	= assert
local pairs	= pairs
local setmetatable	= setmetatable
local type	= type

local M = {}
local Banner = {}

STRICT = true

local BITMAP_EXPAND = futas.loadBitmap 'sml/arrow_down_blue.png'
local BITMAP_SHRINK = futas.loadBitmap 'sml/arrow_up_blue.png'
local BANNER_BACK = futas.Colour '#0670C2'
local BANNER_FRONT = futas.Colour '#FFFFFF'
local BANNER_BORDER = futas.Colour '#03406F'

local function expandShrink(self, expand, bitmap, tooltip)
  if self.expanded~=expand then
    for name, md in pairs(self.md) do
      md:setVisible(expand)
    end
    self.ctrls.toggle:setBitmap(bitmap)
    self.ctrls.toggle:setTooltip(tooltip)
    self.expanded = expand
  end
end

function Banner:expand()
  expandShrink(self, true, BITMAP_SHRINK, 'Hide orderbook')
end

function Banner:shrink()
  expandShrink(self, false, BITMAP_EXPAND, 'Show orderbook')
end

function Banner:toggle()
  if self.expanded then
    self:shrink()
  else
    self:expand()
  end
end

function Banner:addMarketDepth(marketDepth)
  assert(type(marketDepth) == 'enerchain::MarketDepth',
	 "'enerchain::MarketDepth' expected, got: "..type(marketDepth))
  self.md[marketDepth.name] = marketDepth
end

function Banner:getCtrl()
  return self.ctrl
end

local bannerMeta = { __index=Banner, __type='enerchain::Banner'}
function M.Banner(x)
  assert(type(x)=='table', "arguments missing")
  assert(type(x.name)=='string', "'name' missing")
  x.expanded = true
  x.md = {}
  x.ctrls = {}
  local self = setmetatable(x, bannerMeta)

  local toggle = function() self:toggle() end

  self.ctrl = e.Form
  {
    background=BANNER_BORDER,
    orient=e.EXPAND_GROW,
    e.Page
    {
      name='top', top=e.FORM
    },
    e.Page
    {
      top='top', bottom='bottom',
      background=BANNER_BACK,
      e.ToolbarButton
      {
	name='toggle', store=self.ctrls,
	bitmap=BITMAP_SHRINK,
	background=BANNER_BACK,
	tooltip='Hide orderbook',
	onAction=toggle
      },
      e.StaticValue
      {
	x.name,
	fontBold=true,
	foreground=BANNER_FRONT,
	background=BANNER_BACK,
	orient=e.XEXPAND_GROW, righttab='$',
	onAction=toggle
      }
    },
    e.Page
    {
      name='bottom', bottom=e.FORM
    },
  }.ctrl_

  return self
end

return M
