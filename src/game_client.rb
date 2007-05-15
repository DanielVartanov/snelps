require 'map'
require 'game_server_proxy'
class GameClient
  def initialize(resource_manager, sound_manager, input_manager, viewport)
    @resource_manager = resource_manager
    @sound_manager = sound_manager
    @input_manager = input_manager
    # TODO should viewport just completely replace screen?
    @viewport = viewport
    @screen = @viewport.screen

    @game_server = GameServerProxy.new
    
    #########################
    ## SETUP THE GAME HERE ##
    #########################
    # TODO start up gui?
#    @map = Map.load_from_file "random_map.yml"
    num_rows = 40
    num_cols = 40
    tiles = NArray.int(num_rows,num_cols)
    num_rows.times do |i|
      num_cols.times do |j|
        tiles[i,j] = rand 271
      end
    end
  
    @map = Map.new 
    @map.setup :tiles => tiles, :width => num_rows, :height => num_cols, :resource_manager => @resource_manager
    @viewport.set_map_size(@map.pixel_width, @map.pixel_height)
    @map.viewport = @viewport

    @background = Surface.new(@screen.size)
  end

  def update(time)
    @viewport.update time
    @background.blit @screen,[0,0]
    @map.draw @screen
    @screen.update
  end

  def mouse_motion(event)
    @viewport.scroll event
  end
end
