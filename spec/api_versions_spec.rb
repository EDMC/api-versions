require 'spec_helper'

describe ApiVersions do
  let(:testclass) { Class.new.extend ApiVersions }

  it "should raise if no vendor string is provided" do
    expect { testclass.api }.to raise_exception(RuntimeError, 'Please set a vendor_string for the api method')
  end
end
