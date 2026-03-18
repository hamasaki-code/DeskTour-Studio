Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "ads.txt", to: "ads#show", defaults: { format: :text }

  root "pages#home"
  get "gallery", to: "posts#index", as: :gallery

  resources :users, only: %i[index new create show edit update]

  resources :posts, only: %i[index show new create edit update destroy] do
    post :like, on: :member
    get :notifications, on: :member
  end

  namespace :admin do
    resources :posts, only: %i[index update destroy]
  end

  get "privacy-policy", to: "pages#privacy", as: :privacy_policy
  get "terms", to: "pages#terms", as: :terms
  get "cookie-policy", to: "pages#cookie", as: :cookie_policy
  get "getting-started", to: "pages#onboarding", as: :onboarding
  get "support", to: "pages#support", as: :support
  post "support", to: "support_requests#create"
  get "about", to: "pages#operator", as: :about
  get "login", to: "pages#login", as: :login
  post "login", to: "sessions#create"
  get "password-reset", to: "password_resets#new", as: :password_reset
  post "password-reset", to: "password_resets#create"
  get "password-reset/edit", to: "password_resets#edit", as: :edit_password_reset
  patch "password-reset", to: "password_resets#update"
  delete "logout", to: "sessions#destroy", as: :logout
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }
end
