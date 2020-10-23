How to steal public facing information.
=======================================

The challenge was to create a 90 minute video of all of this year's Spiel.Digital releases. So....

* pinch Spiel's game ids for each game using Puppeeter to automate Chrome and Puppeeter-Har to capture all requests including calls to their own API.
* Now that we have a list of game ids we can make multiple calls to their API using the Ruby HTTP client.
* Storing each piece of game data as YAML.
* Grab each image using the Down gem and store it.
* convert all non-JPG to JPG
* using Imagemagick compose an image per game with a background image, game name and title, with other branding.
* piece all of these together into one video usiing FFMPEG
* cheat and apply audio to the video in Da Vinci Resolve. Too lazy to find out how to loop audio over a video with FFMPEG

    yarn
    bundle install
    ruby scrape.rb

Then you might just end up with something like...

https://youtu.be/x1qg86t4mdY
