require 'rubygems'
require 'open-uri'
require 'json'
require 'pry' 
require 'pp'
require 'csv'
require 'google/api_client'
require 'flickr_fu'

# 1. Find an open source data set with information about the food and beverage venues in the Times Square area. Write a script that retrieves that data and outputs a CSV file containing the name, phone number, and address of the pizza restaurants in the data set.

class PizzaLocationData
  attr_accessor :url, :json_data, :pizza_places

  # def initialize(json_url)
  #   @json_url = json_url
  # end

  def food_beverage_times_square
    self.url = "https://data.cityofnewyork.us/api/views/kh2m-kcyz/rows.json?accessType=DOWNLOAD"
    self.json_data = get_json
    self.pizza_places = get_venues
    get_name_phone_address
  end

  private
  def get_json
    data = open(self.url).read
    JSON.parse(data)
  end

  def get_venues
    venues = self.json_data["data"]
    venues.select do |venue|
     venue.include?("Pizza")
    end

  end

  def get_name_phone_address
    self.pizza_places.map do |venue|
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
    CSV.open("pizzeria_info.csv", "wb") {|csv| self.data_set.to_a.each {|elem| csv << elem} }
  end
end


data = PizzaLocationData.new
info = data.food_beverage_times_square
newCSV = OutputCSV.new(info)
newCSV.convert_hashdata_to_CSV


# Create a single-file program in Javascript, Ruby, or Objective-C that performs the exercise. Javascript and Ruby codeshould not be platform-specific. Objective-C code samples will be compiled and run on Mac OS X.
# - Feel free to use any third-party libraries you'd like, but don't include them with your submission. You can include a standard package manager configuration (bundler, cocoapods, npm, bower, etc...).
# - Any APIs selected should be either freely usable without authentication, or have an API key that's easy to sign up for. Please don't include any API keys in your submission.
# - Zip the code sample file and any supporting materials and email to sam@mypizza.com. Please include the string “sample code submission” in the subject line. Please also include the time the exercise was begun.


# 3. Find an API for a source of news, in audio format. Output a file that can be loaded into VLC Media Player to play a series of news stories about pizza.

