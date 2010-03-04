class ScopeInputsController < InheritedResources::Base
  actions :index, :show
  respond_to :html, :json

  protected
    def collection
      @scope_inputs = ScopeInput.limit(10)
    end
end