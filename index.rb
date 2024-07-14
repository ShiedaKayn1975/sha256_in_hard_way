require 'open-uri'
require 'fileutils'
require 'pry'
require './sha256'
require './helpers'


def main image_url
  print("Encoding SHA256\n")
  file_path = download_image(image_url)
  binary_content = convert_file_into_binary(file_path)
  sha256_string = Sha256.new(binary_content).hash()

  print("Getting first 10 characters\n")
  first_10_characters = get_first_10_characters(sha256_string)

  base_10 = convert_to_base_10(first_10_characters)
  print("Result is #{base_10}")
  return base_10
end

main(IMAGE_URL)