require 'spec_helper'

class ApplicationController < ActionController::Base
  include ApiVersions::SimplifyFormat

  def index
    render nothing: true, status: 200
  end
end

describe ApplicationController do
  describe "simplify format" do
    it "should set the format" do
      request.env['Accept'] = 'application/vnd.myvendor+json;version=1'
      get :index
      request.format.should == 'application/json'
    end
  end

  context "when the header is not set" do
    it "should be successful" do
      get :index
      response.should be_success
    end

    it "should not change the format" do
      get :index
      request.format.should == "text/html"
    end
  end
end
