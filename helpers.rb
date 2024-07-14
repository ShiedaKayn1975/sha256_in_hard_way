require 'open-uri'
require 'fileutils'
require 'pry'
require './constants'


def download_image(url, file_path = DEFAULT_IMAGE_PATH)
  begin
    dir = File.dirname(file_path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    
    # Open the URL and save the image
    URI.open(url) do |image|
      File.open(file_path, 'wb') do |file|
        file.write(image.read)
      end
    end
    
    puts "Image downloaded successfully to #{file_path}"

    return file_path
  rescue => e
    puts "Failed to download image: #{e.message}"
  end
end

def convert_file_into_binary file_path
  begin
    binary_content = File.open(file_path, 'rb') { |file| file.read }
    binary_content = binary_content.unpack('B*').first

    puts "Image converted to binary successfully"

    return binary_content
  rescue => e
    puts "Failed to convert image to binary: #{e.message}"
    return nil
  end
end

def get_first_10_characters string
  string[0, 10]
end

def convert_to_base_10 string
  string.to_i(16)
end