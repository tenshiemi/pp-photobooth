require 'sinatra'

get '/' do
  haml :index
end

get '/photo_booth' do
  haml :photo_booth, :locals => {:title => params[:title]}
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
