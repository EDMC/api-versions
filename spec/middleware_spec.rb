require 'spec_helper'
require 'rack/test'

describe ApiVersions::Middleware do
  let(:app) { ->(env) { [200, { "Content-Type" => "text/plain" }, [env["HTTP_ACCEPT"]]] } }

  around do |example|
    original = ApiVersions::VersionCheck.vendor_string
    ApiVersions::VersionCheck.vendor_string = "myvendor"
    example.run
    ApiVersions::VersionCheck.vendor_string = original
  end

  describe "the accept header" do
    it "should not adjust the header" do
      request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/vnd.foobar+json;version=1", lint: true, fatal: true)
      response = described_class.new(app).call(request).last
      response.first.should == "application/vnd.foobar+json;version=1"
    end

    it "should adjust the header" do
      request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "text/plain,application/vnd.myvendor+json;version=1,text/html,application/vnd.myvendor+xml", lint: true, fatal: true)
      response = described_class.new(app).call(request).last
      response.last.should == "text/plain,application/json,application/vnd.myvendor+json;version=1,text/html,application/xml,application/vnd.myvendor+xml"
    end

    it "should tolerate a nil Accept header" do
      request = Rack::MockRequest.env_for("/", lint: true, fatal: true)
      response = described_class.new(app).call(request).last
      response.last.should_not be
    end

    it "should tolerate an empty Accept header" do
      request = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => '', lint: true, fatal: true)
      response = described_class.new(app).call(request).last
      response.last.should == ""
    end
  end
end
