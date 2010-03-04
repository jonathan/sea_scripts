require 'spec_helper'

describe "scope_inputs/show.html.erb" do
  before(:each) do
    assign(:scope_input, @scope_input = stub_model(ScopeInput))
  end

  it "renders attributes in <p>" do
    render
  end
end
