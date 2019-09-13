# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :orders, only: [] do
      resources :shipments, only: [] do
        resources :return_authorizations, only: %i[new create]
      end
    end

    resources :shipments, only: :destroy do
      member do
        post :push_shipment_order
      end
    end
  end
end
