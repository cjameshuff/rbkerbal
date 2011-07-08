#!/usr/bin/env ruby

class ShipPart
    attr_accessor :pos, :rot, :stg, :istg, :name, :sqor
    def initialize(name)
        @name = name
        @pos = [0, 0, 0]
        @rot = [0, 0, 0, 1]
        @stg = 8
        @istg = 0
        @sqor = false
        @links = []
    end
    
    def pos=(pos)
        @pos = pos
    end
    
    def write(fout)
        fout.puts "{"
        fout.puts "\tpart = #{@name}"
        fout.puts "\tpos = #{@pos}"
        fout.puts "\trot = #{@rot}"
        fout.puts "\tstg = #{@stg}"
        fout.puts "\tistg = #{@istg}"
        if(@sqor)
            fout.puts "\tsqor = False"
        else
            fout.puts "\tsqor = True"
        end
        @links.each{|links| fout.puts "\tlink = #{links.name}"}
        fout.puts "}"
        @links.each{|link| link.write(fout)}
    end
end # class ShipPart


# Lots of modules just mount a single item underneath
class SimplePart < ShipPart
    def initialize(name, height)
        super(name)
        @height = height
    end
    
    # Stack decouplers mount a single module underneath
    def link(mod)
        @mod = mod
        @links.push(mod)
        mod
    end
    
    def pos=(pos)
        super(pos)
        if(@mod)
            @mod.pos = [pos[0], pos[1] - @height, pos[2]]
        end
    end
end # class SimplePart


class Pod_Mk1 < ShipPart
    def initialize(ship)
        super(ship.get_part_id(:mk1pod))
    end
    
    def link_chute(chute)
        @chute = chute
        @links.push(chute)
        chute
    end
    
    def link(mod)
        @mod = mod
        @links.push(mod)
        mod
    end
    
    def pos=(pos)
        super(pos)
        # Parachute location is pod location + y*0.405
        # Module location is pod location - 0.385
        if(@chute)
            @chute.pos = [pos[0], pos[1] + 0.405, pos[2]]
        end
        if(@mod)
            @mod.pos = [pos[0], pos[1] - 0.385, pos[2]]
        end
    end
end # class Pod_Mk1


class ParachuteSingle < ShipPart
    def initialize(ship)
        super(ship.get_part_id(:parachuteSingle))
    end
end # class ParachuteSingle


class StackDecoupler < SimplePart
    def initialize(ship)
        super(ship.get_part_id(:stackDecoupler), 1.066)
    end
end # class StackDecoupler


class RadialDecoupler < ShipPart
    def initialize(ship)
        super(ship.get_part_id(:radialDecoupler))
    end
    
    # Radial decouplers mount a single module on the side (always a solid booster?)
    def link_booster(booster)
        @booster = booster
        @links.push(booster)
        booster
    end
    
    def pos=(pos)
        super(pos)
        # TODO: calculate booster position
        if(@booster)
            @booster.pos = [pos[0], pos[1] - 1.066, pos[2]]
        end
    end
end # class RadialDecoupler

# TODO: tricoupler


class FuelTank < SimplePart
    def initialize(ship)
        super(ship.get_part_id(:fuelTank), 1.4645)
        @radials = []
    end
    
    # Fuel tanks mount a single module underneath, and also
    # mount radial mounting decouplers and fins
    def link_radial(radial)
        @radials.push(radial)
        @links.push(radial)
        radial
    end
    
    def pos=(pos)
        super(pos)
        # TODO: compute positions of radial mounted parts
    end
end # class FuelTank

class SolidBooster < SimplePart
    def initialize(ship)
        # TODO: fix booster height!
        super(ship.get_part_id(:solidBooster), 1.4645)
        @radials = []
    end
    
    # Solid boosters tanks can mount a single module underneath, and also
    # mount radial mounting decouplers, fins, and other boosters
    def link_radial(radial)
        @radials.push(radial)
        @links.push(radial)
        radial
    end
    
    def pos=(pos)
        super(pos)
        # TODO: compute positions of radial mounted parts
    end
end # class FuelTank


class SAS_Module < SimplePart
    def initialize(ship)
        super(ship.get_part_id(:sasModule), 1.057)
        @radials = []
    end
end # class SAS_Module


class LiquidEngine < SimplePart
    def initialize(ship)
        super(ship.get_part_id(:liquidEngine), 0.81)
        @radials = []
    end
end # class SAS_Module


class Ship
    attr_accessor :part_ctrs, :main_pod
    
    def initialize(ship_name)
        @ship_name = ship_name
        @part_ctrs = {}
        @main_pod = Pod_Mk1.new(self)
    end
    
    def get_part_id(part_sym)
        if(@part_ctrs[part_sym] == nil)
            @part_ctrs[part_sym] = 0
        end
        @part_ctrs[part_sym] += 1
        return "#{part_sym.to_s}_#{@part_ctrs[part_sym] - 1}"
    end
    
    def write(file_name)
        @main_pod.pos = [0, 0, 0]
        
        fout = File.open(file_name, 'w')
        fout.puts "ship == #{@ship_name}"
        @main_pod.write(fout)
        
        fout.close
    end
end # class Ship
