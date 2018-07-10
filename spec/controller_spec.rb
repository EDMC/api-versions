require 'spec_helper'

require 'api-versions/test/controller_helpers'

describe Api::V1::BarController do
  include RSpec::Rails::ControllerExampleGroup
  extend ApiVersions::Test::ControllerHelpers

  routes Api::V1::BarController

  it "should invoke controller's action" do
    get :new, format: :json
    expect(response).to be_success
  end
end
