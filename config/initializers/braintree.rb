Braintree::Configuration.environment = CONFIGS[:braintree]["environment"].to_sym
Braintree::Configuration.merchant_id = CONFIGS[:braintree]["merchant_id"]
Braintree::Configuration.public_key = CONFIGS[:braintree]["public_key"]
Braintree::Configuration.private_key = CONFIGS[:braintree]["private_key"]