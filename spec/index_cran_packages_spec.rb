require 'rspec'
require_relative '../lib/index_cran_packages.rb'
require 'dotenv'

Dotenv.load

RSpec.describe IndexCranPackages do
  let(:file_name_path) { ENV['FILE_NAME_PATH_TEST'] }
  let(:cran_server_url) { ENV['CRAN_SERVER_URL'] }
  subject { described_class.new(cran_server_url, file_name_path) }
  let(:batch) {[subject.get_packages_links.slice(1)] }

  # ideally we should mock get_packages_links and the batch of packages(using a library like webmock/rspec)
  # but I had some issue trying to mock Nokogiri::HTML::Document objects so I decided to use the real ones
  # with more time I would have tried to mock them.

  describe '#get_packages_links' do
    it 'returns an array of package links' do
      expect(subject.send(:get_packages_links)).to all(have_attributes(name: 'a', text: end_with('.tar.gz')))
    end
  end

  describe '#process_batch_packages' do
    it 'processes the batch of packages' do
      subject.process_batch_packages(batch)
      expect(File.exist?(file_name_path)).to be true
      file_content = File.read(file_name_path).split(/\r?\n/)
      expect(file_content[0]).to eq('name: AATtools')
      expect(file_content[1]).to eq('version: 0.0.2')
      expect(file_content[2]).to eq('dependencies: R (>= 3.6.0)')
      expect(file_content[3]).to eq('title: Reliability and Scoring Routines for the Approach-Avoidance Task')
      expect(file_content[4]).to eq('description: Compute approach bias scores using different scoring algorithms,')
      file = File.open(file_name_path, 'r')
      File.delete(file)
    end
  end

  describe '#get_package_description' do
    it 'returns a Nokogiri::HTML object' do
      link = double('link', text: 'A3_1.0.0.tar.gz')
      expect(subject.get_package_description('A3', link)).to be_a(Nokogiri::HTML::Document)
    end
  end
end
