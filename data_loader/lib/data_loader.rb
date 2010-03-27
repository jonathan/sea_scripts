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
      circuit_info = { 
        :circuit => circuit, :energy => energy,
        :pixel => pixel, :scan => scan
      }

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      max = { :voltage => 0.0, :time => 0.0 }
      min = { :voltage => 0.0, :time => 0.0 }
      prev_volt = 0.0
      
      lines.each_with_index do |line, i|
        if i == 0
          max, min, prev_volt = bootstrap(line, max, min)
          next
        end
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

        if (prev_volt < 0.0 && v >= 0.0) || lines.size == i + 1
          ScopeInput.create(circuit_info.merge(min)) if min[:voltage] != 0.0
          min[:voltage] = min[:time] = 0.0
        end

        if (prev_volt >= 0.0 && v < 0.0) || lines.size == i + 1
          ScopeInput.create(circuit_info.merge(max)) if max[:voltage] != 0.0
          max[:voltage] = max[:time] = 0.0
        end
        prev_volt = v
      end
    end
    
    def bootstrap(line, max, min)
      t, v = line.split(' ')
      v = v.to_f
      max[:voltage] = v if v >= 0.0
      min[:voltage] = v if v < 0.0
      return max, min, v
    end
  end
end