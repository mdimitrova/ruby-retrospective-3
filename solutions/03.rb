module Graphics
  require 'set'
  class Canvas
    def initialize(width = 1, height = 1)
      @height = height
      @width = width
      @canvas = initialize_canvas @width, @height
    end

    def initialize_canvas(width, height)
      canvas = {}
      0.upto(height - 1) do |i|
        canvas[i] = Array.new(width, 0)
      end
      canvas
    end

    def width
      @width
    end

    def height
      @height
    end

    def get_canvas
      @canvas
    end

    def set_pixel(x, y)
      @canvas[y][x] = 1
    end

    def pixel_at?(x, y)
      @canvas[y][x] == 1
    end

    def draw(figure)
      if figure.is_a? Point
        set_pixel(figure.x, figure.y)
      else
        (figure.pixels_to_draw).each { |point| set_pixel(point[0], point[1]) }
      end
    end

    def render_as(renderer)
      renderer.render @canvas, @width, @height
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
      def self.render canvas, width, height
        rendered = ' <!DOCTYPE html><html><head><title>Rendered Canvas</title><style type=
                     "text/css">.canvas {font-size: 1px;line-height: 1px;}.canvas *
                     {display: inline-block;width: 10px; height: 10px; border-radius:
                     5px;}.canvas i {background-color: #eee;}.canvas b {background-color:
                      #333;} </style> </head> <body><div class="canvas">'
        0.upto(height - 1) do |j|
          rendered << canvas[j].join.to_s
          rendered << '<br>' if j < height - 1
        end
        rendered.gsub!(/[01]/, '0' => '<i></i>', '1' => '<b></b>')
        rendered << '</div></body></html>'
      end
    end
  end

  class Point
    def initialize(x, y)
      @x = x
      @y = y
    end

    def x
      @x
    end

    def y
      @y
    end

    def ==(other)
      @x == other.x and @y == other.y
    end

    def eql?(other)
      @x.eql? other.x and @y.eql? other.y
    end
  end

  class Line
    def initialize(from, to)
      @from = from
      @to = to
    end

    def from
      @from.y > @to.y ? @from : @to
    end

    def to
      @from.y > @to.y ? @to : @from
    end

    def ==(other)
      points = Set.new([[from.x, from.y], [to.x, to.y]])
      points_other = Set.new([[other.from.x, other.from.y],[other.to.x, other.to.y]])
      points == points_other
    end

    def eql?(other)
      points = Set.new([[from.x, from.y], [to.x, to.y]])
      points_other = Set.new([[other.from.x, other.from.y],[other.to.x, other.to.y]])
      points.eql? points_other
    end

    def pixels_to_draw
      pixels = []
      if from.y == to.y
        (from.x).downto(to.x) { |x| pixels << [x, from.y] }
      elsif from.x == to.x
        (from.y).downto(to.y) { |y| pixels << [from.x, y] }
      end
      pixels
    end
  end

  class Rectangle
    def initialize(left, right)
      @left = left
      @right = right
    end

    def left
      @left.x < @right.x ? @left : @right
    end

    def right
      @left.x < @right.x ? @right : @left
    end

    def top_left
      if left.y < right.y
        left
      else
        top_left = Point.new(left.x, right.y)
      end
    end

    def top_right
      top_right = Point.new(right.x, left.y)
    end

    def bottom_left
      bottom_left = Point.new(left.x, right.y)
    end

    def bottom_right
      if left.x < right.x
        right
      else
        bottom_right = Point.new(right.x, left.y)
      end
    end

    def pixels_to_draw
      pixels = []
      pixels.concat Line.new(top_left, top_right).pixels_to_draw
      pixels.concat Line.new(top_left, bottom_left).pixels_to_draw
      pixels.concat Line.new(bottom_left, bottom_right).pixels_to_draw
      pixels.concat Line.new(top_right, bottom_right).pixels_to_draw
      pixels
    end
  end
end
