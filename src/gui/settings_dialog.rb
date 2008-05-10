require 'publisher'
require 'dialog'
class SettingsDialog < Dialog
  extend Publisher
  can_fire :destroy_modal_dialog

  attr_accessor :settings
  def setup(*args)
    @settings = args.shift

    @layout = AbsoluteLayout.new self, @font_manager, 
      {
        :title=>"Snelps Settings",
        :x=>100,
        :y=>100,
        :w=>824,
        :h=>600
      }
    check = CheckBox.new @layout, "Fullscreen", :checked => @settings[:fullscreen] do |c|
      @settings[:fullscreen] = c.checked?
    end
    @layout.add check, 450, 120

    button = Button.new @layout, "Cancel" do |b|
      close
    end
    @layout.add button, 150, 350
    button = Button.new @layout, "OK" do |b|
      apply
      close
    end
    @layout.add button, 450, 350
  end

  def on_key_up(event)
    case event.key
    when K_ESCAPE
      close
    when K_Q
      close
    else
      @layout.key_up event
    end
  end
end
