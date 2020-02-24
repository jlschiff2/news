require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }  

# enter your Dark Sky API key here
ForecastIO.api_key = "6db4f62deb242d6ae74da3d760af00d6"

get "/" do
    view "app"
end

get "/news" do
    # turn city into lat-long coordinates
    results = Geocoder.search(params["q"])
    @location = params["q"]
    lat_long = results.first.coordinates #=> [lat, long]
    lat = "#{lat_long[0]}"
    long = "#{lat_long[1]}"
    
    # send lat-long to Dark Sky to retrieve weather
    forecast = ForecastIO.forecast("#{lat}","#{long}").to_hash
    @current_temperature = forecast["currently"]["temperature"]
    @current_conditions = forecast["currently"]["summary"]
    @current_icon = forecast["currently"]["icon"]

    # display current weather
    puts "In #{@location}, it is currently #{@current_temperature} and #{@current_conditions}."

    # display weather forecast
    @day = forecast["daily"]["data"]
    for object in @day
    puts "It will be #{object["summary"]} with a high of #{object["temperatureHigh"]}."
    end
        
    # display national headlines
    geocoder_results = Geocoder.search(@location)
    url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=4bd84eb679e949d597951ba41ca8d754"
    news = HTTParty.get(url).parsed_response.to_hash 
    @top_articles = news["articles"]

    view "app_news"
end


# url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=4bd84eb679e949d597951ba41ca8d754"
# news = HTTParty.get(url).parsed_response.to_hash
# news is now a Hash you can pretty print (pp) and parse for your output

# results = Geocoder.search("Evanston, IL")
# results.first.coordinates #=> [42.0574063,-87.6722787]

# get "/news" do
  # do everything else
  #results = Geocoder.search(params["q"])
   # @lat_long = results.first.coordinates => [lat,long]
    #"#{@lat_long[0]} #{@lat_long[1]}"

   
# a loop gets built on an array, not a hash!
# variable made for what the array is, then you can use that to locate the data you need.

    #for day in forecast["daily"]["data"]
    #puts "A high temperature of #{day["temperatureHigh"]} and #{day["summary"]}"
    #end
#end