require 'sinatra'
require 'twitter'

enable :sessions
set :session_secret, 'pp secret session'

get '/' do
  haml :index
end

get '/photo_booth' do
  haml :photo_booth, :locals => {:title => params[:title]}
end

post '/photo_booth' do
  session[:name] = params[:name]
  session[:twitter] = params[:twitter]
  haml :photo_booth, :locals => {:title => params[:title]}
end

get '/save' do
  Twitter.configure do |config|
    config.consumer_key = '49sIHBtAXKoNaUiftyaQ'
    config.consumer_secret = 'NgrDUmUS3QBed1TRR9XZqM2Km8xuRsnnqAOt2dcoJ4'
    config.oauth_token = '1623270049-T1n1RgSdYd5XvHPAynt0naAbKSWaVW2pQdt64PJ'
    config.oauth_token_secret = 'Ga6hOEra4iW4JgSF6wBI5kot7BFp898Yggg1IcvATjQ'
  end

  Twitter.update("Welcome to Paperless Post, #{session[:name]} #{session[:twitter]}");
  redirect '/'
end

get '/js/*.*' do
  send_file 'js/'+params[:splat].join('.')
end

get '/images/*.*' do
  send_file 'images/'+params[:splat].join('.')
end

get '/css/*.*' do
  send_file 'css/'+params[:splat].join('.')
end
