require 'rubygems'
require 'open-uri'
require 'pry' 
require 'pp'
require 'flickr_fu'
require 'RMagick'
include Magick


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
    @flickr.photos.search(text: 'pizza',tags: 'pizza', content_type: 1, per_page: 6)
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

  def download_imgs
    photos_array = []
    @photo_urls.each_with_index do |url, index|
      open(url) {|f|
        File.open("pizza#{index}.jpg","wb") do |file|
            file.puts f.read
            photos_array << "pizza#{index}.jpg"
          end
        }
    end
    photos_array
  end

  def slice_(photos_array)
    photos_array.each_slice(3).to_a
  end

  def output_composite_img #(photos_array)

   # this will be the final image
    collage = ImageList.new
   #this is an image containing first row of images
    first_row = Magick::ImageList.new
    #this is an image containing second row of images
    second_row = Magick::ImageList.new

    #adding images to the first row (Image.read returns an Array, this is why .first is needed)
    first_row.push(Image.read("pizza0.jpg").first)
    first_row.push(Image.read("pizza1.jpg").first)
    first_row.push(Image.read("pizza2.jpg").first)
    #adding first row to big image and specify that we want images in first row to be appended in a single image on the same row - argument false on append does that
    collage.push (first_row.append(false))
    collage.append(true).write("big_image.jpg")
  end

  def create_row_of_images(array)
    row = Magick::ImageList.new
  end

end


x = FlickrConnection.new
y = x.get_photo_urls
z = OutputCompositeImageFile.new(y)
array=z.download_imgs
pp z.slice_(array)
z.output_composite_img