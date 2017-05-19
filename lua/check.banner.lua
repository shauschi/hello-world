#!/bin/bash -e
A=--[[ L=$0;while :;do E=${L%/*}/lua;[ -f $E ]&&break #-*-mode:lua-*-
if [ -h $L ];then L=`ls -l $L` L=${L#*> };else E=fslua;break;fi;done;exec "$E" "$0" "$@" #]]A

-- @responsible SHA
local guicheck	= require 'guicheck'
local marketdepth	= require 'marketdepth'
local verify	= require 'verify'

local string	= string

framework = guicheck.makeUniverse():makeFramework()

-- Testee
local banner	= require 'banner'

local function test(msg)
  print("test case: '"..msg.."'")
end

local function fail(error, func, ...)
  local ok, msg = pcall(func, ...)
  verify.EQUAL(ok, false, "no error")
  verify.VERIFY(string.find(msg, error), "expected: "..error.." but was: "..msg)
end

test "arguments missing"
do
  fail(
    "arguments missing",
    banner.Banner
  )
end

test "name missing"
do
  fail(
    "'name' missing",
    banner.Banner, {}
  )
end

local function testee()
  return banner.Banner{ name="Testee" }
end

test "Add invalid GUI"
do
  local testee = testee()
  fail(
    "enerchain::MarketDepth",
    testee.addMarketDepth, {}
  )
end

local config = {}
local eventHandler = { addCallback=function() end }
local controller = { getMarketDepth=function() return { bid={}, ask={} }  end }
local function md(name)
  return marketdepth.MarketDepth{
    name=name,
    config=config,
    eventHandler=eventHandler,
    controller=controller
  }
end

test "Toggle all Market Depths (toggle, shrink, expand)"
do
  local testee = testee()
  local md1 = md "MD1"
  local md2 = md "MD2"
  local md3 = md "MD3"
  testee:addMarketDepth( md1 )
  testee:addMarketDepth( md2 )
  testee:addMarketDepth( md3 )

  -- all visible
  verify.EQUAL(md1:getCtrl():isVisible(), true)
  verify.EQUAL(md2:getCtrl():isVisible(), true)
  verify.EQUAL(md3:getCtrl():isVisible(), true)

  testee:toggle()
  verify.EQUAL(md1:getCtrl():isVisible(), false)
  verify.EQUAL(md2:getCtrl():isVisible(), false)
  verify.EQUAL(md3:getCtrl():isVisible(), false)

  testee:toggle()
  verify.EQUAL(md1:getCtrl():isVisible(), true)
  verify.EQUAL(md2:getCtrl():isVisible(), true)
  verify.EQUAL(md3:getCtrl():isVisible(), true)

  testee:shrink()
  verify.EQUAL(md1:getCtrl():isVisible(), false)
  verify.EQUAL(md2:getCtrl():isVisible(), false)
  verify.EQUAL(md3:getCtrl():isVisible(), false)

  testee:expand()
  verify.EQUAL(md1:getCtrl():isVisible(), true)
  verify.EQUAL(md2:getCtrl():isVisible(), true)
  verify.EQUAL(md3:getCtrl():isVisible(), true)
end
