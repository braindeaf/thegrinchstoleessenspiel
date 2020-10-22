require 'down'
require 'http'
require 'pry'
require 'yaml'

unless File.exist?('game_ids.yaml')
  # load page to grab the spiel.har
  %x[node spiel.js]

  har = YAML.load_file('spiel.har')
  entries = har['log']['entries']
  entry = entries.detect { |h| h['request']['method'] == 'POST' && h['request']['url'] == 'https://api.spiel.digital/api/gamereleases/query?locale=en_US' }
  ids = JSON.parse(entry['response']['content']['text'])['gameReleaseIds']

  File.open('game_ids.yaml', 'w') do |f|
    f.puts ids.to_yaml
  end
else
  ids = YAML.load_file('game_ids.yaml')
end

unless File.exist?('games.yaml')
  games = []
  http = HTTP
  ids.each_slice(20) do |gids|
    games += JSON.parse(http.get('https://api.spiel.digital/api/gamereleases', params: { ids: gids.join(',') }).to_s)['gameReleases']
  end
  File.open('games.yaml', 'w') do |f|
    f.puts games.to_yaml
  end
else
  games = YAML.load_file('games.yaml')
end

games = games.select { |h| h['coverUrl'] }.sort_by { |h| h['title'] }

games.each do |h|
  ext = h['coverUrl'].split('.').last.downcase.gsub('jpeg', 'jpg')
  path = "images/#{h['id']}.#{ext}"

  unless File.exist?(path)
    Down.download(h['coverUrl'], destination: path)
    # binding.pry unless File.exist?(path)
    if path.include?('.png')
      %x[convert #{path} #{path.sub('.png', '.jpg')}]
    end
    binding.pry unless File.exist?("images/#{h['id']}.jpg")
  end
end

games.each do |h|
  original_path = "images/#{h['id']}.jpg"
  path = "images-composited/#{h['id']}.jpg"
  unless File.exist?(path)
    # binding.pry unless File.exist?(original_path)
    %x[bash composite.sh #{h['id']} "#{h['title']}" "#{h['exhibitorDisplayName']}"]
  end
end

File.open('config.json', 'w') do |f|
  f.puts({
    "output": "video.mp4",
    "options": {
      "fps": 25,
      "loop": 5,
      "transition": true,
      "transitionDuration": 1,
      "videoBitrate": 1024,
      "videoCodec": "libx264",
      "size": "1920x1080",
      "audioBitrate": "128k",
      "audioChannels": 2,
      "format": "mp4",
      "subtitleStyles": {
        "Fontname": "Verdana",
        "Fontsize": "26",
        "PrimaryColour": "11861244",
        "SecondaryColour": "11861244",
        "TertiaryColour": "11861244",
        "BackColour": "-2147483640",
        "Bold": "2",
        "Italic": "0",
        "BorderStyle": "2",
        "Outline": "2",
        "Shadow": "3",
        "Alignment": "1",
        "MarginL": "40",
        "MarginR": "60",
        "MarginV": "40"
      },
    },
  }.to_json)
end

File.open('config.txt', 'w') do |f|
  games.each do |game|
    next if game['id'] == 1
    f.puts "file 'images-composited/#{game['id']}.jpg"
    f.puts 'duration 4s'
  end
end

%x[ffmpeg -f concat -i config.txt -vsync vfr -pix_fmt yuv420p output.mp4]
