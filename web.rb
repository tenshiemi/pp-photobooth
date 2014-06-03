require 'sinatra'
require 'twitter'
require 'aws-sdk'
require 'base64'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN

s3 = AWS::S3.new(
  :access_key_id => '',
  :secret_access_key => ''
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
    config.consumer_key = ''
    config.consumer_secret = ''
    config.oauth_token = ''
    config.oauth_token_secret = ''
  end


  bucket = s3.buckets['photobooth.s3.paperlesspost.net']

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

<<<<<<< HEAD
    tweet = "Welcome to Paperless Post, #{session[:name]} " + (session[:twitter].empty? ? '' : session[:twitter]) + " #{url}"
=======
    tweet = "Welcome to Paperless Post, #{session[:name]} " + (session[:twitter].empty? ? '' : '@'+session[:twitter]) + " #{session[:title]} #{url}"
>>>>>>> b6c58440820863f34e9796465ecfa42935982798
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
