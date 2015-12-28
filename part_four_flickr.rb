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
    @flickr.photos.search(text: 'pizza',tags: 'pizza', content_type: 1, per_page: 20)
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
        File.open("pizza_#{index}.jpg","wb") do |file|
            file.puts f.read
            photos_array << "pizza_#{index}.jpg"
          end
        }
    end
    photos_array
  end

  def slice_(photos_array, num)
    photos_array.each_slice(num).to_a
  end

  def collage_of_imgs(sliced_arrays)
    collage = ImageList.new

    sliced_arrays.each do |array|
      row = create_row_of_images(array)
      collage.push (row.append(false))
    end
    collage.append(true).write("pizza_collage.jpg")
  end

  def create_row_of_images(photos_array)
    row = Magick::ImageList.new
    photos_array.each_with_index do |photo, index|
      resize_img(photo, index)
      row.push(Image.read("pizza_#{index}.jpg")[0])
    end
    row
  end

  def resize_img(photo, index)
    image = Magick::Image.read(photo)[0]
    resize = image.resize_to_fill(200, 100)
    resize.write("pizza_#{index}.jpg")
  end

end


x = FlickrConnection.new
y = x.get_photo_urls
z = OutputCompositeImageFile.new(y)
array=z.download_imgs
a= z.slice_(array, 4)
z.collage_of_imgs(a)