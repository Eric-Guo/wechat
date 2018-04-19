Rails.application.routes.draw do
  get 'wechat', to: 'wechat#show'
  post 'wechat', to: 'wechat#create'

  get 'wechat_corp', to: 'wechat_corp#show'
  post 'wechat_corp', to: 'wechat_corp#create'

  get  'wechat_accounts', to: 'wechat_accounts#show'
  post 'wechat_accounts', to: 'wechat_accounts#create'
end
