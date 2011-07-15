#!/usr/bin/env ruby

require 'pp'
require 'pathname'
require 'fileutils'

def obj_yrotate(srcobjfile, dstobjfile, amt)
    sinang = Math.sin(amt*Math::PI/180.0)
    cosang = Math.cos(amt*Math::PI/180.0)
    
    fin = File.open(srcobjfile, 'r')
    fout = File.open(dstobjfile, 'w')
    fin.each_line {|line|
        if(line.start_with?('v '))
            v = line.split(' ')[1, 3].map{|x| x.to_f}
            fout.puts "v #{v[0]*cosang + v[2]*sinang} #{v[1]} #{-v[0]*sinang + v[2]*cosang}"
        elsif(line.start_with?('vn '))
            v = line.split(' ')[1, 3].map{|x| x.to_f}
            fout.puts "vn #{v[0]*cosang + v[2]*sinang} #{v[1]} #{-v[0]*sinang + v[2]*cosang}"
        else
            fout.puts line
        end
    }
    fin.close
    fout.close
end


def load_cfg(part_cfg)
    cfg = {}
    cfg_file = File.open(part_cfg)
    cfg_file.each_line {|line|
        line.strip!
        if(line.length > 0 && !line.start_with?('//'))
            var, val = line.split('=', 2)
            cfg[var.strip.to_sym] = val.strip
        end
    }
    cfg_file.close
    cfg
end

def cfg_set(cfgfile, changes)
    lines = IO.readlines(cfgfile)
    fout = File.open(cfgfile, 'w')
    lines.each {|line|
        var, val = line.split('=', 2).map{|x| x.strip}
        if(changes.has_key?(var.to_sym))
            fout.puts "#{var} = #{changes[var.to_sym]}"
        else
            fout.puts line
        end
    }
    fout.close
end

def part_yrotate(srcdir, rot)
    partdirbase = Pathname.new(srcdir).basename
    dstdir = "generated/#{partdirbase}%03d" % [rot]
    
    FileUtils.mkdir_p('generated')
    FileUtils.rm_f(dstdir)
    FileUtils.cp_r(srcdir, dstdir)
    
    cfgfile = dstdir + '/part.cfg'
    cfg = load_cfg(cfgfile)
    # pp cfg
    
    # Nodes are rotated around the node_stack_top position, which must exist for the
    # part to be rotated.
    orig = cfg[:node_stack_top].split(',').map{|x| x.to_f}
    
    changes = {}
    sinang = Math.sin(rot*Math::PI/180.0)
    cosang = Math.cos(rot*Math::PI/180.0)
    cfg.keys.find_all{|x| x.to_s.start_with?('node_')}.each{|key|
        vorig = cfg[key].split(',').map{|x| x.to_f}
        v = vorig[0, 3].map.with_index{|x, i| x - orig[i]}
        v = [v[0]*cosang + v[2]*sinang, v[1], -v[0]*sinang + v[2]*cosang]
        v = v.map.with_index{|x, i| x + orig[i]}
        changes[key] = "%8f, %8f, %8f, #{vorig[3,4].join(', ')}" % v
    }
    cfg_set(cfgfile, changes)
    
    # File.extname("#{srcdir}/#{cfg[:mesh]}")
    # negate rotation here, different coordinate systems
    obj_yrotate("#{srcdir}/#{cfg[:mesh]}", "#{dstdir}/#{cfg[:mesh]}", -rot)
    
    cfg_set(dstdir + '/part.cfg', {
        name: "#{cfg[:name]}#{rot}",
        title: "#{cfg[:title]} #{rot}deg"
    })
end


partname = ARGV.shift
ARGV.each {|rot| part_yrotate(partname, rot.to_i)}

