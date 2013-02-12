require 'spec_helper'

class SimplifiedFormat < ActionController::Base
  include ApiVersions::SimplifyFormat

  def index
    render nothing: true, status: 200
  end
end

describe SimplifiedFormat do
  describe "simplify format" do
    after { request.format.should == 'application/json' }

    it "should set the format" do
      request.env['Accept'] = 'application/vnd.myvendor+json;version=1'
      get :index
    end

    it "should set the format when there is no version specified" do
      request.env['Accept'] = 'application/vnd.myvendor+json'
      get :index
    end

    it "should set the format with spaces" do
      request.env['Accept'] = 'application/vnd.myvendor + json ; version = 1'
      get :index
    end

    it "should set the format with spaces and no version" do
      request.env['Accept'] = 'application/vnd.myvendor + json'
      get :index
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
