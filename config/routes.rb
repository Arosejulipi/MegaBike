# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#home"

  # Temporary debug route: only mounted when EXPOSE_ERRORS_PUBLIC=1
  if ENV['EXPOSE_ERRORS_PUBLIC'] == '1'
    get "/__trigger_error", to: "debug#trigger"
    get "/__debug_status", to: "debug#status"
    get "/__diagnose", to: "debug#diagnose"
  end

  get "/nosotros", to: "pages#about"

  resources :products, only: %i[index show]

  resource :cart, only: %i[show] do
    post :add_item
    post :remove_item
    post :clear
  end

  resources :orders, only: %i[new create show]

  resources :appointments, only: %i[new create]
  resources :custom_quotes, only: %i[new create]

  get "/faq", to: "faq#index"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/registro", to: "registrations#new"
  post "/registro", to: "registrations#create"

  namespace :admin do
    root to: "products#index"
    resources :products
  end

  # Letter Opener
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
