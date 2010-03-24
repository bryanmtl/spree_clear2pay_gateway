# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class Clear2payGatewayExtension < Spree::Extension
  version "1.0"
  description "Integration with Clear2Pay gateway. Added as a payment method"
  url "http://github.com/bryanmtl/clear2pay_gateway"

  def activate
    
    PaymentMethod::ClearPay.register    
        
    # inject paypal code into orders controller
    CheckoutsController.class_eval do
      include Spree::ClearPay
    end
    
    Creditcard.class_eval do
      
      def process!(payment)
        return true
      end
      
    end
    

  end
end
