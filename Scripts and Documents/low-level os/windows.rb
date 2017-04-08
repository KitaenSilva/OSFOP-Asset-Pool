if $OS == 0 
    SWPO = Win32API.new 'user32', 'SetWindowPos', ['l','i','i','i','i','i','p'], 'i'
    WINX = Win32API.new 'user32', 'FindWindowEx', ['l','l','p','p'], 'i'
    SMET = Win32API.new 'user32', 'GetSystemMetrics', ['i'], 'i'
    GWRF = Win32API.new 'user32', 'GetWindowRect', ['i','p'], 'i'
    MOVW = Win32API.new 'user32', 'MoveWindow', ['l','i','i','i','i','i'], 'i'

    SELF_WINDOW = WINX.call(0,0,"RGSS Player",0)
    # SELF_WINDOW = WINX.call(0,0,0,"Start Command Prompt With Ruby - irb")

    RECT = [0,0,0,0]
end

class WIN
    def self.move(dx, dy)
        resw = SMET.call(0)
        resh = SMET.call(1)
        width = Graphics.width + ((SMET.call(5) + SMET.call(45)) * 2)
        height = (SMET.call(6) + SMET.call(45)) * 2 + SMET.call(4) + Graphics.height
        p = self.getwpos
        x = p[0]-8; y = p[1]-8
        y = 0 if y < 0;x = 0 if x < 0
        MOVW.call(SELF_WINDOW,x+dx,y+dy,width,height,0)
    end
    def self.movetocoords(x,y)
        width = Graphics.width + ((SMET.call(5) + SMET.call(45)) * 2)
        height = (SMET.call(6) + SMET.call(45)) * 2 + SMET.call(4) + Graphics.height
        MOVW.call(SELF_WINDOW,x-8,y-8,width,height,0)
    end
    def self.getwpos
        r = RECT.pack("llll")
        GWRF.call(SELF_WINDOW,r)
        full = r.unpack("llll")
        full[0] = full[0] + 8
        full[1] = full[1] + 8
        full[0,2]
    end
    def self.query(querytext, caps)
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
        str = str.delete("\000")
        if caps 
            str.upcase!
        end
        return str
    end
end
