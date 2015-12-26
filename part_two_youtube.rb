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

  DEVELOPER_KEY = File.read("youtube.yml")

  def initialize
    @client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
    )
  end

  def get_pizza_video_urls
    get_video_ids.map do |video_id|
      "https://www.youtube.com/embed/#{video_id}"
    end
  end

  def get_video_ids
    pizza_query.values[4].map do |video|
      video["id"]["videoId"]
    end
  end

  def pizza_query
    youtube = @client.discovered_api('youtube', 'v3')

    video_search = @client.execute :api_method => youtube.search.list, :parameters => {q: 'pizza', part: 'id', type: 'video', chart: "mostPopular"}

    JSON.parse(video_search.data.to_json)
  end
end

class EmbedVideotoHTMLPage
  attr_accessor :urls_array

  def initialize(urls_array)
    @urls_array = urls_array
  end

  def create_html_page
    File.open("pizza_videos.html","wb") do |file|
      file.write("<!DOCTYPE html><html><body>")
      embed_video_strings.each do |video_string|
        file.write(video_string)
      end
      file.write("</body></html>")
    end
  end

  def embed_video_strings
    self.urls_array.map do |url|
      "<iframe title='YouTube video player' width='480' height='390' src=" + url + " type='video/mp4'></iframe>"
    end
  end
end

x = YouTubeConnection.new.get_pizza_video_urls
y = EmbedVideotoHTMLPage.new(x).create_html_page
