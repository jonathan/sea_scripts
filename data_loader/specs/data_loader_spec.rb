$:.unshift File.expand_path('../../lib', __FILE__)

require 'data_loader'
require 'dm-aggregates'

describe "DataLoader" do
  before(:all) do
    DataMapper.setup(:default, 'postgres://localhost/sea_data_test')
    DataLoader::ScopeInput.auto_migrate!
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

  context "bootstrap" do
    before(:each) do
      @max = { :voltage => 0.0, :time => 0.0 }
      @min = { :voltage => 0.0, :time => 0.0 }
      @prev_volt = 0.0
    end

    it "sets the max voltage to v if it is higher than 0.0" do
      v = 1.0
      line = '2.0 ' + v.to_s
      @max, @min, @prev_volt = DataLoader::bootstrap(line, @max, @min)
      @max[:voltage].should eq(v)
      @prev_volt.should eq(v)
    end

    it "sets the max voltage to v if it is equal to 0.0" do
      v = 0.0
      line = '2.0 ' + v.to_s
      @max, @min, @prev_volt = DataLoader::bootstrap(line, @max, @min)
      @max[:voltage].should eq(v)
      @prev_volt.should eq(v)
    end

    it "sets the min voltage to v if it is lower than 0.0" do
      v = -1.0
      line = '2.0 ' + v.to_s
      @max, @min, @prev_volt = DataLoader::bootstrap(line, @max, @min)
      @min[:voltage].should eq(v)
      @prev_volt.should eq(v)
    end
  end

  it "loads in 6 data points" do
    data_file = File.expand_path('./specs/spec_data/t3t33_high_1000_avg1.txt')
    DataLoader::process_file(data_file)
    DataLoader::ScopeInput.count.should eq(6)
  end
end
