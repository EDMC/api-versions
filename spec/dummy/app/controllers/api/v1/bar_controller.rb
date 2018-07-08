class Api::V1::BarController < ActionController::Base
  def new
    respond_to do |format|
      format.json { render json: {} }
      format.xml  { render xml:  {} }
    end
  end
end
