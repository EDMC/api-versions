class ErrorsController < ActionController::Base
  def not_found
    head :not_found
  end
end
