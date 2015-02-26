require 'sinatra'
require 'twitter'
require 'aws-sdk'
require 'base64'
require 'logger'
require "sinatra/config_file"

config_file 'config.yml'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN

s3 = AWS::S3.new(
  :access_key_id => AWS_KEY,
  :secret_access_key => AWS_SECRET,
  :region => 'us-east-1'
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
  session[:title] = params[:title]
  haml :photo_booth, :locals => {:title => params[:title]}
end

post '/save' do
  Twitter.configure do |config|
    config.consumer_key = TWITTER_CONSUMER_KEY
    config.consumer_secret = TWITTER_CONSUMER_SECRET
    config.oauth_token = OAUTH_CONSUMER_KEY
    config.oauth_token_secret = OAUTH_CONSUMER_SECRET
  end


  bucket = s3.buckets['apportable-photobooth']

  if bucket.exists?
    data_url = params[:base64]
    data_only = data_url[ /(?<=,).+/ ]

    now = DateTime.now.strftime('%Y%m%dT%H%M%S')
    filename = session[:name] + now + '.png'

    file = File.open(filename, 'wb')
    file.write(Base64.decode64(data_only))
    file.close
    file = File.open(filename, 'rb')

    obj = bucket.objects[filename]
    obj.write(file)

    url = obj.public_url.to_s

    tweet = "Welcome to Apportable, #{session[:name]} " + (session[:twitter].empty? ? '' : '@'+session[:twitter]) + " #{session[:title]} #{url}"
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
