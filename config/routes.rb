# frozen_string_literal: true

Rails.application.routes.draw do
  resources :squad_analyses, only: [:new, :create, :show]

  resources :players, only: [:show]

  root "squad_analyses#new"
end
