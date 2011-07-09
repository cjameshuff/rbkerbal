#!/usr/bin/env ruby

load('lib/rbkerbal.rb')

ship = Ship.new("testShip")
ship.main_pod.link_chute(ParachuteSingle.new(ship))
dc1 = ship.main_pod.link(StackDecoupler.new(ship))
ft1 = dc1.link(FuelTank.new(ship))
le1 = ft1.link(LiquidEngine.new(ship))

ship.write("testout.craft")
