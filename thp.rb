# Index page will show 'now playing' title and time
# play stop forward and back buttons
# and maybe a 'whats next on the playlist' or something

# then a song browser. model ui/flow on ipod/itunes. make it 
# searchable. jQuery. etc.

# models: song, playlist, library.

# make play/stop/pause buttons look better. and visual indication on click.

# perhaps library browsing/playlist management is a seperate lil' app

require 'rubygems'
require 'librmpd'
require 'json'

#$host = 'localhost'
#$port = 6600
#$mpd = MPD.new $host, $port
# put this stuff in Thp.create??

Camping.goes :Thp


module Thp::Helpers
    def while_connected
        mpd = MPD.new
        mpd.connect
        yield mpd
    end

    def return_json
        while_connected do |mpd|
            yield mpd
            @headers['Content-Type'] = "application/json"
            @result.to_json
        end
    end
end


module Thp::Controllers

    class Static < R '/static/(.*)'
      def get(static_name)
        current_dir = File.expand_path(File.dirname(__FILE__))
        @headers['Content-Type'] = "text/plain"
        @headers['X-Sendfile'] = "#{current_dir}/static/#{static_name}"
      end
    end

    class Image < R '/img/(.*)'
      def get(static_name)
        current_dir = File.expand_path(File.dirname(__FILE__))
        # TODO: quick and dirty mime type detection. this should be improved
        extension = static_name[/\.(gif|jpg|png)$/]
        mime_types = {".jpg"=>"jpeg", ".gif"=>"gif", ".png"=>"png"}
        mime_type = mime_types[extension]
        @headers['Content-Type'] = "image/" + mime_type
        @headers['X-Sendfile'] = "#{current_dir}/img/#{static_name}"
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
            return_json do |mpd|
                mpd.play
                @result = mpd.current_song.title
            end
        end
    end

    class PlaySong < R '/playsong/(\d+)'
        def get(number)
            return_json do |mpd|
                mpd.play(number)
                @result = mpd.current_song.title
            end
        end
    end

    class Status
        def get
            return_json do |mpd|
                @result = mpd.status.to_s
            end
        end
    end

    class Stats
        def get
            return_json do |mpd|
                @result = mpd.stats.to_s
            end
        end
    end

    class Stop
        def get
            return_json do |mpd|
                mpd.stop
                @result = "Stopped"
            end
        end
    end

    class Pause
        def get
            return_json do |mpd|
                paused = mpd.paused?
                mpd.pause = !paused
                if paused == false
                    @result = "Paused"
                else
                    @result = mpd.current_song.title
                end
            end
        end
    end

    class Previous
        def get
            return_json do |mpd|
                mpd.previous
                @result = mpd.current_song.title
            end
        end
    end

    class Next
        def get
            return_json do |mpd|
                mpd.next
                if mpd.current_song != nil
                    @result = mpd.current_song.title
                else
                    @result = "Stopped"
                end
            end
        end
    end

    class Error
        def get
#            render :mpd_error
            "There was an error connecting to mpd"
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
#                script :src => "/static/jquery-1.7.min.js",
#                       :type => 'text/javascript' do
#                    #empty block because we need the close script tag
#                end
#                script :src => "/static/jqtouch-jquery.min.js",
#                       :type => 'text/javascript' do
#                end
                script :src => "/static/thp.js",
                       :type => 'text/javascript' do
                end

                link :rel => 'stylesheet', :type => 'text/css',
                     :href => '/static/jqtouch.css', :media => 'screen'
                link :rel => 'stylesheet', :type => 'text/css',
                     :href => '/static/jqt.css', :media => 'screen'

                title { "Thp!" }
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

             #ajax this
#            p.state @mpd_state # need to ajax this
            ul.rounded do
                li do
                    if @song == nil
                        p.songtitle "Thp!!"
                    else
                        p.songtitle @song.title
                    end
                end
                li do
                    a.greenbutton 'Play', :href => R(Play)
                    a.whitebutton 'Pause', :href => R(Pause)
                    a.redbutton 'Stop', :href => R(Stop)
                end
                li do
                    ul.individual do
                        li do
                            a.graybutton 'Previous', :href => R(Previous)
                        end
                        li do
                            a.graybutton 'Next', :href => R(Next)
                        end
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
                li do
                    text "Now playing: "
                    span.songtitle
                end
                @playlist.each do |s|
                    li.playsong do
#                        a.playsong :href => R(PlaySong, s.pos) do
                        h2.title s.title
                        p.id s.pos
                        p s.artist
                        p s.album
#                        end
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
                li.about do
                    h2 "Thp! is a little mpd client made in Camping."
                end
                li.status do
                    h2 "mpd status"
                    p @mpd_status
                end
                li.stats do
                    h2 "mpd stats"
                    p @mpd_stats
                end
            end
        end
    end
end
