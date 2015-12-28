require 'rubygems'
require 'open-uri'
require 'json'
require 'pry' 
require 'pp'
require 'csv'
require 'google/api_client'
require 'flickr_fu'
require 'RMagick'
include Magick

class All
  def self.run
    VenueSearchandOutput.run
    YoutubeSearchandOutput.run
    RunNPRQuery.run
    FlickrSearchandOutput.run
  end
end

# 1. Find an open source data set with information about the food and beverage venues in the Times Square area. Write a script that retrieves that data and outputs a CSV file containing the name, phone number, and address of the pizza restaurants in the data set.

class VenueSearchandOutput

  def self.run
    info = VenueLocationData.new("pizza").food_beverage_times_square
    newCSV = OutputCSV.new(info)
    newCSV.convert_hashdata_to_CSV
  end
end

class VenueLocationData
  attr_accessor :venue_type, :url, :json_data, :pizza_places

  def initialize(venue_type)
    @venue_type = venue_type
  end

  def food_beverage_times_square
    url = "https://data.cityofnewyork.us/api/views/kh2m-kcyz/rows.json?accessType=DOWNLOAD"
    json_result = get_json(url)
    venue_info = get_venues(json_result)
    get_name_phone_address(venue_info)
  end

  def get_json(url)
    data = open(url).read
    JSON.parse(data)
  end

  def get_venues(json_result)
    venues = json_result["data"]
    venues.select do |venue|
     venue.include?(venue_type.capitalize)
    end
  end

  def get_name_phone_address(venues)
    venues.map do |venue|
      address = clean_address(venue[7][40..55])
      [venue[8], venue[11], address]
    end
  end

  def clean_address(string)
    string.gsub("\n", "").tr(%q{"'}, '').strip
  end
end

class OutputCSV
  attr_reader :data_set

  def initialize(data_set)
    @data_set = data_set
  end

  def convert_hashdata_to_CSV
    CSV.open("pizzeria_info.csv", "wb", :write_headers=> true,
    :headers => ["Venue Name","Phone","Address"] ) do |csv|
     self.data_set.to_a.each {|elem| csv << elem}
   end
  end
end

# 2. Find a source of embeddable videos with an API to find the 
# top-rated high-definition videos about pizza. Output an HTML file 
# which embeds these videos and presents them as a grid.

class YoutubeSearchandOutput
  def self.run
    videos = YouTubeConnection.new.get_videos("Pizza")
    EmbedVideotoHTMLPage.new(videos).create_html_page
  end
end

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

  def get_videos(search_term)
    query_result = query(search_term)
    video_ids = get_video_ids(query_result)
    get_pizza_video_urls(video_ids)
  end

  def query(search_term)
    youtube = @client.discovered_api('youtube', 'v3')

    video_search = @client.execute :api_method => youtube.search.list, :parameters => {q: "#{search_term}", part: 'id', type: 'video', chart: "mostPopular"}

    JSON.parse(video_search.data.to_json)
  end

  def get_video_ids(query_result)
    query_result.values[4].map do |video|
      video["id"]["videoId"]
    end
  end

  def get_pizza_video_urls(video_ids)
    video_ids.map do |video_id|
      "https://www.youtube.com/embed/#{video_id}"
    end
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

# 3. Find an API for a source of news, in audio format. 
# Output a file that can be loaded into VLC Media Player 
# to play a series of news stories about pizza.

class RunNPRQuery

  def self.run
    results = NPRQuery.new("pizza").query
    pizza_audio = CreatePlaylist.new(results)
    urls = pizza_audio.get_audio_urls
    pizza_audio.new_playlist(urls)
  end

end

class NPRQuery
  attr_accessor :search_term

  API_KEY = File.read("npr.yml")

  def initialize(search_term)
    @search_term = search_term
  end

  def query
    base_url = "http://api.npr.org/"
    query_url = "#{base_url}query?&requiredAssets=audio&searchTerm=#{self.search_term}&dateType=story&searchType=mainText&output=JSON&apiKey=#{API_KEY}"
    result = open(query_url).read
    JSON.parse(result)
  end
end

class CreatePlaylist
  attr_accessor :json_data

  def initialize(json_data)
    @json_data = json_data
  end

  def get_audio_urls
    self.json_data["list"]["story"].map do |data|
      data["audio"][0]["format"]["mp3"].first["$text"]
    end
  end

  def new_playlist(mp3_urls)
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

# 4. Find an API that can be used to search for Creative Commons 
# licensed images. Write a script that finds and retrieves 20 
# images of pizza and outputs an image file that is a collage of 
# these images.

class FlickrSearchandOutput

  def self.run
    photos = FlickrConnection.new.get_photo_urls
    CreateCollage.new(photos).new_collage
  end
end

class FlickrConnection
  attr_accessor :photos, :urls

  def initialize  
    @flickr = Flickr.new('flickr.yml')
  end

  def get_photo_urls
    self.photos = get_pizza_photos
    get_urls
  end

  def get_pizza_photos
    #need to change per_page to 20 for final submission
    @flickr.photos.search(text: 'pizza',tags: 'pizza', content_type: 1, per_page: 20, license: 6)
  end

  def get_urls
    self.photos.map do |photo|
      photo.url(:small)
    end
  end

end

class CreateCollage
    attr_accessor :photo_urls, :sliced_arrays, :photos_array

  def initialize(photo_urls)
    @photo_urls = photo_urls
  end

  def new_collage
    self.download_imgs
    self.collage_of_imgs
  end

  def download_imgs
    @photos_array = []
    Dir.mkdir("images") unless File.exist?("images")
    @photo_urls.each_with_index do |url, index|
      open(url) {|f|
        File.open("images/pizza_#{index}.jpg","wb") do |file|
            file.puts f.read
            self.photos_array << "images/pizza_#{index}.jpg"
          end
        }
    end
    photos_array
  end

  def collage_of_imgs
    collage = ImageList.new

    sliced_photo_array.each do |array|
      row = create_row_of_images(array)
      collage.push (row.append(false))
    end
    collage.append(true).write("pizza_collage.jpg")
  end

  def sliced_photo_array
    #slices array of photos into subarrays of 4 photos
    self.photos_array.each_slice(4).to_a
  end

  def create_row_of_images(photos_array)
    row = Magick::ImageList.new
    photos_array.each_with_index do |photo, index|
      resize_img(photo, index)
      row.push(Image.read("images/pizza_#{index}.jpg")[0])
    end
    row
  end

  def resize_img(photo, index)
    image = Magick::Image.read(photo)[0]
    resize = image.resize_to_fill(200, 100)
    resize.write("images/pizza_#{index}.jpg")
  end
end

All.run

