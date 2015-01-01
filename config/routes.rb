Rails.application.routes.draw do
  devise_for :users

  resources :users do
    get "current", on: :collection
  end

  root to: "dashboards#show"
end
