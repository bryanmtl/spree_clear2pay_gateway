# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class Clear2payGatewayExtension < Spree::Extension
  version "1.0"
  description "Integration with Clear2Pay gateway. Added as a payment method"
  url "http://github.com/bryanmtl/spree_clear2pay_gateway"

  def activate

      PaymentMethod::ClearPay.register    

      # inject paypal code into orders controller
      CheckoutsController.class_eval do
        include Spree::ClearPay

        before_filter :redirect_for_clearpay
        before_filter :load_data, :except => [:payment_success, :payment_failure]
        def redirect_for_clearpay
          if object.payment? 
            if PaymentMethod.find(params[:checkout][:payments_attributes].first[:payment_method_id].to_i).class.name == 'PaymentMethod::ClearPay'
              payment_method = params[:checkout][:payments_attributes].first[:payment_method_id].to_i
              redirect_to(clearpay_payment_order_checkout_url(:payment_method_id => payment_method)) and return
            end
          end
        end
        
        def payment_success
          session[:order_id] = nil
          flash[:commerce_tracking] = I18n.t("notice_messages.track_me_in_GA")
        end

      end

      Creditcard.class_eval do

        def process!(payment)
          return true
        end

      end


    end
  end
