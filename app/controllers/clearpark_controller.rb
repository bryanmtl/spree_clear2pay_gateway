class ClearparkController < ApplicationController
  
  before_filter :set_gateway_and_order
  
  def verification
    total = params[:TIA].to_s.gsub(",", ".")
    # make sure the cpid matches before going any further
    unless @cpid == params[:CPID] and  @security_token == params[:SECTOK] and @order.total.to_s == total 
      render :text => 'NOK'
    else
      render :text => 'OK'
    end 
  end
  
  def get_extra_info
    # not really necessary
  end
  
  def notification
    total = params[:TIA].to_s.gsub(",", ".")
    result = params[:RESULT]
    ok_result_values = %w(Approved Rejected Exception)
    unless @cpid == params[:CPID] and @security_token == params[:SECTOK] and @order.total.to_s == total and ok_result_values.include?(result)
      render :text => 'NOK'
    else
      begin
      # record the payment
      fake_card = Creditcard.new :cc_type        => "visa",
                                 :month          => Time.now.month, 
                                 :year           => Time.now.year, 
                                 :first_name     => @order.bill_address.firstname, 
                                 :last_name      => @order.bill_address.lastname,
                                 :verification_value => 'clearpay',
                                 :number => "clearpay"

      payment = @order.checkout.payments.create(:amount => @order.total, 
                                             :source => fake_card,
                                             :payment_method_id => @gateway.id)

      # query - need 0 in amount for an auth? see main code
      transaction = CreditcardTxn.new( :amount => @order.total,
                                       :response_code => 'success',
                                       # :payment_status => 'paid',
                                       :txn_type => CreditcardTxn::TxnType::PURCHASE)


      payment.txns << transaction  

      @order.save!
      session[:order_id] = nil
      until @order.checkout.state == "complete"
        @order.checkout.next!
      end
      flash[:commerce_tracking] = I18n.t("notice_messages.track_me_in_GA")
      payment.finalize!
      
    rescue
      render :text => 'NOK'
      return false
    end
      
      # respond ok
      render :text => 'OK'
      
      
    end
  end
  
  private
  
  def set_gateway_and_order
    @gateway = PaymentMethod.find(:first, 
    :conditions => ['type = ? and active = ? and environment = ?', 'PaymentMethod::ClearPay', true, ENV['RAILS_ENV']])
    @order = Order.find_by_number(params[:ORDID])
    @cpid = @gateway.preferred_cpid
    @security_token = @gateway.preferred_security_token
    
  end
  
end
