#!/usr/bin/env ruby

require 'rubygems'

$:.unshift('./lib')
require 'data_loader'

DataLoader.setup()

dir = './data'
Dir.glob(dir + '/*.txt') do |file_name|
  DataLoader::process_file(file_name)
end
