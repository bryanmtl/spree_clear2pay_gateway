module Spree::ClearPay
  include ERB::Util
  # include ActiveMerchant::RequiresParameters

  def clearpay_payment
    load_object
    
    @gateway = payment_method
    
  end
  
  def payment_success
    load_object
    @gateway = payment_method
    
    # record a payment
      
    fake_card = Creditcard.new :cc_type        => "visa",
                               :month          => Time.now.month, 
                               :year           => Time.now.year, 
                               :first_name     => @order.bill_address.firstname, 
                               :last_name      => @order.bill_address.lastname,
                               :verification_value => 'clearpay',
                               :number => "clearpay"
                               
    payment = @order.checkout.payments.create(:amount => @order.total, 
                                           :source => fake_card,
                                           :payment_method_id => params[:payment_method_id])

    # query - need 0 in amount for an auth? see main code
    transaction = CreditcardTxn.new( :amount => @order.total,
                                     :response_code => 'success',
                                     :payment_status => 'paid',
                                     :txn_type => CreditcardTxn::TxnType::PURCHASE)
    

    payment.txns << transaction  


    
    @order.save!
    @checkout.reload
    #need to force checkout to complete state
    until @checkout.state == "complete"
      @checkout.next!
    end
    complete_checkout
    payment.finalize!

  end


  def payment_failure
    load_object
    @gateway = payment_method
  end

  

    # create the gateway from the supplied options
  def payment_method
    PaymentMethod.find(params[:payment_method_id])
  end

  
  
  
end
