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

  def query
    #search for audio based on search_term
    base_url = "http://api.npr.org/"
    query_url = "#{base_url}query?id=1053&requiredAssets=audio&searchTerm=#{self.search_term}&dateType=story&output=JSON&apiKey=#{API_KEY}"
    result = open(query_url).read
    JSON.parse(result)
  end
end

NPRQuery.new("pizza").query