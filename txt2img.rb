#!/usr/bin/env ruby

require "optparse"
# gm convert -size 400x400 xc:white -fill none -strokewidth 10 -stroke red -draw "rectangle 0,0 398,398" -font /usr/local/share/fonts/TradeMark\ Demo.otf -stroke black -pointsize 48 -draw "text 20,200 'hello'" output.png

class Txt2Img
    # COLORS = ["black", "red", "blue", "green", "cyan", "magenta", "yellow"]
    COLORS = ["\"#FFBBDD\"","\"#DDEEAA\"","\"#AADDDD\"","\"#AABBEE\"","\"#EEEEEE\"","\"#99DDFF\"","\"#FFCC77\"","\"#CCAACC\"","\"#FFEE55\"","\"#EEFFDD\"","\"#AABBEE\"",]
    FONTS = [
        "Greenlight-Script",
        "HackGenConsoleNF-Regular",
        "KosugiMaru-Regular",
        "TradeMark-Demo",
        "UDEVGothicNF-Regular"
    ]

    def initialize
        @opts = {}
        @cmd = ["gm convert"]
    end

    def opt_parse
        OptionParser.new do |op|
            op.on('-s', '--size N') {|v|
                if(v =~ /\d+x\d+/)
                    w, h = v.split("x").map(&:to_i)
                    @opts[:size] = [w, h]
                else
                    @opts[:size] = [v, v].map(&:to_i)
                end
            }
            op.on('-b', '--border N', Integer) {|v|
                n = v.to_i
                @opts[:strokewidth] = n
            }
            op.on('-f', '--font FONT') {|v|
                font = FONTS.find{ |x| x.downcase.include?(v.downcase) }
                @opts[:font] = font
            }
            op.on('-p', '--point N', Integer) {|v|
                @opts[:pointsize] = v
            }
            op.on('--bordercolor COLOR') {|v|
                @opts[:bordercolor] = v
            }
            op.on('--fgcolor COLOR') {|v|
                @opts[:fgcolor] = v
            }

            op.parse!(ARGV)
        end

        default_opts
        @outfile = ARGV[0]
        @text = ARGV[1]
        self
    end

    def default_opts
        @opts[:size] ||= [400, 400]
        @opts[:strokewidth] ||= 20
        @opts[:bordercolor] ||= COLORS.sample
        @opts[:font] ||= "\"KosugiMaru-Regular\""
        @opts[:pointsize] ||= 24
        @opts[:fgcolor] ||= "\"#444444\""
        self
    end

    def build
        @cmd << "-size #{@opts[:size].join("x")}" if @opts[:size]
        @cmd << "xc:white"
        @cmd << "-fill none"
        @cmd << "-strokewidth #{@opts[:strokewidth]}" if @opts[:strokewidth]
        @cmd << "-stroke #{@opts[:bordercolor]}" if @opts[:bordercolor]
        if(@opts[:strokewidth] && @opts[:size])
            st = (@opts[:strokewidth] / 2).to_i
            enx = (@opts[:size][0] - st - 1)
            eny = (@opts[:size][1] - st - 1)
            @cmd << "-draw \"rectangle #{st},#{st} #{enx},#{eny}\""
        end
        @cmd << "-font #{@opts[:font]}" if @opts[:font]
        @cmd << "-fill #{@opts[:fgcolor]}" if @opts[:fgcolor]
        @cmd << "-stroke #{@opts[:fgcolor]}"
        @cmd << "-strokewidth 2"
        @cmd << "-pointsize #{@opts[:pointsize]}" if @opts[:pointsize]
        @cmd << "-density 200"
        @cmd << "-gravity center"
        @cmd << "-draw \"text 0,0 '#{@text}'\""
        @cmd << @outfile
        self
    end

    def to_txt
        @cmd.join(" ")
    end

    def get_txt_rect
        rect_cmd = ["gm convert"]
        rect_cmd << "-fill none"
        rect_cmd << "-background white"
        rect_cmd << "-size 1000x1000"
        rect_cmd << "-font #{@opts[:font]}" if @opts[:font]
        rect_cmd << "-fill #{@opts[:fgcolor]}" if @opts[:fgcolor]
        rect_cmd << "-stroke #{@opts[:fgcolor]}"
        rect_cmd << "-strokewidth 1"
        rect_cmd << "-pointsize #{@opts[:pointsize]}" if @opts[:pointsize]
        rect_cmd << "-density 100"
        rect_cmd << "-draw \"text 1,100 '#{@text}'\""
#        rect_cmd << "-gravity center"
        rect_cmd << "xc:white"
        rect_cmd << "-trim"
        rect_cmd << "info:-"

        cmd = rect_cmd.join(" ")
        result = `#{cmd}`
        result.gsub(/.*=>/, "").split("+").first.split("x").map(&:to_i)
    end
end

txt = Txt2Img.new
    .opt_parse
    .build
    .to_txt

puts txt
system txt

# Txt2Img.new.opt_parse.get_txt_rect

