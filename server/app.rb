# app.rb
ENV['RACK_ENV'] ||= 'development'
 
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym


require 'sinatra'
require 'rest-client'
require 'json'
require 'twilio-ruby'
require 'data_mapper'
require File.dirname(__FILE__) + '/model.rb'

before do
    content_type 'application/json'
end

set :bind, '0.0.0.0'
set :port, 9494  

def sendcode(number,code)
    # put your own credentials here 
    account_sid = 'AC66e5bf0268a022039ae5e46db4b30356' 
    auth_token = '07573bd8292ae07dd1f7e186c3e86b32' 
 
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new account_sid, auth_token 
 
    @client.account.messages.create({
      :from => '+15615315542', 
      :to => "#{number}", 
      :body => "Please enter the following code #{code}",  
    })
end

get '/' do
    "root page"
end
  
get '/version' do
    "flightapi 0.1"
end
  
get '/flightstatnearbyairport' do
    appid = "816afdf3"
    appkey = "5131ea27d6454d7d0cc72c133ee954c2"
    # long = "#{params[:long]}"
    # lat = "#{params[:lat]}"
    long = "-80"
    lat = "25"
    url = "https://api.flightstats.com/flex/airports/rest/v1/json/withinRadius/#{long}/#{lat}/30?appId=#{appid}&appKey=#{appkey}"
    "https://api.flightstats.com/flex/airports/rest/v1/json/withinRadius/#{long}/#{lat}/30?appId=#{appid}&appKey=#{appkey}"
    response = RestClient.get(url)
  	result = JSON.parse(response.body)
  	result.to_json
end
  
get '/nearbyairport' do
    long1 = params[:long].to_f+0.5
    long2 = params[:long].to_f-0.5
    lat1 = params[:lat].to_f+0.5
    lat2 = params[:lat].to_f-0.5
    airportinf = Airportinfo.all(:latitude_deg.gt => lat2, :latitude_deg.lt => lat1, :longitude_deg.gt => long2, :longitude_deg.lt => long1, :iata_code.not => "")
    airportinf.to_json(:only => [:iata_code, :name])
end
  
get '/registration' do
    phone = "#{params[:number]}"
    code = Random.new.rand(1000..9999)
    sendcode("#{phone}","#{code}")   
end
  
get '/airportinfo' do
    iata = "#{params[:iata]}"
    airport = Airportinfo.first(:iata_code => iata)
    airport.to_json(:only => [:iata_code, :name])
end

