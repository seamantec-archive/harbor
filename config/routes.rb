Rails.application.routes.draw do
  devise_for :users, :controllers => {:sessions => "user_sessions"}, :skip => [:passwords]
  mount Resque::Server, :at => "/resque"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static#show'

  # authenticate  do #replace admin_user(s) with whatever model your users are stored in.
  #   mount Resque::Server.new, :at => "/resque"
  # end

  # authenticate :user, lambda { |u| u.is_admin? } do
  #   mount Resque::Server.new, :at => "/resque"
  # end
  resources :users do

    collection do
      get 'list_customers'
      get 'list_partners'
      get 'list_admins'
      get 'new_partner'
      post 'create_sign_up'
    end

    member do
      get 'suspend'
      get 'resume'
      get 'activate_anonym'
      get 'new_customer'
      get 'edit_password'
      patch 'change_password'
      patch 'update_password'
      get 'edit_password_with_token'
      get 'reset_password'
    end

    resources :licenses do
      collection do
        #get "demo_licenses"
      end
    end


    resources :license_pools do
      member do
        get "new_allocation"
        post "allocate_new_license"
      end
    end

    resources :devices

    resources :nmea_logs do
      collection do
        get "process_logs"

      end
      member do 
         get "download"
      end
    end

    resources :polars do
      member do
        get "download"
        get "send_to_device"
      end
    end

  end

  resources :coupons do
    member do
      get "print"
    end
    collection do
      post "post_redeem"
    end
  end
  resources :license_templates
  resources :dashboards do
    collection do
      get "get_user_reports"
      get "get_licenses_reports"
      get "get_orders_reports"
      get "get_payments_reports"
    end
  end
  resources :releases do
    member do
      post "upload_callback"
      get "set_def_mac"
      get "set_def_win"
      post "upload_file"
    end
  end

  resources :licenses do
    collection do
      get "list_demo"
      get "list_commercial"
      get "list_trial"
      get "new_demo"
      post "create_demo"
      get "new_trial"
      post "create_trial"
      get "new_public_trial"
      post "create_public_trial"
    end
    member do
      get "resend_email"
    end
  end

  resources :orders do
    resources :paypal_payments do
      collection do
        get "set_express_checkout"
        get "do_express_checkout"
        get "cancel_payment"
        post "ipn"
      end
    end
    collection do
      get "refresh_number_of_items"
      get "validate_vat_id"
      get "buy_it_now"

    end
    member do
      get "payment_summary"
      get "thank_you"
      get "create_invoice_manually"
      get 'create_billingo_invoice'
      get 'send_billingo_invoice'
    end

    resources :payments do
      collection do
        post "pay_with_braintree"
      end
    end
  end


  resources :invoice_arrays do
    resources :invoices do
      member do
        get "save_as_pdf"
        get "open_raw_invoice"
        get "resend"
        get "storno"
        get "finalize"
      end
    end

    member do
      get "set_default_web_shop_array"
    end

  end

  resources :product_categories do
    collection do
      get "new_item"
      post "create_item"
      get "show_item"
      get "edit_item"
      patch "update_item"
      put "update_item"
      delete "destroy_item"
    end
  end

  resources :faqs do
    collection do
      get "new_question"
      post "create_question"
      get "show_question"
      get "edit_question"
      patch "update_question"
      put "update_question"
      delete "destroy_question"
      post "topic_change"
      post "question_change"
      post "question_topic_change"
    end
  end

  resources :admin_panels do
    collection do
      get "activate_anonym_customers"
      get "websockets"
    end
  end

  resources :testimonials

  get "public_faq" => "faqs#list"

  get "about" => "static#about"
  get "terms" => "static#terms"
  get "data_protection" => "static#data_protection"
  get "eula" => "static#eula"
  get "contact" => "static#contact"

  get "get_license" => "licenses#get_license"
  post "download_license" => "licenses#download_license"
  get "download_license_from_list" => "licenses#download_license"

  get "download" => "products#download"
  get "download_win" => "products#download_win"
  get "download_mac" => "products#download_mac"
  get "get_current_version" => "products#get_current_version"
  get "store" => "orders#store"
  post "accept_cookie" => "application#accept_cookie"
  get "thank_you" => "products#thank_you"
  get "sign_up" => "users#sign_up"
  get "forget_password" => "users#forget_password"
  post "reset_password_by_email" => "users#reset_password_by_email"
  get "redeem" => "coupons#redeem"

  #-------------API------------------

  namespace :api do
    namespace :v1 do
      resource :api
      post "download_license" => "api#get_license"
      post "sign_in" => "api#sign_in_with_token"
      get "get_devices" => "api#get_devices"
      get "get_actual_polar" => "api#get_actual_polar"
      get "polar_downloaded" => "api#polar_downloaded"
      get "download_polar" => "api#download_polar"
      get "get_polars" => "api#get_polars"
      get "send_polar_to_devices" => "api#send_polar_to_devices"
      post "save_polar" => "api#save_polar"
      put "update_polar" => "api#update_polar"
      delete "destroy_polar" => "api#destroy_polar"
      post "save_log_file" => "api#save_log_file"
    end
  end

end
