Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to:  "tactile#index"
  get "tactile/index", to: "tactile#index", as: :tactile_index
  get "tactile/mokuji", to: "tactile#mokuji", as: :tactile_mokuji
  get "tactile/show", to: "tactile#show", as: :tactile_show
  get "tactile/tts_settings", to: "tactile#tts_settings", as: :tactile_tts_settings
  
end
