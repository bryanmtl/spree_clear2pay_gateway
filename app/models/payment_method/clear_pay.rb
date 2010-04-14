class PaymentMethod::ClearPay < PaymentMethod
  
  preference :cpid, :string
  preference :url, :string
	preference :currency_code, :string
	preference :language, :string
	preference :security_token, :string
  
  # visa 4000 0000 0000 0002 - test visa number
  # Validation Code: 123
  # Any future date
  
  def payment_profiles_supported?
    false
  end
  
end
