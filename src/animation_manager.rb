require 'image_list'
class AnimationManager
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60

  constructor :resource_manager
  def setup()
    STDOUT.puts "loading images..."
    load_images
    STDOUT.write "done.\n"
    @animated_objects = []
  end

  def register(animated_object)
    animated_object.frame_num = 0
    animated_object.last_animated_time = 0
    animated_object.frame_count = animated_object.animation_length
    @animated_objects << animated_object
  end

  # returns the image
  def get_default_frame(unit_type)
    @images[unit_type][:default].first
  end

  def get_selection_image(unit_type)
    @images[unit_type][:selected].first
  end

  def update(time)
    for obj in @animated_objects
      if obj.animating?
        if obj.last_animated_time > FRAME_UPDATE_TIME
          obj.next_frame(@images[obj.object_type][obj.animation_image_set][obj.next_frame_num]) 
          obj.last_animated_time = 0
        else
          obj.last_animated_time += time.milliseconds
        end
      end
    end
  end

  def load_images
    @images = {}
    for type, dir in IMAGE_NAMES
      @images[type] = {}
      for k, v in dir
        @images[type][k] = []
        for file_name in v
          @images[type][k] << @resource_manager.load_image(file_name)
        end
      end
    end
    @images
  end
    
end

