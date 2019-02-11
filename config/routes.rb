Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :shipments, only: [] do
      member do
        post :push_shipment_order
      end
    end
  end
end
