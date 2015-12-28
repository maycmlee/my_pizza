require 'rubygems'
require 'open-uri'
require 'json'
require 'pry' 
require 'pp'
require 'csv'

# 1. Find an open source data set with information about the food and beverage venues in the Times Square area. Write a script that retrieves that data and outputs a CSV file containing the name, phone number, and address of the pizza restaurants in the data set.

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


info = VenueLocationData.new("pizza").food_beverage_times_square
newCSV = OutputCSV.new(info)
newCSV.convert_hashdata_to_CSV


# Create a single-file program in Javascript, Ruby, or Objective-C that performs the exercise. Javascript and Ruby codeshould not be platform-specific. Objective-C code samples will be compiled and run on Mac OS X.
# - Feel free to use any third-party libraries you'd like, but don't include them with your submission. You can include a standard package manager configuration (bundler, cocoapods, npm, bower, etc...).
# - Any APIs selected should be either freely usable without authentication, or have an API key that's easy to sign up for. Please don't include any API keys in your submission.
# - Zip the code sample file and any supporting materials and email to sam@mypizza.com. Please include the string “sample code submission” in the subject line. Please also include the time the exercise was begun.


# 3. Find an API for a source of news, in audio format. Output a file that can be loaded into VLC Media Player to play a series of news stories about pizza.

