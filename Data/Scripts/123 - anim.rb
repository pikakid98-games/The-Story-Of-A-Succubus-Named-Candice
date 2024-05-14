#Make Sure to Copy and Paste this into the RPG Script after you downloaded this or copied this!

if true

module Azian_Animated_Title
  BACKGROUND_SCROLL_SPEED = [-1,0]
  NUMBER_OF_PARTICLES = 10
  CHARACTER_POSITION = [0,0]     
  COMMAND_POSITION = [0,270]
  COMMAND_SPACE = [150,-60]
  CHARACTER_AURA_EFFECT = true
  LOGO = true
  LOGO_DURATION = 2
  TRASITION_DURATION = 10
  NEWGAME_STOP_BGM = true
end


$imported = {} if $imported.nil?
$imported[:azian_animated_title_screen] = true


#Scene Title

class Scene_Title
  include Azian_Animated_Title
  
# Main
       
  def main      
      execute_logo if LOGO
      Graphics.update
      Graphics.freeze
      execute_setup
      execute_loop
      dispose
  end  
  def execute_setup
      @phase = 0
      @active = false
      @continue_enabled = DataManager.save_file_exists?
      @com_index = @continue_enabled ? 1 : 0
      @com_index_old = @com_index
      @com_index_max = 2
      create_sprites
  end
  
 # Execute Loop
       
  def execute_loop
       Graphics.update
       Graphics.transition(TRASITION_DURATION)
       play_title_music
       loop do
          Input.update
          update
          Graphics.update
          break if SceneManager.scene != self
       end
   end
      
end
 

# Scene Title

class Scene_Title
    
  def execute_logo
      Graphics.transition
      create_logo 
      loop do
         Input.update
         update_logo
         Graphics.update
         break if !@logo_phase
      end
      dispose_logo
  end
    
  def create_logo
      @logo = Sprite.new
      @logo.z = 100
      @logo.opacity = 0
      @logo_duration = [0,60 * LOGO_DURATION]
      @logo.bitmap = Cache.title1("Logo") rescue nil
      @logo_phase = @logo.bitmap != nil ? true : false      
  end
       
  def dispose_logo      
      Graphics.freeze
      @logo.bitmap.dispose if @logo.bitmap != nil
      @logo.dispose
  end
  
    
  def update_logo  
      return if !@logo_phase
      update_logo_command
      if @logo_duration[0] == 0
         @logo.opacity += 5
         @logo_duration[0] = 1 if @logo.opacity >= 255
       elsif @logo_duration[0] == 1
         @logo_duration[1] -= 1
         @logo_duration[0] = 2 if @logo_duration[1] <= 0
       else  
         @logo.opacity -= 5
         @logo_phase = false if @logo.opacity <= 0
       end
  end
  
     
  def update_logo_command
      return if @logo_duration[0] == 2
      if Input.trigger?(:C) or Input.trigger?(:B)
         @logo_duration = [2,0]
      end
  end
  
end


# Scene Title

class Scene_Title
  
         
  def create_sprites     
      create_background
      create_fog
      create_commands
      create_particles
      create_character
      create_layout
  end
    
             
  def create_fog
      @fog = []
      @fog_speed = [0,0,0]
      for index in 0...2
         @fog.push(Plane.new)
         @fog[index].bitmap = Cache.title1("Fog" + index.to_s)
         @fog[index].blend_type = 0
         @fog[index].opacity = 0
         if index == 0
            @fog[index].z = 4
            @fog_speed[index] = 2
         else
            @fog[index].z = 1
            @fog_speed[index] = 1
         end   
      end
  end
  
#Background(To Activate the Background)
  def create_background
      @background = Plane.new
      @background.bitmap = Cache.title1("Background")
      @background_scroll = [BACKGROUND_SCROLL_SPEED[0],BACKGROUND_SCROLL_SPEED[1],0]
      @background.z = 0
      @background.opacity = 0
  end
  
#Layout
  def create_layout
      @layout = Sprite.new
      @layout.bitmap = Cache.title1("Layout")
      @layout.z = 20
      @layout.opacity = 0
  end

                 
  def create_commands
      @com = []
      for index in 0...3
          @com.push(Title_Commands.new(nil,index))
      end 
  end
  
  
  def create_particles
      @particles_sprite =[]
      for i in 0...NUMBER_OF_PARTICLES
          @particles_sprite.push(Particles_Title.new(nil))
      end
  end   
  
 #Character (Where Character is Positioned)
  def create_character
      @character = Sprite.new
      @character.bitmap = Cache.title1("Character")
      @character.ox = @character.bitmap.width / 2
      @character.oy = @character.bitmap.height / 2
      @character.x = CHARACTER_POSITION[0] + @character.ox
      @character.y = CHARACTER_POSITION[1] + @character.oy
      @character.z = 3
      @character.opacity = 0
  end
 
end


# Particle's Title (For the Particle Movement/Path)

class Particles_Title < Sprite
  
  include Azian_Animated_Title
  
            
  def initialize(viewport = nil)
      super(viewport)
      @speed_x = 0
      @speed_y = 0
      @speed_a = 0
      @speed_o = 0
      self.bitmap = Cache.title1("Particles")
      self.z = 4
      @cx_size = Graphics.width + self.bitmap.width + (self.bitmap.width / 2)
      @cy_size = self.bitmap.height + (self.bitmap.height / 2)
      @cy_limit = -(@cy_size * 3)
      reset_setting(true)
  end  
  
             
  def reset_setting(initial = false)
      zoom = (50 + rand(100)) / 100.1
      self.zoom_x = zoom
      self.zoom_y = zoom
      self.x = rand(Graphics.width)
      self.y = initial == true ? rand(480) : (Graphics.height + @cy_size)
      self.opacity = 0
      z = rand(2)
      if z == 1
         self.z = 5
      else
         self.z = 1
      end
      @speed_y = -(1 + rand(3))
      @speed_x = (1 + rand(2))
      @speed_a = (1 + rand(4))
      @speed_o = (2 + rand(8))
  end
  
              
  def dispose
      super
      self.bitmap.dispose if self.bitmap != nil
  end  
  
               
  def update
      super
      self.x += @speed_x 
      self.y += @speed_y
      self.angle += @speed_a
      self.opacity += 5
      reset_setting if can_reset_setting?
  end  
  
  def can_reset_setting?
      return true if self.y < -@cy_size
      return true if self.x > @cx_size
      return false
  end  

end

#Commands (For New Game,Continue,Exit)

class Title_Commands < Sprite
  include Azian_Animated_Title
  
 
  def initialize(viewport = nil,index)
      super(viewport)
      @index = index
      @float = [0,0,0]
      @image = Cache.title1("Command" + index.to_s)
      @image_cw = @image.width
      @image_ch = (@image.height / 2)
      @active = 1
      @active_old = @active
      self.bitmap = Bitmap.new(@image_cw,@image_ch)
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2 
      @org_pos = [COMMAND_POSITION[0] + self.ox + (COMMAND_SPACE[0] * index),
        COMMAND_POSITION[1] + self.oy + (self.bitmap.height + COMMAND_SPACE[1]) * index,
        self.ox - 24]
      @org_pos[0] += 0
      @org_pos[1] += -20
      self.x = -32 + @org_pos[0] - self.bitmap.width - (self.bitmap.width * index)
      self.y = @org_pos[1]
      self.z = 5
      @next_pos = [@org_pos[0],@org_pos[1]]
      refresh_command
  end
  
 
  def refresh_command
      @active_old = @active
      self.bitmap.clear
      b_rect = Rect.new(0,@image_ch * @active,@image_cw,@image_ch)
      self.bitmap.blt(0,0,@image,b_rect)
  end
  
 
  def dispose_sprites
      self.bitmap.dispose
      @image.dispose
  end
  
              
  def update_sprites(index,active)
      if index == @index
         self.opacity += 10 
         @active = 0
      else
         self.opacity -= 15 if self.opacity > 150
         @float = [0,0,0]
         @active = 1
      end  
      refresh_command if @active_old != @active
      update_slide(0,@next_pos[0])
      update_slide(1,@org_pos[1] + @float[0])
  end
  
                     
  def update_slide(type,np)
      cp = type == 0 ? self.x : self.y
      sp = 3 + ((cp - np).abs / 10)
      if cp > np 
         cp -= sp
         cp = np if cp < np
      elsif cp < np 
         cp += sp
         cp = np if cp > np
      end     
      self.x = cp if type == 0
      self.y = cp if type == 1
  end     
  
end

# Scene Title (Aka: The Graphics and Layout)

class Scene_Title
        
  def dispose
      Graphics.freeze
      dispose_background
      dispose_particles
      dispose_character
      dispose_layout
      dispose_fog
      dispose_commands
  end
             
  def dispose_background
      @background.bitmap.dispose
      @background.dispose    
  end
  
             
  def dispose_layout  
      @layout.bitmap.dispose
      @layout.dispose
  end  
    
              
  def dispose_commands
      @com.each {|sprite| sprite.dispose_sprites }
  end  
  
               
  def dispose_fog
      @fog.each {|sprite| sprite.bitmap.dispose }
      @fog.each {|sprite| sprite.dispose }
  end    
    
 def dispose_particles
     @particles_sprite.each {|sprite| sprite.dispose }
 end    
  
     
  def dispose_character
      @character.bitmap.dispose
      @character.dispose
 end    
  
end


#  Scene Title

class Scene_Title
  
        
  def update_sprites
      update_background    
      update_particles
      update_character
      update_commands
      update_fog
  end
    
           
  def update_fog
      @fog_speed[2] += 1
      return if @fog_speed[2] < 3
      @fog_speed[2] = 0
      for index in 0...2
          @fog[index].opacity += 5
          @fog[index].ox += @fog_speed[index]
      end
  end
  
          
  def update_background
      @layout.opacity += 5
      @background.opacity += 5
      @background_scroll[2] += 1
      return if @background_scroll[2] < 4
      @background_scroll[2] = 0
      @background.ox += @background_scroll[0]
      @background.oy += @background_scroll[1]
  end  
  
                 
  def update_commands
      @com.each {|sprite| sprite.update_sprites(@com_index,@active)}
  end      
  
  def update_particles
      return if @particles_sprite == nil
      @particles_sprite.each {|sprite| sprite.update }
  end  

  def update_character
      @character.opacity += 5
  end
  
end


# Scene Title

class Scene_Title
  
           
  def update
      update_command
      update_sprites
  end
  
          
  def update_command
      update_key
      refresh_index if @com_index_old != @com_index
  end
    
             
  def update_key
      if Input.trigger?(:DOWN) or Input.trigger?(:RIGHT)
         add_index(1) 
      elsif Input.trigger?(:UP) or Input.trigger?(:LEFT)
         add_index(-1)
      elsif Input.trigger?(:C)  
         select_command
      end  
  end
  
               
  def select_command
      case @com_index
         when 0; command_new_game
         when 1; command_continue
         when 2; command_shutdown  
      end
  end
  
                
  def add_index(value = 0)
      @com_index += value
      if !@continue_enabled and @com_index == 1
          @com_index = 2 if value == 1
          @com_index = 0 if value == -1
      end    
      @com_index = 0 if @com_index > @com_index_max
      @com_index = @com_index_max if @com_index < 0
  end
  
            
  def refresh_index
      @com_index_old = @com_index
      Sound.play_cursor
  end
  
          
  def command_new_game    
      Sound.play_ok
      DataManager.setup_new_game
      fadeout_all
      $game_map.autoplay
      SceneManager.goto(Scene_Map)      
  end  

def command_continue
      if !@continue_enabled
         Sound.play_cancel
         return
      else   
         Sound.play_ok
      end  
      SceneManager.call(Scene_Load)
  end    
  
         
  def command_shutdown
      Sound.play_ok
      fadeout_all
      SceneManager.exit    
  end
  
  
  def play_title_music
      $data_system.title_bgm.play
      RPG::BGS.stop
      RPG::ME.stop
  end  
  
  
  def fadeout_all(time = 1000)
      RPG::BGM.fade(time) if NEWGAME_STOP_BGM
      RPG::BGS.fade(time)
      RPG::ME.fade(time)
      Graphics.fadeout(time * Graphics.frame_rate / 1000)
      RPG::BGM.stop if NEWGAME_STOP_BGM
      RPG::BGS.stop
      RPG::ME.stop
  end  
  
end

end