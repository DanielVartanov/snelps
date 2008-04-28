require 'yaml'
require 'narray'
require 'publisher'
# represents a game map
# original map idea is to load/save as yaml
class Map
  extend Publisher

  can_fire :victory, :failure
  
  # check every 2 seconds
  CHECK_CONDITIONS_POLL_TIME = 2000

  def to_yaml_properties()
    ['@width', '@height', '@tile_size', '@converted_tiles', '@half_tile_size']
  end

  attr_accessor :tile_size, :height, :width, :tile_images, :tiles,
    :converted_tiles, :viewport, :resource_manager, :half_tile_size,
    :background_image, :check_conditions, :last_check

  alias :w :width
  alias :h :height
  def setup(args = {})
    @last_check = 0
    @resource_manager = args[:resource_manager]
    @width = args[:width].nil? ? 6 : args[:width]
    @height = args[:height].nil? ? 6 : args[:height]

    # nubmer of pixels of each tile
    @tile_size = args[:tile_size].nil? ? 32 : args[:tile_size]
    @tiles = args[:tiles].nil? ? NArray.object(@width, @height) : args[:tiles]
    @half_tile_size = (@tile_size / 2.0).floor
    load_images
  end

  def load_images()
    @tile_images = NArray.object @width, @height
    @width.times do |i|
      @height.times do |j|
        @tile_images[i,j] = 
          @resource_manager.load_image "terrain#{@tiles[i,j]}.png"
      end
    end
  end

  def pixel_height()
    @height * @tile_size
  end

  def pixel_width()
    @width * @tile_size
  end

  def self.load_from_file(resource_manager, map_name)
    map = resource_manager.load_map(map_name)
    map.resource_manager = resource_manager
    map.last_check = 0
    map.tiles = NArray.object(map.width, map.height)
    map.converted_tiles.each_with_index do |row,i|
      row.each_with_index do |col,j|
        map.tiles[i,j] = col
      end
    end
    map.load_images
    map
  end

  def save(file_name)
    @converted_tiles = @tiles.to_a
    @resource_manager.save_map self, file_name
  end

  def at(x,y)
    @tiles[x,y]
  end

  def set(x,y,val)
    @tiles[x,y] = val
  end

  # returns the tile x,y that the coord point falls in
  def coords_to_tiles(x, y)
    if tiles[1] > @height - 1 or tiles[0] > @width - 1
      p "WTF: #{},#{}  => #{tiles[0]},#{tiles[1]}"
    end
    tiles = [(x / @tile_size).ceil, (y / @tile_size).ceil]
    tiles[0] = 0 if tiles[0] < 0
    tiles[0] = @width - 1 if tiles[0] > @width - 1
    tiles[1] = 0 if tiles[1] < 0
    tiles[1] = @height - 1 if tiles[1] > @height - 1
    tiles
  end

  # returns and array of [x,y] to the center of the tile
  def tiles_to_coords(tile_x, tile_y)
    [tile_x * @tile_size + @half_tile_size,
      tile_y * @tile_size + @half_tile_size]
  end

  def recreate_map_image()
    @background_image = Surface.new [pixel_width,pixel_height]
    @width.times do |i|
      @height.times do |j|
        x = i * @tile_size
        y = j * @tile_size
        @tile_images[i,j].blit @background_image, @viewport.world_to_view(x,y)
      end
    end
  end

  def update(time)
    @last_check += time
    if @last_check > CHECK_CONDITIONS_POLL_TIME
      @last_check = 0
      state = @check_conditions.call("TODO:GAME OBJECT HERE")
      case state
      when :victory
        fire :victory
      when :failure
        fire :failure
      end
    end
  end

  def draw(destination)
    recreate_map_image if @background_image.nil?
    @background_image.blit destination, @viewport.world_to_view(0,0)
  end
end

