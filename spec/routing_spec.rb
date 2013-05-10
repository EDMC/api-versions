require 'spec_helper'

describe 'API Routing' do
  include RSpec::Rails::RequestExampleGroup

  describe "V1" do
    it "should not route something from V2" do
      get new_api_foo_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=1'
      response.status.should == 404
    end

    it "should route" do
      get new_api_bar_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=1'
      @controller.class.should == Api::V1::BarController
    end

    it "should default" do
      get new_api_bar_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json'
      @controller.class.should == Api::V1::BarController
    end

    it "should default with nothing after the semi-colon" do
      get new_api_bar_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json; '
      @controller.class.should == Api::V1::BarController
    end
  end

  describe "V2" do
    it "should copy bar" do
      get new_api_bar_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=2'
      @controller.class.should == Api::V2::BarController
    end

    it "should add foo" do
      get new_api_foo_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=2'
      @controller.class.should == Api::V2::FooController
    end

    it "should not default" do
      get new_api_foo_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json'
      response.status.should == 404
    end

    it "should default" do
      original_version = ApiVersions::VersionCheck.default_version
      ApiVersions::VersionCheck.default_version = 2
      get new_api_foo_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json'
      ApiVersions::VersionCheck.default_version = original_version
      @controller.class.should == Api::V2::FooController
    end
  end

  describe "V3" do
    it "should copy foo" do
      get new_api_foo_path, nil, 'HTTP_ACCEPT' => 'application/vnd.myvendor+json;version=3'
      @controller.class.should == Api::V3::FooController
    end
  end

  describe "Header syntax" do
    context "when valid" do
      after(:each) do
        get new_api_bar_path, nil, 'HTTP_ACCEPT' => @accept_string
        response.should be_success
      end

      context "the semi-colon" do
        it "should allow spaces after" do
          @accept_string = 'application/vnd.myvendor+json;   version=1'
        end

        it "should allow spaces before" do
          @accept_string = 'application/vnd.myvendor + xml ;version=1'
        end

        it "should allow spaces around" do
          @accept_string = 'application/vnd.myvendor + xml ; version=1'
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
          @accept_string = 'application/vnd.myvendor +xml; version=1'
        end
      end
    end

    it "should not route when invalid" do
      get new_api_bar_path, nil, 'HTTP_ACCEPT' => 'application/vnd.garbage+xml;version=1'
      response.status.should == 404
    end

    it "should not route when no header is specified" do
      get new_api_bar_path, nil
      response.status.should == 404
    end
  end
end
