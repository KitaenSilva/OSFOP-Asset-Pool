class Scene_AUTONAME1 < Scene_Base
  def start()
    super
    create_all_windows
  end

  def create_all_windows()
    create_windowbase13win
    create_windowbase12win
    create_windowbase11win
    create_windowbase10win
    create_windowbase9win
    create_windowbase8win
    create_windowbase7win
    create_windowbase6win
    create_windowbase5win
  end

  def create_windowbase13win()
    @windowbase13_window = Window_Extra2.new(143,165,166,101)
    @windowbase13_window.viewport = @viewport
    @windowbase13_window.set_handler(:ok,    method(:on_windowbase13_ok))
    @windowbase13_window.set_handler(:cancel,    method(:on_windowbase13_cancel))
    @windowbase13_window.show
  end

  def on_windowbase13_ok()
  end

  def on_windowbase13_cancel()
  end

  def create_windowbase9win()
    @windowbase9_window = Window_Selector.new(0,50,143,59)
    @windowbase9_window.viewport = @viewport
    @windowbase9_window.set_handler(:ok,    method(:on_windowbase9_ok))
    @windowbase9_window.set_handler(:cancel,    method(:on_windowbase9_cancel))
    @windowbase9_window.show
  end

  def on_windowbase9_ok()
  end

  def on_windowbase9_cancel()
  end

  def create_windowbase8win()
    @windowbase8_window = Window_Meters.new(143,50,166,115)
    @windowbase8_window.viewport = @viewport
    @windowbase8_window.set_handler(:ok,    method(:on_windowbase8_ok))
    @windowbase8_window.set_handler(:cancel,    method(:on_windowbase8_cancel))
    @windowbase8_window.show
  end

  def on_windowbase8_ok()
  end

  def on_windowbase8_cancel()
  end

  def create_windowbase7win()
    @windowbase7_window = Window_Flavor.new(309,266,235,146)
    @windowbase7_window.viewport = @viewport
    @windowbase7_window.set_handler(:ok,    method(:on_windowbase7_ok))
    @windowbase7_window.set_handler(:cancel,    method(:on_windowbase7_cancel))
    @windowbase7_window.show
  end

  def on_windowbase7_ok()
  end

  def on_windowbase7_cancel()
  end

  def create_windowbase6win()
    @windowbase6_window = Window_Photo.new(309,0,235,266)
    @windowbase6_window.viewport = @viewport
    @windowbase6_window.set_handler(:ok,    method(:on_windowbase6_ok))
    @windowbase6_window.set_handler(:cancel,    method(:on_windowbase6_cancel))
    @windowbase6_window.show
  end

  def on_windowbase6_ok()
  end

  def on_windowbase6_cancel()
  end

  def create_windowbase5win()
    @windowbase5_window = Window_Header.new(0,0,309,50)
    @windowbase5_window.viewport = @viewport
    @windowbase5_window.set_handler(:ok,    method(:on_windowbase5_ok))
    @windowbase5_window.set_handler(:cancel,    method(:on_windowbase5_cancel))
    @windowbase5_window.show
  end

  def on_windowbase5_ok()
  end

  def on_windowbase5_cancel()
  end

end