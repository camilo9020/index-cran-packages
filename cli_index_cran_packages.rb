require './lib/index_cran_packages.rb'
require 'dotenv'

Dotenv.load

index_cran_packages = IndexCranPackages.new(ENV['CRAN_SERVER_URL'], ENV['FILE_NAME_PATH'])
index_cran_packages.execute
