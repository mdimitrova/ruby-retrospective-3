module Graphics
  require 'set'

  class Canvas
    attr_reader :width, :height, :pixels

    def initialize(width, height)
      @width  = width
      @height = height
      @pixels = Array.new(height) { Array.new(width, 0) }
    end

    def set_pixel(x, y)
      @pixels[y][x] = 1 if (x < width and y < height)
    end

    def pixel_at?(x, y)
      @pixels[y][x] == 1
    end

    def draw(shape)
      shape.draw_pixels(self)
    end

    def render_as(renderer)
      renderer.render @pixels, @width, @height
    end
  end

  module Renderers
    class Ascii
      def self.render canvas, width, height
        rendered = ''
        0.upto(height - 1) do |j|
          rendered << canvas[j].join.to_s + "\n"
        end
        rendered.gsub!(/[01]/, '0' => '-', '1' => '@')
        rendered.chomp
      end
    end

    class Html

      HEADER = '<!DOCTYPE html><html><head><title>Rendered Canvas</title><style type=
                     "text/css">.canvas {font-size: 1px;line-height: 1px;}.canvas *
                     {display: inline-block;width: 10px; height: 10px; border-radius:
                     5px;}.canvas i {background-color: #eee;}.canvas b {background-color:
                      #333;} </style> </head> <body><div class="canvas">'.freeze
      FOOTER = '</div></body></html>'.freeze

      EMPTY = '<i></i>'.freeze
      FILLED = '<b></b>'.freeze
      NEW_LINE = '<br>'.freeze

      def self.render canvas, width, height
        rendered = []
        0.upto(height - 1) do |j|
          rendered << canvas[j].join.to_s.gsub!(/[01]/, '0' => EMPTY, '1' => FILLED)
        end
        HEADER + rendered.join(NEW_LINE) + FOOTER
      end
    end
  end

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def ==(other)
      x == other.x and y == other.y
    end

    alias eql? ==

    def hash
      [x, y].hash
    end

    def draw_pixels(canvas)
      canvas.set_pixel(x, y)
    end
  end

  class Line
    attr_reader :from, :to

    def initialize(from, to)
      if from.x > to.x or (from.x == to.x and from.y > to.y)
        @from = to
        @to   = from
      else
        @from = from
        @to   = to
      end
    end

    def ==(other)
      from == other.from and to == other.to
    end

    alias eql? ==

    def hash
      [from.hash, to.hash].hash
    end

    def draw_pixels(canvas) #FIXME
      bresenham_pixels.each { |x, y| canvas.set_pixel(x, y) }
    end

    private

    def bresenham_pixels
      delta_x, delta_y = to.x - from.x, to.y - from.y
      slope = delta_y / delta_x.to_f if delta_x != 0
      if slope
        rasterize([delta_x, delta_y].max, slope).map { |x, y| [from.x + x, from.y + y] }
      else
        from.y.upto(to.y).map { |y| [from.x, y] }
      end
    end

    def rasterize(length, slope)
      if slope > 1
        0.upto(length).map { |i| [(i/slope).round, i] }
      else
        0.upto(length).map { |i| [i, (i*slope).round] }
      end
    end
  end

  class Rectangle
    attr_reader :left, :right

    def initialize(left, right)
      if left.x > right.x or (left.x == right.x and left.y > right.y)
        @left = right
        @right = left
      else
        @left = left
        @right = right
      end
    end

    def top_left
      Point.new left.x, [left.y, right.y].min
    end

    def top_right
      Point.new right.x, [left.y, right.y].min
    end

    def bottom_left
      Point.new left.x, [left.y, right.y].max
    end

    def bottom_right
      Point.new right.x, [left.y, right.y].max
    end

    def ==(other)
      top_left == other.top_left and bottom_right == other.bottom_right
    end

    alias eql? ==

    def hash
      [top_left, bottom_right].hash
    end

    def draw_pixels(canvas) #FIXME
      canvas.draw Line.new(top_left, top_right)
      canvas.draw Line.new(top_left, bottom_left)
      canvas.draw Line.new(bottom_left, bottom_right)
      canvas.draw Line.new(top_right, bottom_right)
    end
  end
end

__END__
module Graphics
  canv = Canvas.new 7, 4
  #puts " width: #{canv.width}"
  #canv.set_pixel(1, 0)
  #canv.draw(Line.new(Point.new(4, 0), Point.new(5, 3)))
  canv.draw Rectangle.new(Point.new(3, 1), Point.new(5,3))
  p canv.pixels
end
