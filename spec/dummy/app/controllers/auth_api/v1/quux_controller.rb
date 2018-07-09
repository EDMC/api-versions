class AuthApi::V1::QuuxController < ActionController::Base
  def new
    respond_to do |format|
      format.json { render json: {} }
      format.xml  { render xml:  {} }
    end
  end
end
