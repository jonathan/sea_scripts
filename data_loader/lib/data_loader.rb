require 'dm-core'
require 'dm-validations'
require 'pathname'

module DataLoader
  autoload :ScopeInput, 'data_loader/scope_input'
  autoload :WaveCoverage, 'data_loader/wave_coverage'
  
  class << self
    def setup(debug = false)
      DataMapper::Logger.new($stdout, :debug) if debug

      DataMapper.setup(:default, 'postgres://localhost/sea_data')

      ScopeInput.auto_migrate!
      WaveCoverage.auto_migrate!
    end

    def process_file(file_name)
      circuit_info = parse_filename(file_name)

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      max = { :voltage => 0.0, :time => 0.0 }
      min = { :voltage => 0.0, :time => 0.0 }
      prev_point = { :voltage => 0.0, :time => 0.0 }
      
      lines.each_with_index do |line, i|
        if i == 0
          max, min, prev_point = bootstrap(line, max, min)
          next
        end
        t, v = line.split(' ')
        t = t.to_f
        v = v.to_f

        if (t > 208.0 && t < 209.12) && (prev_point[:voltage] < 0.0 && v > 0.0)
          intercept = calculate_intercept(prev_point, { :voltage => v, :time => t })
          # 209.12 should be configurable.
          x_intercept = 209.12 - intercept
          WaveCoverage.create(circuit_info.merge({ :x_intercept => x_intercept, :strike_point => 209.12 }))
        end

        if v > max[:voltage] && v > 0.3
          max[:voltage] = v
          max[:time] = t
        end

        if v < min[:voltage] && v < -0.3
          min[:voltage] = v
          min[:time] = t
        end

        if (prev_point[:voltage] < 0.0 && v >= 0.0) || lines.size == i + 1
          ScopeInput.create(circuit_info.merge(min)) if min[:voltage] != 0.0
          min[:voltage] = min[:time] = 0.0
        end

        if (prev_point[:voltage] >= 0.0 && v < 0.0) || lines.size == i + 1
          ScopeInput.create(circuit_info.merge(max)) if max[:voltage] != 0.0
          max[:voltage] = max[:time] = 0.0
        end
        prev_point[:voltage] = v
        prev_point[:time] = t
      end
    end

    def parse_filename(file_name)
      root = Pathname.new(file_name).basename.to_s.gsub(/.txt/, '')
      tokens = root.split('_')

      case tokens.size
        when 4
          { :circuit => tokens[0], :energy => tokens[1],
            :pixel => tokens[2], :scan => tokens[3] }
        when 5
          { :circuit => tokens[0], :energy => tokens[1],
            :pixel => tokens[3], :scan => tokens[4] }
        else
          { }
      end
    end

    def bootstrap(line, max, min)
      t, v = line.split(' ')
      v = v.to_f
      t = t.to_f
      max[:voltage] = v if v >= 0.0
      min[:voltage] = v if v < 0.0
      return max, min, { :voltage => v, :time => t }
    end

    def calculate_intercept(point1, point2)
      slope = (point2[:voltage] - point1[:voltage]) / (point2[:time] - point1[:time])
      b = point2[:voltage] - point2[:time] * slope
      return -b / slope
    end
  end
end