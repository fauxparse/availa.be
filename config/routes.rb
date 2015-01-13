Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    resources :users do
      get 'current', on: :collection
    end

    resources :groups do
      resources :events
      resources :skills

      get 'preferences', on: :member
      put 'preferences', on: :member
      patch 'preferences', on: :member
    end

    resources :events, except: [:new, :create]
    resources :skills, only: [:show]

    get 'calendar', to: 'events#calendar'

    root to: 'dashboards#show'
  end
end
