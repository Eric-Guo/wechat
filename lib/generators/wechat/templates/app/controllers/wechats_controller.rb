<% if defined? ActionController::API -%>
class WechatsController < ApplicationController
<% else -%>
class WechatsController < ActionController::Base
<% end -%>
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder

  on :text do |request, content|
    request.reply.text "echo: #{content}" # Just echo
  end
end
