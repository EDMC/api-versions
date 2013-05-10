require 'spec_helper'
require 'rack/test'

describe ApiVersions::Middleware do
  let(:app) { ->(env) { [200, { "Content-Type" => "text/plain"}, [env["HTTP_ACCEPT"]]] } }

  before do
    ApiVersions::VersionCheck.vendor_string = "myvendor"
  end

  describe "the accept header" do
    it "should not adjust the header" do
      request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/vnd.foobar+json;version=1", lint: true, fatal: true)
      _, _, response = described_class.new(app).call(request)
      response.first.should == "application/vnd.foobar+json;version=1"
    end

    it "should adjust the header" do
      request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "text/plain,application/vnd.myvendor+json;version=1,text/html,application/vnd.myvendor+xml", lint: true, fatal: true)
      _, _, response = described_class.new(app).call(request)
      response.last.should == "text/plain,application/json,application/vnd.myvendor+json;version=1,text/html,application/xml,application/vnd.myvendor+xml"
    end
  end
end
