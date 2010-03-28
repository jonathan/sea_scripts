$:.unshift File.expand_path('../../lib', __FILE__)

require 'data_loader'
require 'dm-aggregates'
require 'pathname'

describe "DataLoader" do
  before(:all) do
    DataMapper.setup(:default, 'postgres://localhost/sea_data_test')
    DataLoader::ScopeInput.auto_migrate!
    DataLoader::WaveCoverage.auto_migrate!
  end

  before(:each) do
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end
  
  after(:each) do
    repository(:default) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end

  context "parse filename" do
    it "returns a hash of circuit info" do
      without_a = 't3t34_high_1000_avg1.txt'
      root = Pathname.new(without_a).basename.to_s.gsub(/.txt/, '')
      circuit, energy, pixel, scan = root.split('_')
      circuit_info = DataLoader::parse_filename(without_a)
      circuit_info[:circuit].should eq(circuit)
      circuit_info[:energy].should eq(energy)
      circuit_info[:pixel].should eq(pixel)
      circuit_info[:scan].should eq(scan)
    end

    it "returns a hash of circuit info that doesn't include the 'a'" do
      with_a = 't3t34_high_a_1000_avg1.txt'
      root = Pathname.new(with_a).basename.to_s.gsub(/.txt/, '')
      circuit, energy, _, pixel, scan = root.split('_')
      circuit_info = DataLoader::parse_filename(with_a)
      circuit_info[:circuit].should eq(circuit)
      circuit_info[:energy].should eq(energy)
      circuit_info[:pixel].should eq(pixel)
      circuit_info[:scan].should eq(scan)
    end
  end

  context "bootstrap" do
    before(:each) do
      @max = { :voltage => 0.0, :time => 0.0 }
      @min = { :voltage => 0.0, :time => 0.0 }
      @prev_point = { :voltage => 0.0, :time => 0.0 }
    end

    it "sets the max voltage to v if it is higher than 0.0" do
      v = 1.0
      t = 2.0
      line = [t.to_s, v.to_s].join(' ')
      @max, @min, @prev_point = DataLoader::bootstrap(line, @max, @min)
      @max[:voltage].should eq(v)
      @prev_point[:voltage].should eq(v)
      @prev_point[:time].should eq(t)
    end

    it "sets the max voltage to v if it is equal to 0.0" do
      v = 0.0
      t = 2.0
      line = [t.to_s, v.to_s].join(' ')
      @max, @min, @prev_point = DataLoader::bootstrap(line, @max, @min)
      @max[:voltage].should eq(v)
      @prev_point[:voltage].should eq(v)
      @prev_point[:time].should eq(t)
    end

    it "sets the min voltage to v if it is lower than 0.0" do
      v = -1.0
      t = 2.0
      line = [t.to_s, v.to_s].join(' ')
      @max, @min, @prev_point = DataLoader::bootstrap(line, @max, @min)
      @min[:voltage].should eq(v)
      @prev_point[:voltage].should eq(v)
      @prev_point[:time].should eq(t)
    end
  end

  context "calculate intercept" do
    before(:each) do
      @point1 = { :voltage => -0.24219, :time => 208.7 }
      @point2 = { :voltage => 0.3, :time => 208.72 }
      @strike_point = 209.12
    end

    it "should calculte an x-intercept of 208.719" do
      # DataLoader::calculate_intercept(@point1, @point2).should eq(208.719)
      DataLoader::calculate_intercept(@point1, @point2).should be_close(208.708933768605, 0.001)
    end
    
    it "should equal the strike point minus the intercept" do
      intercept = DataLoader::calculate_intercept(@point1, @point2)
      # (@strike_point - intercept).should be_close(0.401, 0.001)
      (@strike_point - intercept).should be_close(0.411066231394898, 0.001)
    end
  end

  context "scope inputs" do
    it "loads in 6 data points" do
      data_file = File.expand_path('./specs/spec_data/t3t33_high_a_1000_avg1.txt')
      DataLoader::process_file(data_file)
      DataLoader::ScopeInput.count.should eq(6)
    end
  end

  context "wave coverage" do
    it "should have 1 x-intercept" do
      data_file = File.expand_path('./specs/spec_data/t3t34_high_a_1000_avg1.txt')
      DataLoader::process_file(data_file)
      DataLoader::WaveCoverage.count.should eq(1)
      # DataLoader::WaveCoverage.first.x_intercept.should be_close(0.401, 0.001)
      DataLoader::WaveCoverage.first.x_intercept.should be_close(0.411066231394898, 0.001)
    end
  end
end