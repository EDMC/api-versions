class ErrorsController < ActionController::Base
  def not_found
    render nothing: true, status: 404
  end
end
