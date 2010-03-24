require File.dirname(__FILE__) + '/../spec_helper'

describe ClearpayAccount do
  before(:each) do
    @clearpay_account = ClearpayAccount.new
  end

  it "should be valid" do
    @clearpay_account.should be_valid
  end
end
