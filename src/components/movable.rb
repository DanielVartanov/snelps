require 'rubygame/ftor'
module Movable 
  attr_accessor :dest

  def self.included(target)
    target.add_setup_listener :setup_movable 
    target.can_fire :move
  end

  def setup_movable(args)
    require_components :able
    @base_speed = self.speed / 1000.0
    @abilities << :move
  end

  def stop_moving!()
    @dest = nil
    @path = nil
    @direction = nil
    unless @last_tile_x.nil? or (@last_tile_x == @tile_x and @last_tile_y == @tile_y)
      @grid.leave @last_tile_x, @last_tile_y
      fire :move, self
      @last_tile_x = nil
      @last_tile_y = nil
    end
  end

  # sets the target for this unit to be tileX, tileY, direction(:sw,:s,
  # etc)
  def set_destination!(new_tile_x, new_tile_y, dir)
    # current location
    if @grid.occupied?(new_tile_x, new_tile_y)
#      stop_moving!
      p "ERROR?"
      return nil
    end
    @animation_image_set = dir
    x,y = @rect.center

    unless @last_tile_x.nil? or (@last_tile_x == @tile_x and @last_tile_y == @tile_y)
      @grid.leave @last_tile_x, @last_tile_y
    end
    @grid.occupy(new_tile_x, new_tile_y, self)
    fire :move, self

    @last_tile_x = @tile_x
    @last_tile_y = @tile_y

    @tile_x = new_tile_x
    @tile_y = new_tile_y
    new_x,new_y = @map.tiles_to_coords(new_tile_x,new_tile_y)
    
    # our current target
    @dest = Ftor.new new_x, new_y

    # our current directional vector
    @direction = Ftor.new(@dest.x - x, @dest.y - y).unit
    animate
  end

  # this will teleport the entity to x, y
  # nil will remove them from the world (aka death)
  def teleport_to(new_tile_x, new_tile_y=nil)
    stop_moving!
    @grid.leave @tile_x, @tile_y
    unless new_tile_x.nil?
      @tile_x = new_tile_x
      @tile_y = new_tile_y
      new_x,new_y = @map.tiles_to_coords(new_tile_x,new_tile_y)
      @rect.centerx = new_x
      @rect.centery = new_y
      @grid.occupy(new_tile_x, new_tile_y, self)
    end
  end

  def idle?()
    @direction.nil?
  end
  alias moving? idle?

  def to_s()
    "UNIT:[#{@server_id}] at [#{x},#{y}] => DEST:#{@dest.inspect} DIR[#{@direction.inspect}]"
  end
end
