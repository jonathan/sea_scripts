require 'spec_helper'

describe ScopeInputsController do

  def mock_scope_input(stubs={})
    @mock_scope_input ||= mock_model(ScopeInput, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all scope_inputs as @scope_inputs" do
      ScopeInput.stub(:all) { [mock_scope_input] }
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

  describe "GET new" do
    it "assigns a new scope_input as @scope_input" do
      ScopeInput.stub(:new) { mock_scope_input }
      get :new
      assigns(:scope_input).should be(mock_scope_input)
    end
  end

  describe "GET edit" do
    it "assigns the requested scope_input as @scope_input" do
      ScopeInput.stub(:find).with("37") { mock_scope_input }
      get :edit, :id => "37"
      assigns(:scope_input).should be(mock_scope_input)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created scope_input as @scope_input" do
        ScopeInput.stub(:new).with({'these' => 'params'}) { mock_scope_input(:save => true) }
        post :create, :scope_input => {'these' => 'params'}
        assigns(:scope_input).should be(mock_scope_input)
      end

      it "redirects to the created scope_input" do
        ScopeInput.stub(:new) { mock_scope_input(:save => true) }
        post :create, :scope_input => {}
        response.should redirect_to(scope_input_url(mock_scope_input))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved scope_input as @scope_input" do
        ScopeInput.stub(:new).with({'these' => 'params'}) { mock_scope_input(:save => false) }
        post :create, :scope_input => {'these' => 'params'}
        assigns(:scope_input).should be(mock_scope_input)
      end

      it "re-renders the 'new' template" do
        ScopeInput.stub(:new) { mock_scope_input(:save => false) }
        post :create, :scope_input => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested scope_input" do
        ScopeInput.should_receive(:find).with("37") { mock_scope_input }
        mock_scope_input.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :scope_input => {'these' => 'params'}
      end

      it "assigns the requested scope_input as @scope_input" do
        ScopeInput.stub(:find) { mock_scope_input(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:scope_input).should be(mock_scope_input)
      end

      it "redirects to the scope_input" do
        ScopeInput.stub(:find) { mock_scope_input(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(scope_input_url(mock_scope_input))
      end
    end

    describe "with invalid params" do
      it "assigns the scope_input as @scope_input" do
        ScopeInput.stub(:find) { mock_scope_input(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:scope_input).should be(mock_scope_input)
      end

      it "re-renders the 'edit' template" do
        ScopeInput.stub(:find) { mock_scope_input(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested scope_input" do
      ScopeInput.should_receive(:find).with("37") { mock_scope_input }
      mock_scope_input.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the scope_inputs list" do
      ScopeInput.stub(:find) { mock_scope_input(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(scope_inputs_url)
    end
  end

end
