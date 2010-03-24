require File.dirname(__FILE__) + '/../spec_helper'

describe ClearpayCreditCard do
  before(:each) do
    @clearpay_credit_card = ClearpayCreditCard.new
  end

  it "should be valid" do
    @clearpay_credit_card.should be_valid
  end
end
