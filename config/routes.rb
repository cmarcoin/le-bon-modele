Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]

  namespace :admin do
    root "dashboard#index"
    resources :packs, only: %i[index edit update] do
      collection do
        post :sync_stripe
      end

      member do
        post :sync_stripe
      end
    end
    resources :availability_slots do
      collection do
        get :bulk_new
        post :bulk_create
        post :purge_past
      end
    end
    resources :bookings, only: %i[index show destroy]
  end

  resources :packs, param: :slug, only: [] do
    resources :bookings, only: %i[new create]
  end

  get "checkout/success", to: "checkout#success", as: :checkout_success
  get "checkout/cancel", to: "checkout#cancel", as: :checkout_cancel
  post "stripe/webhooks", to: "stripe_webhooks#create", as: :stripe_webhooks

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  get "qui-sommes-nous", to: "home#about", as: :about
  get "faq", to: "home#faq", as: :faq
  get "starter-pack", to: "home#starter_pack", as: :starter_pack
  get "pack-premium", to: "home#pack_premium", as: :pack_premium
  get "contact", to: "home#contact", as: :contact
  post "contact", to: "home#submit_contact", as: :submit_contact
end
