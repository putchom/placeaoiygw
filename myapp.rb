require 'sinatra'
require 'rmagick'
require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

get '/' do
  send_file File.join(File.dirname(__FILE__) + '/public', 'index.html')
end

get '/:width/:height' do
  width = params['width'].to_i
  height = params['height'].to_i
  filename = get_image_filename(width, height)
  send_file filename, type: 'image/jpeg', disposition: 'inline'
end

private

def get_image_filename(width, height)
  filename = File.join(File.dirname(__FILE__) + '/images/generated', "#{width}x#{height}.jpg")
  return filename if FileTest.exist?(filename)

  original_filename = get_original_image_urls.sample
  image_original = Magick::Image.read(original_filename).first
  image = image_original.resize_to_fill(width, height)
  image.write(filename)
  filename
end

def get_original_image_urls
  domain = 'yagawaaoi.tumblr.com'
  api_key = ENV['API_KEY']
  json = get_json("https://api.tumblr.com/v2/blog/#{domain}/posts?api_key=#{api_key}")
  response = json['response']
  posts = response['posts']
  original_image_urls = []
  posts.each{ |post|
    original_image_urls.push(
      get_image_src(post['body'])
    )
  }
  original_image_urls
end

def get_json(location)
  uri = URI.parse(location)
  json = Net::HTTP.get(uri)
  result = JSON.parse(json)
  result
end

def get_image_src(body)
  doc = Nokogiri::HTML(body)
  img_srcs = doc.css('img').map{ |i| i['src'] }
  img_src = img_srcs.first
end