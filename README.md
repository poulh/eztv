# P3::Eztv
[![Gem Version](https://badge.fury.io/rb/p3-eztv.svg)](http://badge.fury.io/rb/p3-eztv)

EZTV Search API: Parses EZTV.ag's HTML as they do not have a clean REST API

## Installation

    $ gem install p3-eztv

## Usage

Search for a series and get all the magnet links:
```ruby
require 'p3-eztv'

white_collar = P3::Eztv::Search.new("white collar")

# uniq uniques by season/episode numbers
white_collar.episodes.uniq.each do |episode|
  puts episode.magnet_link
end
```

Get all regular torrent download links from S01E01:

```ruby
white_collar.episode(1,1).links
# ["//torrent.zoink.it/White.Collar.S01E01.Pilot.HDTV.XviD-FQM.[eztv].torrent",
# "http://www.mininova.org/tor/3077342",
# "http://www.bt-chat.com/download.php?info_hash=e0e74306adca549be19b147b5ee14bde1b99bb1d"]
```

Get number of seasons or number of episodes per season:
```ruby
puts "Number of seasons: #{white_collar.seasons.count}"
# Number of seasons: 5
puts "Number of episodes in season 1: #{white_collar.season(1).count}"
# Number of episodes in season 1: 13
```

Get the last episode of the latest season in S01E01 format:
```ruby
white_collar.episodes.last.s01e01_format
# S05E13
```

Fetch an episode in S01E01 format:
```ruby
white_collar.get('S03E05')
# P3::Eztv::Episode.new
```
There will be an error raised if you browsed for a non existing series:
```ruby
nonny = P3::Eztv::Search.new("nonny")
begin
  nonny.episodes
rescue P3::Eztv::SearchNotFoundError => e
  puts e.message 
  # "Unable to find 'nonny' on https://eztv.it."
end
```

## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
