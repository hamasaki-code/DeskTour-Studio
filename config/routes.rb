Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "posts#index"

  resources :users, only: %i[new create show edit update]

  resources :posts, only: %i[index show new create edit update destroy] do
    post :like, on: :member
    get :notifications, on: :member
    resources :reports, only: :create
  end

  namespace :admin do
    resources :posts, only: %i[index update destroy]
    resources :reports, only: :index do
      patch :restore_post, on: :member
      patch :dismiss, on: :member
      delete :delete_post, on: :member
    end
  end

  get "privacy-policy", to: "pages#privacy", as: :privacy_policy
  get "terms", to: "pages#terms", as: :terms
  get "cookie-policy", to: "pages#cookie", as: :cookie_policy
  get "getting-started", to: "pages#onboarding", as: :onboarding
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }
end
