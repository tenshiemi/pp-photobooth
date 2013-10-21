require 'sinatra'
require 'twitter'
require 'aws-sdk'
require 'base64'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN

s3 = AWS::S3.new(
  :access_key_id => 'AKIAJCZJCPRZO5FDCUCA',
  :secret_access_key => '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'
)

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


  bucket = s3.buckets['photobooth.s3.paperlesspost.net']

  if bucket.exists?
    data_url = params[:base64]
    data_only = data_url[ /(?<=,).+/ ]

    now = DateTime.now.strftime('%Y%m%dT%H%M')
    filename = session[:name] + now + '.png'

    file = File.open(filename, 'wb')
    file.write(Base64.decode64(data_only))
    file.close
    file = File.open(filename, 'rb')

    obj = bucket.objects[filename]
    obj.write(file)

    url = obj.public_url.to_s

    tweet = "Welcome to Paperless Post, #{session[:name]} " + (session[:twitter].empty? ? '' @: session[:twitter]) + " #{url}"
    Twitter.update(tweet)
    redirect '/'
  else
    return "An Error Occurred :("
  end
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
