$:.unshift File.expand_path('../../lib', __FILE__)

require 'data_loader'
require 'dm-aggregates'
require 'pathname'

describe "DataLoader" do
  before(:all) do
    DataMapper.setup(:default, 'postgres://localhost/sea_data_test')
    DataLoader::ScopeInput.auto_migrate!
    DataLoader::WaveCoverage.auto_migrate!
    DataLoader::ErrorPoint.auto_migrate!
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

  context "calculate intercept" do
    before(:each) do
      @point1 = { :voltage => -0.24219, :time => 208.7 }
      @point2 = { :voltage => 0.3, :time => 208.72 }
      @strike_point = 209.12
    end

    it "should calculte an x-intercept of 208.719" do
      DataLoader::calculate_intercept(@point1, @point2).should be_close(208.708933768605, 0.001)
    end
    
    it "should equal the strike point minus the intercept" do
      intercept = DataLoader::calculate_intercept(@point1, @point2)
      (@strike_point - intercept).should be_close(0.411066231394898, 0.001)
    end
  end

  context "wave coverage" do
    it "should have 1 x-intercept" do
      data_file = File.expand_path('./specs/spec_data/t3t34_high_a_1000_avg1.txt')
      DataLoader::process_intercepts(data_file)
      DataLoader::WaveCoverage.count.should eq(1)
      DataLoader::WaveCoverage.first.x_intercept.should be_close(0.411066231394898, 0.001)
    end
  end

  context "error points" do
    it "should have 1 error" do
      data_file = File.expand_path('./specs/spec_data/t3t33_high_1003_avg1.txt')
      DataLoader::process_error_points(data_file)
      DataLoader::ErrorPoint.count.should eq(1)
    end
  end

  context "ugly error points" do
    it "should have 3 errors" do
      data_file = File.expand_path('./specs/spec_data/pos_1225.txt')
      DataLoader::process_ugly_error_points(data_file)
      DataLoader::ErrorPoint.count(:energy.eql => 'pos').should eq(24)
    end
  end

  context "point delta" do
    it "should return 'true' if the time/voltage deltas pass the thresholds" do
      min = { :time => 209.0, :voltage => -2.0 }
      max = { :time => 209.42, :voltage => 2.0 }
      DataLoader::point_delta(min, max).should be_true
    end

    it "should return 'false' if the time/voltage deltas don't pass the thresholds" do
      min = { :time => 209.0, :voltage => -1.0 }
      max = { :time => 209.3, :voltage => 1.0 }
      DataLoader::point_delta(min, max).should be_false
    end
  end
end