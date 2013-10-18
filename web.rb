require 'sinatra'
require 'twitter'
require 'aws-sdk'
require 'base64'

enable :sessions
set :session_secret, 'pp secret session'

get '/' do
  haml :index
end

get '/photo_booth' do
  haml :photo_booth, :locals => {:title => params[:title]}
end

post '/photo_booth' do
  redirect '/' if params[:name].empty?
  session[:name] = params[:name]
  session[:twitter] = params[:twitter]
  haml :photo_booth, :locals => {:title => params[:title]}
end

post '/save' do
  Twitter.configure do |config|
    config.consumer_key = '49sIHBtAXKoNaUiftyaQ'
    config.consumer_secret = 'NgrDUmUS3QBed1TRR9XZqM2Km8xuRsnnqAOt2dcoJ4'
    config.oauth_token = '1623270049-T1n1RgSdYd5XvHPAynt0naAbKSWaVW2pQdt64PJ'
    config.oauth_token_secret = 'Ga6hOEra4iW4JgSF6wBI5kot7BFp898Yggg1IcvATjQ'
  end

  logger.info ENV['S3_BUCKET_NAME']
  logger.info ENV['AWS_ACCESS_KEY_ID']
  logger.info ENV['AWS_SECRET_ACCESS_KEY']

  File.open(session[:name], 'wb') do|f|
    f.write(Base64.decode64(params[:base64]))
  end

  Twitter.update("Welcome to Paperless Post, #{session[:name]} @#{session[:twitter]}") unless session[:twitter].empty?
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
