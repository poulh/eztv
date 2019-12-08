require 'httparty'
require 'nokogiri'
require 'uri'

module P3
    module Eztv
        SE_FORMAT = "S(\\d{1,2})E(\\d{1,2})"
        X_FORMAT = "(\\d{1,2})x(\\d{1,2})"

        class SearchNotFoundError < StandardError
            def initialize(search)
                msg = "Unable to find '#{search.search_string()}' on https://eztv.ag."
                super(msg)
            end
        end

        class Search
            include HTTParty
            attr_reader :name, :high_def
            EPISODES_XPATH = '//*[@id="header_holder"]/table[5]'

            base_uri 'http://eztv.ag'

            def initialize(phrase)
                @phrase = phrase
                @high_def_term = false
            end
          
            def high_def!(term)
                @high_def_term = term
            end

            def search_string
                search_term = "#{@phrase} #{@high_def_term}"
                return URI::escape( search_term )
            end

            def episodes
                @episodes ||= EpisodeFactory.create( name, fetch_episodes() )
            end

            def episode(season, episode_number)
                episodes().find do |episode|
                    episode.season == season and episode.episode_number == episode_number
                end
            end

            def get(s01e01_format)
                season_episode_match_data = s01e01_format.match( /#{SE_FORMAT}/ )
                season  = season_episode_match_data[1].to_i
                episode_number = season_episode_match_data[2].to_i
                return episode(season, episode_number)
            end

            def season(season)
                episodes().find_all {|episode| episode.season == season }
            end

            def seasons
                episodes().sort.group_by {|episode| episode.season }
            end

            private

            def fetch_episodes

                # 'get' method comes from httparty
                result = Search::get("/search/#{self.search_string()}")

                document = Nokogiri::HTML(result)

                episodes_array = document.xpath( EPISODES_XPATH )

                episodes_array = episodes_array.children
                episodes_array = episodes_array.select{ | episode | episode.attributes['class'].to_s == 'forum_header_border' }

                raise SearchNotFoundError.new(self) if episodes_array.empty?

                return episodes_array
            end
        end

        module EpisodeFactory
            def self.create( name, episodes_node_array )
                episodes = []
                episodes_node_array.reverse.collect do |episode_node|
                    begin
                        e = Episode.new( episode_node )

                        if( ( e.raw_title.match( /#{name} #{SE_FORMAT}/i ) ) or ( e.raw_title.match( /#{name} #{X_FORMAT}/i ) ) )
                            # Episode will throw if it can't parse
                            episodes << e
                        end
                    rescue
                    end
                end
                return episodes
            end
        end

        class Episode
            attr_accessor :season, :episode_number, :links, :magnet_link, :raw_title

            def initialize(episode_node)
                set_season_and_episode_number(episode_node)
                set_links(episode_node)
            end

            def s01e01_format
                @s01e01_format ||= "S#{season.to_s.rjust(2,'0')}E#{episode_number.to_s.rjust(2,'0')}"
            end

            def eql?(other)
                other.hash == self.hash
            end

            def hash
                [episode_number, season].hash
            end

            def <=>(other)
                return self.s01e01_format <=> other.s01e01_format
            end

            private

            def set_season_and_episode_number(episode_node)
                @raw_title = episode_node.css('td.forum_thread_post a.epinfo').first.inner_text
                season_episode_match_data = @raw_title.match( /#{SE_FORMAT}/ ) || @raw_title.match( /#{X_FORMAT}/ )
                raise "no match" unless season_episode_match_data
                @season = season_episode_match_data[1].to_i
                @episode_number = season_episode_match_data[2].to_i
            end

            def set_links(episode_node)
                links_data = episode_node.css('td.forum_thread_post')[2]
                @magnet_link = links_data.css('a.magnet').first.attributes['href'].value
                @links = links_data.css('a')[2..-1].map {|a_element| a_element['href'] }
            end
        end
    end
end
