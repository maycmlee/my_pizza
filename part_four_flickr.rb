require 'rubygems'
require 'open-uri'
require 'pry' 
require 'pp'
require 'flickr_fu'
require 'mini_magick'


# 4. Find an API that can be used to search for Creative Commons 
# licensed images. Write a script that finds and retrieves 20 
# images of pizza and outputs an image file that is a collage of 
# these images.

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
    @flickr.photos.search(text: 'pizza',tags: 'pizza', content_type: 1, per_page: 2)
  end

  def get_urls
    self.photos.map do |photo|
      photo.url(:small)
    end
  end

end

class OutputCompositeImageFile

  def initialize(photo_urls)
    @photo_urls = photo_urls
  end

  def download_img
    @photo_urls.each_with_index do |url, index|
      open(url) {|f|
        File.open("pizza#{index}.jpg","wb") do |file|
            file.puts f.read
          end
        }
    end
  end

  def output_composite_img
  #   puts @photo_collection
  #   File.open("pizza_images.jpg",'wb') do |f|
  #     @photo_collection.each do |photo|
  #       binding.pry
  #       f.write photo.read
  #     end
  #   end
  end

end


x = FlickrConnection.new
y = x.get_photo_urls
z = OutputCompositeImageFile.new(y)
z.download_img