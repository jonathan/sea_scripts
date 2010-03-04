require 'spec_helper'

describe "scope_inputs/index.html.erb" do
  before(:each) do
    assign(:scope_inputs, [
      stub_model(ScopeInput),
      stub_model(ScopeInput)
    ])
  end

  it "renders a list of scope_inputs" do
    render
  end
end
