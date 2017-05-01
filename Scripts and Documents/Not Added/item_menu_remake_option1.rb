    #==============================================================================
    # Item Menu Remake V 1.5
    #     Created by: Uriel Everos
    #==============================================================================
    # This Script Features the Following:
    # † Changes Item menu design
    # † Made Upon Request: R_Valkyrie
    # † Credits to: Mr. Trivel
    #==============================================================================
    # ☩ Start of Script
    #==============================================================================
     
    #==============================================================================
    # ☩ Creates Item Scene
    #==============================================================================
    class Scene_Item < Scene_ItemBase
     
      def start
        super
        create_equipped_weapon_window
        create_help_item_window
        create_category_window
        create_item_window
      end
     
      # ☩ Creates Category
      def create_category_window
        @category_window = Window_ItemCategory.new
        @category_window.viewport = @viewport
        @category_window.help_window = @help_item_window
        @category_window.y = 0
        @category_window.set_handler(:ok,     method(:on_category_ok))
        @category_window.set_handler(:cancel, method(:return_scene))
      end
     
      # ☩ Creates Item List
      def create_item_window
        wy = @category_window.height
        wh = Graphics.height - @help_item_window.height - @category_window.height
        widt = Graphics.width-250
        @item_window = Window_ItemList.new(10, wy + 15, widt, wh -30)
        @item_window.viewport = @viewport
        @item_window.help_window = @help_item_window
        @item_window.set_handler(:ok,     method(:on_item_ok))
        @item_window.set_handler(:cancel, method(:on_item_cancel))
        @category_window.item_window = @item_window
        
      # ☩ Creates Item Icon Window
        whc = Graphics.height - @help_item_window.height - @category_window.height
        @icon_window = Window_Item_Icon.new(@item_window.width+55, @category_window.height+35,
        Graphics.width-@item_window.width - 95, whc - 70)
        @icon_window.viewport = @viewport
        @item_window.icon_window = @icon_window
      end
     
      # ☩ Creates Item Description
      def create_help_item_window
        @help_item_window = Window_Help_Item.new
        @help_item_window.viewport = @viewport
      end
     
      # ☩ Creates Equipped weapon and HP bar
      def create_equipped_weapon_window
        @equipped_weapon_window = Window_Equipped_Weapon.new
        @equipped_weapon_window.viewport = @viewport
      end
     
      def on_item_cancel
        @item_window.unselect
        @category_window.activate
        @icon_window.refresh
      end
    end
     
    #==============================================================================
    # ☩ Removes item Icon in list
    #==============================================================================
    class Window_Base < Window
       def draw_item_name_custom(item, x, y, enabled = true, width = 172)
        return unless item
        change_color(normal_color, enabled)
        draw_text(x + 24, y, width, line_height, item.name)
      end
    end
     
    #==============================================================================
    # ☩ Item List
    #==============================================================================
    class Window_ItemList < Window_Selectable
      attr_reader   :icon_window
      def col_max
        return 1
      end
      def draw_item_number(rect, item)
        draw_text(rect, sprintf("x%2d", $game_party.item_number(item)), 2)
      end
     
      def draw_item(index)
        item = @data[index]
        if item
          rect = item_rect(index)
          rect.x -= 10
          rect.width -= 4
          draw_item_name_custom(item, rect.x, rect.y, enable?(item))
          draw_item_number(rect, item)
        end
      end
     
      def update_help
        @help_window.set_item(item)
        @icon_window.set_item(item) if @icon_window
      end
     
      def icon_window=(icon_window)
        @icon_window = icon_window
        call_update_help_icon
      end
     
      def update_help_icon
        @icon_window.clear
      end
     
      def call_update_help_icon
        update_help_icon if active && @icon_window
      end
    end
     
    #==============================================================================
    # ☩ Description Window
    #==============================================================================
    class Window_Help_Item < Window_Base
     
      def initialize(line_number = 5)
        height = Graphics.height - fitting_height(line_number)
        super(fitting_height(line_number), height, Graphics.width - fitting_height(line_number), fitting_height(line_number))
      end
     
      def set_text(text)
        if text != @text
          @text = text
          refresh
        end
      end
     
      def clear
        set_text("")
      end
     
      def set_item(item)
        set_text(item ? item.description : "")
      end
     
      def refresh
        contents.clear
        draw_text_ex(4, 0, @text)
      end
    end
     
    #==============================================================================
    # ☩ Item Icon
    #==============================================================================
    class Window_Item_Icon < Window_Base
      def initialize(x, y, width, height)
        super
      end
     
      def refresh
        contents.clear
      end
     
      def set_item(item)
        contents.clear
        if item.nil?
        else
            draw_icon_custom(item.icon_index, 40, 40)
        end
      end
     
      def draw_icon_custom(icon_index, x, y, enabled = true)
        bitmap = Cache.system("Iconset")
        f = 2
        n = 24 * f
        iconbit = Bitmap.new(bitmap.width * f, bitmap.height * f)
        iconbit.stretch_blt(iconbit.rect, bitmap, bitmap.rect)
        rect = Rect.new(icon_index % 16 * n, icon_index / 16 * n, n, n)
        contents.blt(x, y, iconbit, rect, enabled ? 255 : translucent_alpha)
        bitmap.dispose
        iconbit.dispose
      end
    end
     
    #==============================================================================
    # ☩ Equipped weapon
    #==============================================================================
    class Window_Equipped_Weapon < Window_Base
     
      def initialize(line_number = 5)
        height = Graphics.height - fitting_height(line_number)
        super(0, height, fitting_height(line_number), fitting_height(line_number))
        draw_actor_hp($game_party.leader, 0, 0)
        if $game_party.leader.weapons[0].nil?
          self.contents.draw_text(10,60,200,line_height,weapon_name)
        else
          self.contents.draw_text(10,100,200,line_height,weapon_name)
        end
        
        draw_icon_custom(weapon_icon, 35, 50)
        
      end
     
      def draw_icon_custom(icon_index, x, y, enabled = true)
        bitmap = Cache.system("Iconset")
        f = 2
        n = 24 * f
        iconbit = Bitmap.new(bitmap.width * f, bitmap.height * f)
        iconbit.stretch_blt(iconbit.rect, bitmap, bitmap.rect)
        rect = Rect.new(icon_index % 16 * n, icon_index / 16 * n, n, n)
        contents.blt(x, y, iconbit, rect, enabled ? 255 : translucent_alpha)
        bitmap.dispose
        iconbit.dispose
      end
     
      def refresh
        self.contents.clear
      end
     
      def weapon_icon
        return $game_party.leader.weapons[0].nil? ? 0 : $game_party.leader.weapons[0].icon_index
      end
     
      def weapon_name
       # return "No Weapon"
       return $game_party.leader.weapons[0].nil? ? "No Weapon" : $game_party.leader.weapons[0].name
      end
    end
     
    #==============================================================================
    # ☩ End of Script
    #==============================================================================