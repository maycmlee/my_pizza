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
    pizza = NPRQuery.new("pizza")
    results = pizza.query
    pizza.get_audio_urls(results)
  end

  def query
    #search for audio based on search_term
    base_url = "http://api.npr.org/"
    query_url = "#{base_url}query?&requiredAssets=audio&searchTerm=#{self.search_term}&dateType=story&searchType=mainText&output=JSON&apiKey=#{API_KEY}"
    result = open(query_url).read
    JSON.parse(result)
  end

  def get_audio_urls(json_data)
    json_data["list"]["story"].map do |data|
      data["audio"][0]["format"]["mp3"].first["$text"]
    end
  end
end

NPRQuery.get_pizza_audios