require 'spec_helper'

describe ScopeInputsController do

  def mock_scope_input(stubs={})
    @mock_scope_input ||= mock_model(ScopeInput, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all scope_inputs as @scope_inputs" do
      ScopeInput.stub(:limit).with(10) { [mock_scope_input] }
      get :index
      assigns(:scope_inputs).should eq([mock_scope_input])
    end
  end

  describe "GET show" do
    it "assigns the requested scope_input as @scope_input" do
      ScopeInput.stub(:find).with("37") { mock_scope_input }
      get :show, :id => "37"
      assigns(:scope_input).should be(mock_scope_input)
    end
  end
end