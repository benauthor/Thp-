Thp!
====

That's onomonopia.
------------------

It's a little mpd client built on Camping. For my house.

You'll need Ruby and Rubygems and Git and MPD and MPC. So:

    apt-get install ruby rubygems git mpd mpc

(you'll prolly need to `sudo` that if you're on ubuntu)

You'll need to set up MPD so it works. I made some notes about that but lost em. You probably have to edit your mpd.conf (in /etc/) and maybe change some folder permissions so mpd can write playlists. I forget. Try out MPD with MPC (its command-line client) to make sure it works ok before you move on.

Anyhow, next you'll need Bundler, which you install via Rubygems

    gem install bundler

(ditto about sudo)

Then use git to install the app

    git clone git@github.com:benauthor/Thp-.git

then bundler will install the rest of the dependencies: camping, markaby, and librmpd

    cd Thp-
    bundle install

To run it, start the camping server

    camping thp.rb

And point a browser at localhost:3301, or to reach it across your LAN you have to figure out the ip of your computer that's running the server... for example, mine is 192.168.1.102:3301

Groovy!
