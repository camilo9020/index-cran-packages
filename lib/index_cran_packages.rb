require 'rubygems/package'
require 'net/http'
require 'nokogiri'
require 'csv'
require 'zlib'
require 'stringio'

class IndexCranPackages
  def initialize(cran_server_url, file_name_path)
    @filename = file_name_path
    @package_list_url = cran_server_url
  end

  def execute
    package_links = get_packages_links
    p "Processing #{package_links.count} packages..."
    package_links.each_slice(10) do |batch|
      process_batch_packages(batch)
    end
    p 'Done!'
  end

  def process_batch_packages(batch)
    packages_info = ''

    batch.each do |link|
      package_name, package_version = link.text.split('_')
      p "Processing #{package_name} #{package_version}..."
      description = get_package_description(package_name, link)
      packages_info += parse_package_description(description)
    end

    write_packages_info(packages_info)
  end

  def write_packages_info(packages_info)
    File.open(@filename, 'a') do |file|
      file.write(packages_info)
    end
  end

  def get_packages_links
    uri = URI(@package_list_url)
    response = Net::HTTP.get(uri)
    return [] unless response
    html = Nokogiri::HTML(response)
    html.css('a[href$=".tar.gz"]')
  end

  def get_package_description(package_name, link)
    tar = get_tar_file(link)
    description_entry = tar.find { |entry| entry.full_name == "#{package_name}/DESCRIPTION" }
    tar.close
    Nokogiri::HTML(description_entry.read)
  end

  def get_tar_file(link)
    tar_url = @package_list_url + link.text
    uri = URI(tar_url)
    response = Net::HTTP.get(uri)
    tar_data = StringIO.new(response)
    gz = Zlib::GzipReader.new(tar_data)
    Gem::Package::TarReader.new(gz)
  end

  def parse_package_description(description)
    text_description = description.css('p').text
    pairs = text_description.scan(/(\w+):\s*(.*?)\n/)

    package_data = {}

    pairs.each do |pair|
      package_data[pair[0].downcase.to_sym] = pair[1]
    end

    "name: #{package_data[:package]}\n" \
    "version: #{package_data[:version]}\n" \
    "dependencies: #{package_data[:depends]}\n" \
    "title: #{package_data[:title]}\n" \
    "description: #{package_data[:description]}\n" \
    "authors: #{package_data[:author]}\n" \
    "maintainers: #{package_data[:maintainer]}\n" \
    "license: #{package_data[:license]}\n\n"
  end
end
