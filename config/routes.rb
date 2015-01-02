Rails.application.routes.draw do
  devise_for :users

  resources :users do
    get "current", on: :collection
  end

  resources :groups do
    get "preferences", on: :member
    put "preferences", on: :member
    patch "preferences", on: :member
  end

  resources :events

  root to: "dashboards#show"
end
