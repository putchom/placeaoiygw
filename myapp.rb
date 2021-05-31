require 'sinatra'
require 'rmagick'

set :public_folder, File.dirname(__FILE__) + '/public'
set :generated_images_folder, File.dirname(__FILE__) + '/images/generated'
set :images_folder, File.dirname(__FILE__) + '/images/source'

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/:width/:height' do
  width = params['width'].to_i
  height = params['height'].to_i
  return_image(width, height)
end

private

def return_image(width, height)
  filename = get_image_filename(width, height)
  send_file filename, type: 'image/jpeg', disposition: 'inline'
end

def get_image_filename(width, height)
  filename = File.join(settings.generated_images_folder, "#{width}x#{height}.jpg")
  return filename if FileTest.exist?(filename)

  original_filename = Dir.glob(File.join(settings.images_folder, '*.*')).sample
  image_original = Magick::Image.read(original_filename).first
  image = image_original.resize_to_fill(width, height)
  image.write(filename)
  filename
end