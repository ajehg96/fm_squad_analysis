# frozen_string_literal: true

# config/routes.rb
Rails.application.routes.draw do
  resources :tactics
  resources :squad_analyses, only: [:new, :create, :show]
  resources :scouted_players, only: [:index, :new, :create]
  resources :players, only: [:show]
  root "tactics#index"
end
