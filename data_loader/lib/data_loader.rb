require 'dm-core'
require 'dm-validations'
require 'pathname'

module DataLoader
  autoload :ScopeInput, 'data_loader/scope_input'
  
  class << self
    def setup(debug = false)
      DataMapper::Logger.new($stdout, :debug) if debug

      DataMapper.setup(:default, 'postgres://localhost/sea_data')

      ScopeInput.auto_migrate!
    end

    def process_file(file_name)
      root = Pathname.new(file_name).basename.to_s.gsub(/.txt/, '')
      circuit, energy, pixel, scan = root.split('_')

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      lines.each do |line|
        t, v = line.split(' ')
        ScopeInput.create(
          :circuit => circuit,
          :time => t.to_f, 
          :voltage => v.to_f,
          :energy => energy,
          :pixel => pixel,
          :scan => scan)
      end
    end
  end
end