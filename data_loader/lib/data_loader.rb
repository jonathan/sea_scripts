# encoding: utf-8

require 'dm-core'
require 'dm-validations'
require 'pathname'

module DataLoader
  autoload :ScopeInput, 'data_loader/scope_input'
  autoload :WaveCoverage, 'data_loader/wave_coverage'
  autoload :ErrorPoint, 'data_loader/error_point'
  
  class << self
    def setup(debug = false)
      DataMapper::Logger.new($stdout, :debug) if debug

      DataMapper.setup(:default, 'postgres://localhost/sea_data')

      ScopeInput.auto_migrate!
      WaveCoverage.auto_migrate!
      ErrorPoint.auto_migrate!
    end

    def process_intercepts(file_name)
      circuit_info = parse_filename(file_name)

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      prev_point = { :voltage => 0.0, :time => 0.0 }
      
      lines.each do |line|
        t, v = line.split(' ')
        t = t.to_f; v = v.to_f

        return if t > 209.5

        if (t > 208.0 && t < 209.12) && (prev_point[:voltage] < 0.0 && v > 0.0)
          intercept = calculate_intercept(prev_point, { :voltage => v, :time => t })
          # 209.12 should be configurable.
          x_intercept = 209.12 - intercept
          WaveCoverage.create(circuit_info.merge({ :x_intercept => x_intercept, :strike_point => 209.12 }))
        end
        prev_point[:voltage] = v
        prev_point[:time] = t
      end
    end
    
    def process_error_points(file_name)
      circuit_info = parse_filename(file_name)

      lines = File.readlines(file_name).map {|l| l.rstrip}[9..-1]

      max = { :voltage => nil, :time => nil, :type => 'MAX' }
      min = { :voltage => nil, :time => nil, :type => 'MIN' }
      prev_voltage = 0.0
      
      lines.each do |line|
        t, v = line.split(' ')
        t = t.to_f; v = v.to_f
        
        next if t < 208.00
        return if t > 211.00

        if (max[:voltage].nil? || v > max[:voltage])
          max[:voltage] = v; max[:time] = t
        end

        if (min[:voltage].nil? || v < min[:voltage])
          min[:voltage] = v; min[:time] = t
        end

        if (prev_voltage < v && point_delta(min, max))
          ErrorPoint.create(circuit_info.merge(max)) if max[:voltage] < 4.01969118249074
          max[:voltage] = max[:time] = nil
        end
        
        if (prev_voltage > v && point_delta(min, max))
          ErrorPoint.create(circuit_info.merge(min)) if min[:voltage] > -4.14416711437404
          min[:voltage] = min[:time] = nil
        end
        prev_voltage = v
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

    def point_delta(min, max)
      time_delta = (min[:time].abs() - max[:time].abs()).abs()
      voltage_delta = (max[:voltage].abs() - min[:voltage].abs()).abs()
      # TODO: the thresholds should be configurable
      time_threshold = 0.4
      voltage_threshold = 2.0
      return (time_delta > time_threshold) && (voltage_delta < voltage_threshold)
    end

    def calculate_intercept(point1, point2)
      slope = (point2[:voltage] - point1[:voltage]) / (point2[:time] - point1[:time])
      b = point2[:voltage] - point2[:time] * slope
      return -b / slope
    end
  end
end