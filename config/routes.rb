require 'resque/server'

Rails.application.routes.draw do
  mount Resque::Server.new, :at => "/resque", :as => 'resque'
  #
  # Default home page
  root :to => 'customers#index'
  #
  # Auth
  devise_for :users
  resource :profile
  #
  # Admin
  namespace :admin do
    resources :users do
      get :become
    end
    #
    # Catalog
    resources :products
    resources :vendors
    #
    # Special
    resources :service_invoices, only: [:show, :create]
    resources :accounts, only: [:update]
  end
  # TODO: Get rid of this
  post 'admin/service_invoices/flush',
    :to => 'invoices#flush',
    :as => 'service_invoice_flush'
  #
  # Proposals
  resources :proposals do
    resources :payments
  end
  #
  # Onboarding
  resources :onboarding
  #
  # Billing
  resources :invoices do
    resources :line_items
    resources :payments
  end
  get 'pay/:payment_token',
    :to => 'pay#new',
    :as => 'new_payment'
  post 'pay/:payment_token',
    :to => 'pay#create',
    :as => 'payment'
  get 'prepay/:portal_id',
    :to => 'pay#prepaid_new',
    :as => 'new_prepayment'
  post 'prepay/:portal_id',
    :to => 'pay#prepaid_create',
    :as => 'prepayment'
  #
  # Customers / Contacts
  resources :contacts do
    resources :opportunities
    resources :comments
  end
  resources :customers do
    resources :proposals
    resources :invoices
    resources :payments
  end
  #
  # Error handling
  match '/400' => 'error#bad_request', :via => :all
  match '/404' => 'error#not_found', :via => :all
  match '/406' => 'error#not_acceptable', :via => :all
  match '/500' => 'error#internal_server_error', :via => :all

end
