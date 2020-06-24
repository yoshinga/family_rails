# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#index'
  resources :books do
    member do
      patch :rent_book, as: 'rent'
      patch :return_book, as: 'return'
    end
  end
  resources :users
  resources :publishers
end
