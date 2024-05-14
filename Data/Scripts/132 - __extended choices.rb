module SES; module ExtendChoices
 
  MaxVisibleChoices = 6
 
end;end

class Window_ChoiceList < Window_Command
 
  def update_placement
        self.width = [max_choice_width + 12, 96].max + padding * 2
        self.width = [width, Graphics.width].min
        self.height = fitting_height([$game_message.choices.size,
                                      SES::ExtendChoices::MaxVisibleChoices].min)
        self.x = Graphics.width - width
        if @message_window.y >= Graphics.height / 2
          self.y = @message_window.y - height
        else
          self.y = @message_window.y + @message_window.height
        end
  end
end