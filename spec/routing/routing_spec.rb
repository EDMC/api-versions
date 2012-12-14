require 'spec_helper'

describe 'API Routing' do
  def merge_and_stub(path, method, hash)
    env_hash = Rack::MockRequest.env_for(path, method: method).merge(hash)
    Rack::MockRequest.stub(:env_for).and_return env_hash
  end

  describe "V1" do
    context "when no header is set" do
      it "doesn't route" do
        expect(get: new_api_bar_path).to_not be_routable
      end
    end

    context "when the header is set incorrectly" do
      it "doesn't route" do
        merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.mybadvendor+json;version=1'
        expect(get: '/api/bar/new').to_not be_routable
      end
    end

    context "when it is set correctly" do
      it "should not route something from V2" do
        merge_and_stub new_api_foo_path, 'get', 'Accept' => 'application/vnd.myvendor+json;version=1'
        expect(get: new_api_foo_path).to_not be_routable
      end

      it "should route" do
        merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json;version=1'
        expect(get: new_api_bar_path).to route_to(controller: 'api/v1/bar', action: 'new')
      end

      it "should default" do
        merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json'
        expect(get: new_api_bar_path).to route_to(controller: 'api/v1/bar', action: 'new')
      end

      it "should default with nothing after the semi-colon" do
        merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json; '
        expect(get: new_api_bar_path).to route_to(controller: 'api/v1/bar', action: 'new')
      end
    end
  end

  describe "V2" do
    it "should copy bar" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json;version=2'
      expect(get: new_api_bar_path).to route_to(controller: 'api/v2/bar', action: 'new')
    end

    it "should add foo" do
      merge_and_stub new_api_foo_path, 'get', 'Accept' => 'application/vnd.myvendor+json;version=2'
      expect(get: new_api_foo_path).to route_to(controller: 'api/v2/foo', action: 'new')
    end

    it "should not default" do
      merge_and_stub new_api_foo_path, 'get', 'Accept' => 'application/vnd.myvendor+json'
      expect(get: new_api_foo_path).to_not be_routable
    end

    it "should default" do
      original_version = ApiVersions::VersionCheck.default_version
      ApiVersions::VersionCheck.default_version = 2
      merge_and_stub new_api_foo_path, 'get', 'Accept' => 'application/vnd.myvendor+json'
      expect(get: new_api_foo_path).to route_to(controller: 'api/v2/foo', action: 'new')
      ApiVersions::VersionCheck.default_version = original_version
    end
  end

  describe "V3" do
    it "should copy foo" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json;version=3'
      expect(get: new_api_bar_path).to route_to(controller: 'api/v3/bar', action: 'new')
    end
  end

  describe "Header syntax" do
    after(:each) do
      expect(get: new_api_bar_path).to route_to(controller: 'api/v1/bar', action: 'new')
    end

    it "should allow spaces after the semi-colon" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json;   version=1'
    end

    it "should allow other formats besides json" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+xml; version=1'
    end

    it "should allow spacing around the equal sign" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor+json; version = 1'
    end

    it "should allow spacing around the plus" do
      merge_and_stub new_api_bar_path, 'get', 'Accept' => 'application/vnd.myvendor + xml; version=1'
    end
  end
end
