class ClearparkController < ApplicationController
  
  before_filter :set_gateway_and_order
  skip_before_filter :verify_authenticity_token 
  
  def verification
    total = params[:TIA].to_s.gsub(",", ".").to_f
    # make sure the cpid matches before going any further
    unless @cpid == params[:CPID] and  @security_token == params[:SECTOK] and @order.total.to_f == total 
      render :text => '[NOK]'
    else
      render :text => '[OK]'
    end 
  end
  
  def getextrainfo
     unless @cpid == params[:CPID] and @order and params[:INF] == 'CustomerReference'
        render :text => '[NOK]'
      else
        render :text => '[OK]'
      end
  end
  
  def notification
    total = params[:TIA].to_s.gsub(",", ".").to_f
    result = params[:RESULT]
    ok_result_values = %w(Approved Rejected Exception)
    unless @cpid == params[:CPID] and @security_token == params[:SECTOK] and @order.total.to_f == total and ok_result_values.include?(result)
      render :text => '[NOK]'
    else
      if result == 'Approved'
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
        render :text => '[NOK]'
        return false
      end
    else
      # the transaction didn't go through yet, but we still need to respond with ok
      render :text => '[OK]'
      return false
    end
      # respond ok
      render :text => '[OK]'   
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
