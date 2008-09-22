require 'narray'
require 'colors'
include Colors

# blocks the players view from things they haven't discovered
# TODO change this to modify some kind of masking image instead of maintaining this; said mask could also be used for the minimap
class Fog
  def initialize(map,entity_manager,viewport,resource_manager)
    @entity_manager = entity_manager
    @viewport = viewport
    @resource_manager = resource_manager
    @map = map
    @tile_size = @map.tile_size
    @fog_stamp = @resource_manager.load_image 'fog_stamp.png'

    @mask_image = Surface.new([@map.pixel_width,@map.pixel_height])
    @mask_image.fill BLACK
    @mask_image.set_colorkey WHITE

    @entity_manager.when :occupancy_grid_created do |grid, z|
      grid.when :occupancy_change do |operation, occupant, tx, ty|
        # TODO un-hardcode the player id
        if occupant.player_id == 1
          # TODO why is occupy, leave messed up?
#          if operation == :occupy 
            # TODO fix this for the visibility range
            for x in ([tx-1,0].max..[tx+1,@map.width-1].min)
              for y in ([ty-1,0].max..[ty+1,@map.height-1].min)
                vx = x*@map.tile_size
                vy = y*@map.tile_size

                # TODO maybe still keep a 2d array around for caching unneccissary blits
                
                # since the colorkey is set to white, this is the same as erasing
                @fog_stamp.blit @mask_image, [vx-3,vy-3]
#                @mask_image.draw_box_s [vx,vy],[vx+@map.tile_size,vy+@map.tile_size],WHITE
              end
            end
#          end
        end
      end
    end
  end

  def draw(screen)
    x_soff = @viewport.screen_x_offset
    y_soff = @viewport.screen_y_offset

    wx,wy = *@viewport.world_to_view(0,0)
    @mask_image.blit screen, [wx+x_soff,wy+y_soff]
  end
end
