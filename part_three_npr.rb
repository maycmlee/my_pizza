require 'rubygems'
require 'open-uri'
require 'json'
require 'pry' 
require 'pp'

# 3. Find an API for a source of news, in audio format. 
# Output a file that can be loaded into VLC Media Player 
# to play a series of news stories about pizza.

class NPRQuery
  attr_accessor :search_term

  API_KEY = File.read("npr.yml")

  def initialize(search_term)
    @search_term = search_term
  end

  def self.get_pizza_audios
    results = NPRQuery.new("pizza").query
    pizza_audio = GetAudioFiles.new(results)
    urls = pizza_audio.get_audio_urls
    pizza_audio.create_playlist(urls)
  end

  def query
    #search for audio based on search_term and return JSON
    base_url = "http://api.npr.org/"
    query_url = "#{base_url}query?&requiredAssets=audio&searchTerm=#{self.search_term}&dateType=story&searchType=mainText&output=JSON&apiKey=#{API_KEY}"
    result = open(query_url).read
    JSON.parse(result)
  end
end

class GetAudioFiles
  attr_accessor :json_data

  def initialize(json_data)
    @json_data = json_data
  end

  def get_audio_urls
    self.json_data["list"]["story"].map do |data|
      # binding.pry
      # data["audio"][0]["format"]["mp3"][3]["$text"]
      data["audio"][0]["format"]["mp3"].first["$text"]
    end
  end

  # def download_audio(urls)
  #   mp3s_list = []
  #   Dir.mkdir("audio") unless File.exist?("audio")
  #   urls.each_with_index do |url, index|
  #     open("audio/audio_#{index}.mp3", 'wb') do |file|
  #       file << open(url).read
  #       mp3s_list << "audio/audio_#{index}.mp3"
  #     end
  #   end
  # end

  def create_playlist(mp3_urls)
    #Open the file and make it writable
    file = File.open("pizza_news.m3u", 'w'){ |f|
      f.write("\n")
      mp3_urls.each do |url|
        f.write("\n")
        f.write("#{url}")
        f.write("\n")
      end    
    }
  end

end

NPRQuery.get_pizza_audios