require 'rubygems'
require 'open-uri'
require 'json'
require 'pry' 
require 'pp'
require 'google/api_client'


# 2. Find a source of embeddable videos with an API to find the 
# top-rated high-definition videos about pizza. Output an HTML file 
# which embeds these videos and presents them as a grid.

class YouTubeConnection

  attr_accessor :video_search_JSON
  
  # YOUTUBE_API_SERVICE_NAME = 'youtube'
  # YOUTUBE_API_VERSION = 'v3'

  def initialize
    @client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
  )
  # @youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)
  end

  def query
    youtube = @client.discovered_api('youtube', 'v3')

    @client.authorization = nil

    video_search = @client.execute :api_method => youtube.search.list, :parameters => {q: 'pizza', part: 'id', type: 'video', chart: "mostPopular"}

    self.video_search_JSON = JSON.parse(video_search.data.to_json)
  end

  def get_video_ids
    self.video_search_JSON.values[4].map do |video|
      video["id"]["videoId"]
    end
  end

  def video_html
# https://www.youtube.com/watch?v=123123asdsad12
    x = get_video_ids.map do |video_id|
      "https://www.youtube.com/watch?v=#{video_id}"
    end
    pp x
  end


end

class EmbedVideotoHTMLPage

# <video width="320" height="240" controls>
#   <source src="movie.mp4" type="video/mp4">
#   <source src="movie.ogg" type="video/ogg">
# Your browser does not support the video tag.
# </video>
end


conn = YouTubeConnection.new
conn.query
conn.get_video_ids
conn.video_html
