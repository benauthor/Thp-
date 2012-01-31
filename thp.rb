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

                @mpd_stats = mpd.stats.to_s
                @song = mpd.current_song
                @playlist = mpd.playlist

                render :now_playing
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
# will we be doing this by post instead later?
#        def post
#            while_connected do |mpd|
#                mpd.play
#            end
#            redirect Index
#        end
    end

    class PlaySong < R '/playsong/(\d+)'
        def get(number)
            while_connected do |mpd|
                mpd.play(number)
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
                mpd.playid(0) if mpd.current_song == nil
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

    def now_playing
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
        div.playlist do
            ul do
            @playlist.each do |s|
                li.song do
                    p.title do
                    a s.title, :href => R(PlaySong, s.id)
                    end
                    p.songmeta s.to_s
                end
            end
            end
        end
        div.meta do
            p.status do
                @mpd_status
            end
            p.stats do
                @mpd_stats
            end
        end

# will we be doing this by post later?
#        form :action => R(Play), :method => :post do
#            input :type => :submit, :value => "Play"
#        end
    end
end
