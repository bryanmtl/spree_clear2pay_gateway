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
