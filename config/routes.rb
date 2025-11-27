Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get '/dashboard', to: 'organisations#show', as: :dashboard
  get '/onboarding', to: 'organisations#new', as: :onboarding

  resources :organisations, only: [:new, :show, :create] do
    resources :expenses, only: [:new, :create, :show, :index]

    resources :employees, only: [:index, :new, :create, :destroy]

    resources :chats, only: [:index, :show, :create, :destroy] do
      resources :messages, only: [:create]
    end
  end

  patch '/expenses/:id/approve', to: 'expenses#approve', as: :approve_expense
  patch '/expenses/:id/reject',  to: 'expenses#reject',  as: :reject_expense

end
