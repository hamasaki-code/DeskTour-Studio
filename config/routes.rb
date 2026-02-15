Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "posts#index"

  resources :posts, only: %i[index show new create] do
    post :like, on: :member
    resources :comments, only: :create
  end

  namespace :admin do
    resources :posts, only: %i[index update destroy]
    resources :comments, only: %i[index update destroy]
  end

  get "privacy-policy", to: "pages#privacy", as: :privacy_policy
  get "terms", to: "pages#terms", as: :terms
  get "cookie-policy", to: "pages#cookie", as: :cookie_policy
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }
end
