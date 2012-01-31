# Index page will show 'now playing' title and time
# play stop forward and back buttons
# and maybe a 'whats next on the playlist' or something

# then a song browser. model ui/flow on ipod/itunes. make it 
# searchable. jQuery. etc.

# models: song, playlist, library.


require 'rubygems'
require 'librmpd'

#$host = 'localhost'
#$port = 6600
#$mpd = MPD.new $host, $port
# put this stuff in Thp.create??

Camping.goes :Thp

def while_connected
    mpd = MPD.new
    mpd.connect
    yield mpd
end


module Thp::Controllers
    class Index < R '/'
        def get
            while_connected do |mpd|
                mpd_status = mpd.status
                @mpd_status = mpd_status.to_s
                @mpd_state = mpd_status['state']
                @song = mpd.current_song
                @playlist = mpd.playlist.map { |s| s['title']}

                render :status_view
            end
        end
    end

    class Play
        def get
            while_connected do |mpd|
                mpd.play
            end
            redirect Index
        end
        def post
            while_connected do |mpd|
                mpd.play
            end
            redirect Index
        end
    end

    class Stop
        def get
            while_connected do |mpd|
                mpd.stop
            end
            redirect Index
        end
        def post
            while_connected do |mpd|
                mpd.stop
            end
            redirect Index
        end
    end

    class Pause
        def get
            while_connected do |mpd|
                mpd.pause = !mpd.paused?
            end
            redirect Index
        end
    end

    class Previous
        def get
            while_connected do |mpd|
                mpd.previous
            end
            redirect Index
        end
    end

    class Next
        def get
            while_connected do |mpd|
                mpd.next
            end
            redirect Index
        end
    end

end


module Thp::Views
    def layout
        html do
            head do
                title { "Thooop" }
            end
            body { self << yield }
        end
    end

    def status_view
        h1.title @song.title
        p.state @mpd_state
        p.controls do
            a '<<', :href => R(Previous)
            text ' | '
            a 'play', :href => R(Play)
            text ' | '
            a 'pause', :href => R(Pause)
            text ' | '
            a 'stop', :href => R(Stop)
            text ' | '
            a '>>', :href => R(Next)
        end
        p.playlist do
        text "Current playlist: #{@playlist}"
        end
        p.meta do
            @mpd_status
        end

#        form :action => R(Play), :method => :post do
#            input :type => :submit, :value => "Play"
#        end
#        form :action => R(Stop), :method => :post do
#            input :type => :submit, :value => "Stop"
#        end
    end
end
