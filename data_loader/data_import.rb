#!/usr/bin/env ruby

require 'rubygems'

$:.unshift('./lib')
require 'data_loader'

DataLoader.setup()

dir = './data/'
dir = ARGV[0] if ARGV[0]

Dir.glob(dir + '*.txt') do |file_name|
  DataLoader::process_file(file_name)
end
