Rails.application.routes.draw do
  # Devise authentication with custom controllers
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Dashboard
  get 'dashboard', to: 'dashboard#show', as: :dashboard
  root 'pages#home'

  # Main resources
  resources :documents do
    member do
      get :download
      post :archive
    end
    collection do
      get :expiring
    end
  end

  resources :compliance_categories, except: [:show]

  resources :team, only: [:index, :show, :destroy] do
    collection do
      post :invite
    end
    member do
      post :resend_invitation
    end
  end

  resources :reminders, only: [:index] do
    member do
      post :acknowledge
    end
  end

  # Settings
  namespace :settings do
    resource :notifications, only: [:show, :update]
    resource :organization, only: [:show, :update]
    resource :billing, only: [:show]
  end

  # Reports
  resources :reports, only: [:index, :show] do
    collection do
      get :audit
      post :generate
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Stripe webhooks
  post 'webhooks/stripe', to: 'webhooks#stripe'
end
