Rails.application.routes.draw do
  root to: 'pages#index'
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    get '/', to: 'pages#index', as: :locale_root
    resources :coffeecards do
      resources :likes
    end
    get 'signup', to: 'users#new'
    resources :users, except: [:new] do
      member do
        get :confirm_email
      end
    end
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    resources :passwords
  end
end
