Rails.application.routes.draw do
  resources :submissions
  resources :payment_intents
  resources :webhooks ,only: [:create]
  

  root 'submissions#index'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
