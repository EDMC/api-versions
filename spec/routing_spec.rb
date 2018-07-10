require 'spec_helper'

describe 'API Routing' do
  include RSpec::Rails::RequestExampleGroup

  describe "V1" do
    it "should not route something from V2" do
      get new_api_foo_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=1' }
      expect(response.status).to eq(404)
    end

    it "should route" do
      get new_api_bar_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=1' }
      expect(@controller.class).to eq(Api::V1::BarController)
    end

    it "should default" do
      get new_api_bar_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json' }
      expect(@controller.class).to eq(Api::V1::BarController)
    end

    it "should default with nothing after the semi-colon" do
      get new_api_bar_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json; ' }
      expect(@controller.class).to eq(Api::V1::BarController)
    end
  end

  describe "V2" do
    it "should copy bar" do
      get new_api_bar_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=2' }
      expect(@controller.class).to eq(Api::V2::BarController)
    end

    it "should add foo" do
      get new_api_foo_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=2' }
      expect(@controller.class).to eq(Api::V2::FooController)
    end

    it "should not default" do
      get new_api_foo_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json' }
      expect(response.status).to eq(404)
    end

    it "should default" do
      original_version = ApiVersions::VersionCheck.default_version
      ApiVersions::VersionCheck.default_version = 2
      get new_api_foo_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json' }
      ApiVersions::VersionCheck.default_version = original_version
      expect(@controller.class).to eq(Api::V2::FooController)
    end
  end

  describe "V3" do
    it "should copy foo" do
      get new_api_foo_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=3' }
      expect(@controller.class).to eq(Api::V3::FooController)
    end

    it "should route to nested controllers" do
      get new_api_nests_nested_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=3' }
      expect(@controller.class).to eq(Api::V3::Nests::NestedController)
    end
  end

  describe "Header syntax" do
    context "when valid" do
      after(:each) do
        get new_api_bar_path, headers: { 'HTTP_ACCEPT' => @accept_string }
        desired_format = /application\/.*\+\s*(?<format>\w+)\s*/.match(@accept_string)[:format]
        expect(response.content_type).to eq("application/#{desired_format}")
        expect(response).to be_successful
      end

      context "the semi-colon" do
        it "should allow spaces after" do
          @accept_string = 'application/vnd.myvendor+json;   version=1'
        end

        it "should allow spaces before" do
          @accept_string = 'application/vnd.myvendor+xml ;version=1'
        end

        it "should allow spaces around" do
          @accept_string = 'application/vnd.myvendor+xml ; version=1'
        end
      end

      context "the equal sign" do
        it "should allow spacing before" do
          @accept_string = 'application/vnd.myvendor+json; version =1'
        end

        it "should allow spacing after" do
          @accept_string = 'application/vnd.myvendor+json; version= 1'
        end

        it "should allow spacing around" do
          @accept_string = 'application/vnd.myvendor+json; version = 1'
        end
      end

      context "the plus sign" do
        it "should allow spacing before" do
          @accept_string = 'application/vnd.myvendor +xml; version=1'
        end

        it "should allow spacing after" do
          @accept_string = 'application/vnd.myvendor+ xml; version=1'
        end

        it "should allow spacing around" do
          @accept_string = 'application/vnd.myvendor + xml; version=1'
        end
      end
    end

    it "should not route when invalid" do
      get new_api_bar_path, headers: { 'HTTP_ACCEPT' => 'application/vnd.garbage+xml;version=1' }
      expect(response.status).to eq(404)
    end
  end

  describe 'paths' do
    it "should pass options, such as :path, to the regular routing DSL" do
      expect(new_api_baz_path).to eq('/baz/new')
    end

    it 'should be possible to use shallow routes with overwritten :path option' do
      expect(api_reply_path(1)).to eq('/replies/1')
    end
  end

  describe 'namespace' do
    it "should be possible to remove api namespace" do
      expect(new_qux_path).to eq('/qux/new')
    end

    it "should be possible to overwrite api namespace" do
      expect(new_auth_api_quux_path).to eq('/auth_api/quux/new')
    end
  end
end
