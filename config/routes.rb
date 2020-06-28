# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#index'
  resources :books do
    member do
      patch :rent_book, as: 'rent'
      patch :return_book, as: 'return'
    end
    collection do
      get :new_book_search, as: 'new_book_search'
      post :create_book_search, as: 'create_book_search'
      get :predictive_search
    end
  end
  resources :users
  resources :publishers

  devise_for :users, :controllers => {
  :registrations => 'users/registrations',
  :sessions => 'users/sessions'
  }

  devise_scope :user do
    get "user/:id", :to => "users/registrations#detail"
    get "signup", :to => "users/registrations#new"
    get "login", :to => "users/sessions#new"
    get "logout", :to => "users/sessions#destroy"
  end
end
