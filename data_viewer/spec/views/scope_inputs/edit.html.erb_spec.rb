require 'spec_helper'

describe "scope_inputs/edit.html.erb" do
  before(:each) do
    assign(:scope_input, @scope_input = stub_model(ScopeInput,
      :new_record? => false
    ))
  end

  it "renders the edit scope_input form" do
    render

    response.should have_selector("form", :action => scope_input_path(@scope_input), :method => "post") do |form|
    end
  end
end
