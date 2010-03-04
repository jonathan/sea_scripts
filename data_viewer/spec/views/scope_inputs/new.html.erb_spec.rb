require 'spec_helper'

describe "scope_inputs/new.html.erb" do
  before(:each) do
    assign(:scope_input, stub_model(ScopeInput,
      :new_record? => true
    ))
  end

  it "renders new scope_input form" do
    render

    response.should have_selector("form", :action => scope_inputs_path, :method => "post") do |form|
    end
  end
end
