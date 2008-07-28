module MeleeAttacker
  DEFAULT_MELEE_RANGE = 15
  DEFAULT_MELEE_DAMAGE = 3
  DEFAULT_MELEE_ATTACK_SPEED = 300 #ms

  def self.included(target)
    target.add_setup_listener :setup_melee_attacker
    target.add_update_listener :update_melee_attacker
  end

  def setup_melee_attacker(args)
    require_components :pathable, :able
    @abilities << :melee_attack
    @attack_timer = 0
  end

  def update_melee_attacker(time)
    unless @current_target.nil?
      if within_range?
        @attack_timer += time
        if @attack_timer > DEFAULT_MELEE_ATTACK_SPEED
          # we waited long enough, attack!!
          @attack_timer = 0
          melee_damage
        end
      end
    end
  end

  def melee_attack(args)
    target = args[:target]
    if target.is_a? Array
      attack_location args
    else
      if is? :pathable
        attack_entity args
      end
    end
  end

  # attack at a particular location on the map
  def attack_location(args)
    set_target nil
    target = args[:target]
    path_to target[0].to_i, target[1].to_i
    # TODO set some sort of anger flag
  end

  def melee_damage()
    @current_target.damage DEFAULT_MELEE_DAMAGE
  end

  def set_target(target)
    #save anger for later
    unless @current_target.nil?
      @current_target.unsubscribe :move, self 
      @current_target.unsubscribe :death, self 
    end

    unless target.nil?
      target.when :move do |tar|
        if target.alive?
          path_to tar.tile_x, tar.tile_y, [tar] 
        end
      end
      target.when :death do |tar|
        set_target nil
      end
    end
    @current_target = target
  end

  # attack and pursue the targeted entity
  def attack_entity(args)
    target = args[:target]
    if target.is? :livable
      set_target target

      if within_range? 
        melee_damage
      else
        # move closer
        path_to target.tile_x, target.tile_y, [target]

      end
    end
  end

  def within_range?()
      from = Node.new tile_x, tile_y
      to = Node.new @current_target.tile_x, @current_target.tile_y
      dist = Pathfinder.diagonal_heuristic from, to

      range = @range || DEFAULT_MELEE_RANGE

      dist <= range
  end

end
