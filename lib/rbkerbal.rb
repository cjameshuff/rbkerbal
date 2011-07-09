#!/usr/bin/env ruby

class ShipPart
    attr_accessor :pos, :rot, :stg, :istg, :name, :sqor
    
    @@cfgs = {}
    def initialize(part_cfg, ship)
        if(!@@cfgs[part_cfg.to_sym])
            cfg_file = File.open("KSP/Parts/#{part_cfg}/part.cfg")
            cfg = {}
            cfg_file.each_line {|line|
                line.strip!
                if(line.length > 0 && !line.start_with?('//'))
                    var, val = line.split('=', 2)
                    cfg[var.strip.to_sym] = val.strip
                end
            }
            cfg_file.close
            @@cfgs[part_cfg.to_sym] = cfg
        end
        @cfg = @@cfgs[part_cfg.to_sym]
        
        if(@cfg[:attachRules])
            @attach_rules = {}
            rules = @cfg[:attachRules].split(',').map{|x| x.strip.to_i}
            @attach_rules[:stack] = (rules[0] != 0)
            @attach_rules[:srfAttach] = (rules[1] != 0)
            @attach_rules[:allowStack] = (rules[2] != 0)
            @attach_rules[:allowSrfAttach] = (rules[3] != 0)
            @attach_rules[:allowCollision] = (rules[4] != 0)
        end
        
        @name = ship.get_part_id(@cfg[:name].to_sym)
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
        fout.puts (@sqor)? "\tsqor = True" : "\tsqor = False"
        @links.each{|links| fout.puts "\tlink = #{links.name}"}
        fout.puts "}"
        @links.each{|link| link.write(fout)}
    end
end # class ShipPart


# Lots of modules just mount a single item underneath
class SimplePart < ShipPart
    def initialize(part_cfg, ship)
        super(part_cfg, ship)
        node_stack_top = @cfg[:node_stack_top].split(',').map{|x| x.strip.to_f}
        node_stack_bottom = @cfg[:node_stack_bottom].split(',').map{|x| x.strip.to_f}
        puts "#{name} node_stack_top: #{node_stack_top}"
        puts "#{name} node_stack_bottom: #{node_stack_bottom}"
        @height = node_stack_top[1] - node_stack_bottom[1]
        puts "#{name} height: #{@height}"
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
        super("mk1pod", ship)
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
        super("parachute_single", ship)
    end
end # class ParachuteSingle


class StackDecoupler < SimplePart
    def initialize(ship)
        super("stackDecoupler", ship)
    end
end # class StackDecoupler


class RadialDecoupler < ShipPart
    def initialize(ship)
        super("radialDecoupler", ship)
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
        super("fuelTank", ship)
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
        super("solidBooster", ship)
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
        super("sasModule", ship)
        @radials = []
    end
end # class SAS_Module


class LiquidEngine < SimplePart
    def initialize(ship)
        super("liquidEngine1", ship)
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
        fout.puts "// Do not edit this file by hand. There are no cheating opportunities here. Go away."
        fout.close
    end
end # class Ship
