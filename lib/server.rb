require "rubygems"
require "sinatra"
require "json"

def file_to_s(filename)
  return File.new('public/'+filename).readlines.to_s
end

get '/file/:filename' do
  file_to_s(params[:filename])
end

get '/file/unit/:filename' do
  content = file_to_s('unit/'+params[:filename])
  resp = "jQuery('.gonca').append('<div class=\"content\"></div>').find('.content').html(#{content.to_json})"
  #File.open('log.js', 'w') {|f| f.write(resp) }
  resp
end
