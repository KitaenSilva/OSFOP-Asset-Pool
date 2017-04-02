SWPO = Win32API.new 'user32', 'SetWindowPos', ['l','i','i','i','i','i','p'], 'i'
WINX = Win32API.new 'user32', 'FindWindowEx', ['l','l','p','p'], 'i'
SMET = Win32API.new 'user32', 'GetSystemMetrics', ['i'], 'i'
GWRF = Win32API.new 'user32', 'GetWindowRect', ['i','p'], 'i'
MOVW = Win32API.new 'user32', 'MoveWindow', ['l','i','i','i','i','i'], 'i'

SELF_WINDOW = WINX.call(0,0,"RGSS Player",0)
# SELF_WINDOW = WINX.call(0,0,0,"Start Command Prompt With Ruby - irb")

RECT = [0,0,0,0]

class Meta
    def self.query(querytext)
        createwindow = Win32API.new("user32","CreateWindowEx",'lpplllllllll','l')
        showwindow   = Win32API.new('user32','ShowWindow',%w(l l),'l')

        ew = createwindow.call((0x00000100|0x00000200),"Edit", "",((0x00800000)),10,520,250,250,0,0,0,0)
        showwindow.call(ew, 1)

        msgbox querytext

        getWindowText       = Win32API.new( 'user32', 'GetWindowText', 'LPI', 'I')
        getWindowTextLength = Win32API.new('user32', 'GetWindowTextLength', 'L', 'I')
        showwindow.call(ew , 0)
        buf_len = getWindowTextLength.call(ew)
        str = ' ' * (buf_len + 1)
        # Retreive the text.
        getWindowText.call(ew , str, str.length)
        return str.delete("\000")
    end
    def self.move(dx,dy)
        resw = SMET.call(0)
        resh = SMET.call(1)
        width = 544 + ((SMET.call(5) + SMET.call(45)) * 2)
        height = (SMET.call(6) + SMET.call(45)) * 2 + SMET.call(4) + 416
        p = self.getwpos
        x = p[0]-8; y = p[1]-8
        y = 0 if y < 0;x = 0 if x < 0
        MOVW.call(SELF_WINDOW,x+dx,y+dy,width,height,0)
    end
    def self.getwpos
        r = RECT.pack("llll")
        GWRF.call(SELF_WINDOW,r)
        full = r.unpack("llll")
        full[0] = full[0] + 8
        full[1] = full[1] + 8
        full[0,2]
    end
    def self.ree(amount)
        amount.times do |i|
            Schedule_buffer[:shift] << Schedule_function.new("winmov",[5,5])
            Schedule_buffer[:shift] << Schedule_function.new("winmov",[-10,-10])
            Schedule_buffer[:shift] << Schedule_function.new("winmov",[0,10])
            Schedule_buffer[:shift] << Schedule_function.new("winmov",[10,-10])
            Schedule_buffer[:shift] << Schedule_function.new("winmov",[-5,5])
        end
    end
end

Schedule_function = Struct.new(:type, :vars)
Schedule_buffer = { :shift => [], :full => [] }

class Schedule
    def self.run
        if !Schedule_buffer[:shift].empty?
            task = Schedule_buffer[:shift].shift
            case task[:type]
        when "winmov"
            Meta.move(task[:vars][0],task[:vars][1])
        end
        if !Schedule_buffer[:full].empty?
            i = 0
            fi = Schedule_buffer[:full].length
            while i < fi 
                task = Schedule_buffer[:full].shift
                case task[:type]
                    # nothing yet
                end
                i += 1
            end
        end
    end
end