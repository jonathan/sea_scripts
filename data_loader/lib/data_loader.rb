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
      ciruit_info = { 
        :circuit => circuit, :energy => energy,
        :pixel => pixel, :scan => scan
      }

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      first_line = lines.unshift
      t, v = first_line.split(' ')
      
      max = { :voltage => 0.0, :time => 0.0 }
      min = { :voltage => 0.0, :time => 0.0 }

      max[:voltage] = v.to_f if v.to_f >= 0
      min[:voltage] = v.to_f if v.to_f < 0
      prev_volt = v.to_f
      
      lines.each do |line|
        t, v = line.split(' ')
        t = t.to_f
        v = v.to_f

        if v > max[:voltage]
          max[:voltage] = v
          max[:time] = t
        end

        if v < min[:voltage]
          min[:voltage] = v
          min[:time] = t
        end

        if prev_volt < 0.0 && v >= 0.0
          ScopeInput.create(circuit_info.merge(min))
          min[:voltage] = min[:time] = 0.0
        end

        if prev_volt >= 0.0 && v < 0.0
          ScopeInput.create(circuit_info.merge(max))
          max[:voltage] = max[:time] = 0.0
        end
      end
    end
  end
end