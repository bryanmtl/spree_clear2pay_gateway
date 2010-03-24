require File.dirname(__FILE__) + '/../spec_helper'

describe ClearpayTxn do
  before(:each) do
    @clearpay_txn = ClearpayTxn.new
  end

  it "should be valid" do
    @clearpay_txn.should be_valid
  end
end
