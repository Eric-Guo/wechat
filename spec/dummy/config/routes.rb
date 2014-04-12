Rails.application.routes.draw do
  get "wechat", to: "wechat#show"
  post "wechat", to: "wechat#create"
end
