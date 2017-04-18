wintest = `ver`
wintest.downcase!
lintest = `uname -o`
lintest.downcase!
osxtest = `sw_vers`
osxtest.downcase!
if wintest.include? "windows"
  $OS = 0
elsif lintext.include? "linux"
  $OS = 2
elsif osxtest.include? "mac os x"
  $OS = 1
else
  $OS = -1
end


module Meta
  def query(querytext, caps = false)
    if $OS == 0
      return WIN.query(querytext, caps)
    elsif $OS == 1
      return OSX.query(querytext, caps)
    elsif $OS == 2
      return LINUX.query(querytext, caps)
    else
      raise $OS
    end
  end
  def move(dx, dy)
    if $OS == 0
      WIN.move(dx, dy)
    elsif $OS == 1
      OSX.move(dx, dy)
    elsif $OS == 2
      LINUX.move(dx, dy)
    else
      raise $OS
    end
  end
  def movetocoords(x, y)
    if $OS == 0
      WIN.movetocoords(x, y)
    elsif $OS == 1
      OSX.movetocoords(x, y)
    elsif $OS == 2
      LINUX.movetocoords(x, y)
    else
      raise $OS
    end
  end
  def ree(amount)
    amount.times do |i|
      $Schedule_buffer[:shift] << Schedule_function.new("winmov", [5, 5])
      $Schedule_buffer[:shift] << Schedule_function.new("winmov", [-10, -10])
      $Schedule_buffer[:shift] << Schedule_function.new("winmov", [0, 10])
      $Schedule_buffer[:shift] << Schedule_function.new("winmov", [10, -10])
      $Schedule_buffer[:shift] << Schedule_function.new("winmov", [-5, 5])
    end
  end
  def shake(shakestuffz)
    if (shakestuffz[2] >= shakestuffz[1]) && shakestuffz[1] != -1
      $AllDoTheHarlemShake = false
      self.movetocoords(shakestuffz[3][0], shakestuffz[3][1])
      return
    end
    r = Random.new
    xtens = r.rand(shakestuffz[0])
    ytens = r.rand(shakestuffz[0])
    xtens = xtens * -1 if r.rand(2) == 1; ytens = ytens * -1 if r.rand(2) == 1
    self.movetocoords(xtens + shakestuffz[3][0], ytens + shakestuffz[3][1])
    $ShakeMusic[2] += 1
  end
  def startshake(intensity, amount)
    $ShakeMusic = [intensity, amount, 0, self.getwpos]
    $AllDoTheHarlemShake = true
  end
  def stopshake
    $AllDoTheHarlemShake = false
    self.movetocoords($ShakeMusic[3][0], $ShakeMusic[3][1])
  end
  def grablocation()
    require "net/http"
    require "uri"

    uri = URI.parse("http://ip-api.com/json")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    if response != nil
      res = JSON.parse(response.body)
      if res["status"] == "success"
        if res["country"] == "United States"
          $game_actors[9] = res["regionName"]
        else
          $game_actors[9] = res["country"]
        end
      else
        $game_actors[9] = "earth"
      end
    else
      $game_actors[9] = "earth"
    end
  end
end

Schedule_function = Struct.new(:type, :vars)
$Schedule_buffer = { :shift => [], :full => [] }
$AllDoTheHarlemShake = false
$ShakeMusic = [0, 0, 0, [0, 0]] #intensity, shaking amount, shakes done, original coords, opt(shaketype, extrainfo)

module Schedule
  def run
    if !$Schedule_buffer[:shift].empty?
      task = $Schedule_buffer[:shift].shift
      case task[:type]
      when "winmov"
        Meta.move(task[:vars][0], task[:vars][1])
      end
    end
    if !$Schedule_buffer[:full].empty?
      i = 0
      fi = $Schedule_buffer[:full].length
      while i < fi
        task = $Schedule_buffer[:full].shift
          #case task[:type]
              # nothing yet
          #end
        i += 1
      end
    end
    if $AllDoTheHarlemShake
      Meta.shake($ShakeMusic)
    end
  end
end
