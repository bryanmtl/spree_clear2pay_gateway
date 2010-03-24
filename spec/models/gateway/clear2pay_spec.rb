require File.dirname(__FILE__) + '/../../spec_helper'

describe Gateway::Clear2pay do
  before(:each) do
    @clear2pay = Gateway::Clear2pay.new
  end

  it "should be valid" do
    @clear2pay.should be_valid
  end
end
