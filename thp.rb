# Index page will show 'now playing' title and time
# play stop forward and back buttons
# and maybe a 'whats next on the playlist' or something

#then a song browser. model it on iphone/itunes. make it 
# searchable. jQuery. etc.


require 'rubygems'
require 'librmpd'

#$host = 'localhost'
#$port = 6600
#$mpd = MPD.new $host, $port
# i think we put this stuff in Thp.create??

Camping.goes :Thp

# helpers

def while_connected
    begin
        mpd = MPD.new
        mpd.connect
        yield mpd
#    rescue
#        "unable to connect to mpd"
    end
end

# Controllers

module Thp::Controllers
    class Index < R '/'
        def get
            while_connected do |mpd|
                mpd_status = mpd.status
                @mpd_status = mpd_status.to_s
                @mpd_state = mpd_status['state']
                @song = mpd.current_song

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

    class Status
        def get
            while_connected do |mpd|
                mpd.status
            end
        end
    end
end

# Views

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
        h1 @song.title
        p @mpd_state
        p.controls do
            a 'play', :href => R(Play)
            text ' | '
            a 'stop', :href => R(Stop)
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
