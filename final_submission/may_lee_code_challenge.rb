require_relative 'environment.rb'

class All
  
  def self.run
    VenueSearchandOutput.run
    YoutubeSearchandOutput.run
    RunNPRQuery.run
    FlickrSearchandOutput.run
  end
end

# 1. Find an open source data set with information about the food and beverage 
#  venues in the Times Square area. Write a script that retrieves that data and outputs
# a CSV file containing the name, phone number, and
# address of the pizza restaurants in the data set.

class VenueSearchandOutput

  def self.run
    pizza_venues = CSVAdapter.new("pizza").output_specific_venues
    CSVOutput.new(pizza_venues).output_CSV
  end
end

class CSVAdapter
  attr_accessor :venue_type

  def initialize(venue_type)
    @venue_type = venue_type
  end

  def output_specific_venues
    venues = self.get_specific_venues
    venues.map do |venue|
      address = venue[7][40..55].gsub("\n", "").tr(%q{"'}, '').strip
      Venue.new(venue[8], venue[11], address)
    end
  end

  def get_specific_venues
    all_venues = self.get_json
    all_venues["data"].select do |venue|
      venue.include?(self.venue_type.capitalize)
    end
  end

  def get_json
    url = "https://data.cityofnewyork.us/api/views/kh2m-kcyz/rows.json?accessType=DOWNLOAD"
    venues = open(url).read
    JSON.parse(venues)
  end
end

class Venue
  attr_accessor :restaurant_name, :phone, :address

  def initialize(restaurant_name, phone, address)
    @restaurant_name = restaurant_name 
    @phone = phone 
    @address = address
  end
end

class CSVOutput
  attr_reader :venues
  
  def initialize(venues)
    @venues = venues
  end

  def output_CSV
    venues = self.format_data_for_CSV
    CSV.open("pizzeria_info.csv", "wb", :write_headers=> true,
    :headers => ["Venue Name","Phone","Address"] ) do |csv|
     venues.each {|elem| csv << elem}
   end
  end

  def format_data_for_CSV
    self.venues.map do |venue|
      [venue.restaurant_name, venue.phone, venue.address]      
    end
  end
end

# 2. Find a source of embeddable videos with an API to find the 
# top-rated high-definition videos about pizza. Output an HTML file 
# which embeds these videos and presents them as a grid.

class YoutubeSearchandOutput
  def self.run
    videos = YouTubeSearch.new("pizza").get_videos
    EmbedVideotoHTMLPage.new(videos).create_html_page
  end
end

class YouTubeSearch
  attr_accessor :search_term, :client, :video_search_JSON

  DEVELOPER_KEY = File.read("youtube.yml")

  def initialize(search_term)
    @search_term = search_term
    @client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
    )
  end

  def get_videos
    videos = self.query
    videos["items"].map do |video|
      Video.new(video["id"]["videoId"])
    end
  end

  def query
    youtube = @client.discovered_api('youtube', 'v3')
    video_search = @client.execute :api_method => youtube.search.list, :parameters => {q: "#{self.search_term}", part: 'id', type: 'video', chart: "mostPopular"}
    JSON.parse(video_search.data.to_json)
  end
end

class Video
  attr_reader :video_id

  def initialize(video_id)
    @video_id = video_id
  end

  def url
    "https://www.youtube.com/embed/#{self.video_id}"
  end
end

class EmbedVideotoHTMLPage
  attr_reader :videos

  def initialize(videos)
    @videos = videos
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
    self.videos.map do |video|
      "<iframe title='YouTube video player' width='480' height='390' src=" + video.url + " type='video/mp4'></iframe>"
    end
  end
end

# 3. Find an API for a source of news, in audio format. 
# Output a file that can be loaded into VLC Media Player 
# to play a series of news stories about pizza.

class RunNPRQuery
  def self.run
    pizza_news_audio_array = NPRQuery.new("pizza").get_audio
    Playlist.new(pizza_news_audio_array).create_playlist
  end
end

class NPRQuery
  attr_accessor :search_term

  API_KEY = File.read("npr.yml")

  def initialize(search_term)
    @search_term = search_term
  end

  def get_audio
    audio_array = self.query
    audio_array["list"]["story"].map do |audio|
      Audio.new(audio)
    end
  end

  def query
    base_url = "http://api.npr.org/"
    query_url = "#{base_url}query?&requiredAssets=audio&searchTerm=#{self.search_term}&dateType=story&searchType=mainText&output=JSON&apiKey=#{API_KEY}"
    result = open(query_url).read
    JSON.parse(result)
  end
end

class Audio
  attr_accessor :data
  def initialize(data)
    @data = data
  end

  def url
    self.data["audio"][0]["format"]["mp3"].first["$text"]
  end
end

class Playlist
  attr_accessor :audio_list

  def initialize(audio_list)
    @audio_list = audio_list
  end

  def create_playlist
    file = File.open("pizza_news.m3u", 'w'){ |f|
      f.write("\n")
      self.audio_list.each do |audio|
        f.write("\n")
        f.write("#{audio.url}")
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
    flickr_photos = FlickrSearch.new("pizza").get_photos
    Collage.new(flickr_photos).create_collage
  end
end

class FlickrSearch
  attr_accessor :search_term

  def initialize(search_term)
    @search_term = search_term 
    @flickr = Flickr.new('flickr.yml')
  end

  def get_photos
    flickr_photos = self.query
    flickr_photos.map.with_index do |photo, index|
      PhotoData.new(photo, index)
    end
  end

  def query
    @flickr.photos.search(text: "#{self.search_term}",tags: "#{self.search_term}", content_type: 1, per_page: 20, license: 6)
  end
end

class PhotoData
  attr_accessor :flickr_data, :id

  def initialize(flickr_data, id)
    @flickr_data = flickr_data
    @id = id
  end

  def url
    self.flickr_data.url(:small)
  end
end

class PhotoImage
  attr_accessor :photo_flickr

  def initialize(photo_flickr)
    @photo_flickr = photo_flickr
  end

  def download
    Dir.mkdir("images") unless File.exist?("images")
    open(self.photo_flickr.url) {|f|
      File.open(self.photo_path,"wb") do |file|
          file.puts f.read
        end
      }
  end

  def resize
    image = Magick::Image.read(self.photo_path)[0]
    resize = image.resize_to_fill(200, 100)
    resize.write(self.photo_path)
  end

  def photo_path
    "images/img_#{self.photo_flickr.id}.jpg"
  end
end

class CollageAdapter
  attr_accessor :flickr_photo_objs

  def initialize(flickr_photo_objs)
    @flickr_photo_objs = flickr_photo_objs
  end

  def convert_to_photos
    self.flickr_photo_objs.map do |photo|
      photo_image = PhotoImage.new(photo)
      photo_image.download
      photo_image.resize
      photo_image
    end
  end
end

class CollageRow
  attr_accessor :images_for_row

  def initialize(images_for_row)
    @images_for_row = images_for_row
  end 

  def create_row_for_collage
    row = Magick::ImageList.new
    self.images_for_row.each do |photo|
      row.push(Image.read(photo.photo_path)[0])
    end
    row
  end
end

class Collage
  attr_reader :flickr_photos

  def initialize(flickr_photos)
    @flickr_photos = flickr_photos
  end

  def create_collage
    collage = ImageList.new
    collage_rows = self.get_rows_of_images
    collage_rows.each do |row|
      collage.push (row.append(false))
    end
    collage.append(true).write("pizza_collage.jpg")
  end

  def get_rows_of_images
    images_array = self.get_images
    collage_rows = slice_for_rows(images_array)
    collage_rows.map do |row|
      CollageRow.new(row).create_row_for_collage
    end
  end

  def slice_for_rows(array)
    #To get 4 photos for each collage row, slice array of photos into subarrays of 4 photos
    array.each_slice(4).to_a
  end

  def get_images
    CollageAdapter.new(self.flickr_photos).convert_to_photos
  end
end

All.run

