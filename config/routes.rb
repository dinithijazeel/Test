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
  end
  # TODO: Get rid of this
  post 'admin/service_invoices/flush',
    :to => 'invoices#flush',
    :as => 'service_invoice_flush'
  #
  # Proposals
  resources :proposals
  #
  # Onboarding
  resources :onboarding
  #
  # Billing
  resources :invoices do
    resources :line_items
    resources :payments
  end
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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
