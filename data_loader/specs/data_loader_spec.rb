$:.unshift('./lib')
require 'data_loader'

describe "DataLoader" do
  before(:all) do
    DataMapper.setup(:default, 'postgres://localhost/sea_data_test')
    ScopeInput.auto_migrate!
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

  it "loads in 6 data points" do
    data_file = './spec_data/t3t33_high_1000_avg1.txt'
    DataLoader::process_file(data_file)
  end
end
