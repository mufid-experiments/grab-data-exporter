Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :static do
    get :bypass
  end

  resources :invoices do
    collection do
      post :refresh
    end
  end
  root to: 'static#home'
end
