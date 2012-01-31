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

    class Static < R '/static/(.*)'
      def get(static_name)
        current_dir = File.expand_path(File.dirname(__FILE__))
        @headers['Content-Type'] = "text/plain"
        @headers['X-Sendfile'] = "#{current_dir}/static/#{static_name}"
      end
    end

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
        def post
            while_connected do |mpd|
                mpd.play
            end
            "Playing"
        end
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
        def post
            while_connected do |mpd|
                mpd.stop
            end
            "Stopped"
        end
    end

    class Pause
        def get
            while_connected do |mpd|
                mpd.pause = !mpd.paused?
            end
            redirect Index
        end
        def post
            while_connected do |mpd|
                mpd.pause = !mpd.paused?
            end
            "Paused"
        end
    end

    class Previous
        def get
            while_connected do |mpd|
                mpd.previous
            end
            redirect Index
        end
        def post
            while_connected do |mpd|
                mpd.previous
            end
            # maybe return song id so it can be updated
            "previous"
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
        def post
            while_connected do |mpd|
                mpd.next
                mpd.playid(0) if mpd.current_song == nil
            end
            # maybe return song id so it can be updated
            "next"
        end
    end

end


module Thp::Views
    def layout
        html do
            head do
                script :src => "/static/zepto.min.js",
                       :type => 'text/javascript' do
                    #empty block because we need the close script tag
                end
                script :src => "/static/jqtouch.min.js",
                       :type => 'text/javascript' do
                end
                link :rel => 'stylesheet', :type => 'text/css',
                     :href => '/static/jqtouch.css', :media => 'screen'
                title { "Thooop" }

                script :type => 'text/javascript' do
                    text <<-END_OF_STRING
$.jQTouch({
    icon: 'jqtouch.png',
    statusBar: 'black-translucent',
    preloadImages: []
});
                    END_OF_STRING
                end

            end
            body { self << yield }
        end
    end

    def now_playing
        div.home! do
            div.toolbar do
                h1 "Thp!"
                a.button 'Playlist', :href => '#playlist'
                a.button.leftbutton.flip 'Info', :href => '#info'
            end

            h2.title @song.title #ajax this
#            p.state @mpd_state # need to ajax this
            ul.rounded do
                li do
                    form :action => R(Play), :method => :post do
                        input :type => :submit, :value => "Play"
                    end
                end
                li do
                    form :action => R(Pause), :method => :post do
                        input :type => :submit, :value => "Pause"
                    end
                end
                li do
                    form :action => R(Stop), :method => :post do
                        input :type => :submit, :value => "Stop"
                    end
                end
            end
            ul.individual do
                li do
                    form :action => R(Previous), :method => :post do
                        input :type => :submit, :value => "Previous"
                    end
                end
                li do
                    form :action => R(Next), :method => :post do
                        input :type => :submit, :value => "Next"
                    end
                end
            end
#            ul.rounded do
#                li do
#                    a.leftbutton.flip 'Info', :href => '#info'
#                end
#            end
#            div.info do
#                p.status do
#                    @mpd_status
#                end
#                p.stats do
#                    @mpd_stats
#                end
#            end
        end



        div.playlist! do
            div.toolbar do
                h1 "Playlist!"
                a.button.back 'Back', :href => '#home'
            end
            ul.edgetoedge do
                @playlist.each do |s|
                    li.arrow do
                        a s.title, :href => R(PlaySong, s.id)
                        p s.artist
                        p s.album
                    end
                end
            end
        end

        div.info! do
            div.toolbar do
                h1 "Info!"
                a.button.back 'Back', :href => '#home'
            end
            ul.rounded do
                li.status do
                    @mpd_status
                end
                li.stats do
                    @mpd_stats
                end
            end
        end
    end
end
