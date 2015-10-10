class WechatsController < ApplicationController
  wechat_responder

  # default text responder when no other match
  on :text do |request, content|
    request.reply.text "echo: #{content}" # Just echo
  end

  # When receive 'help', will trigger this responder
  on :text, with: 'help' do |request|
    request.reply.text 'help content'
  end

  # When receive '<n>news', will match and will got count as <n> as parameter
  on :text, with: /^(\d+) news$/ do |request, count|
    # Wechat article can only contain max 10 items, large than 10 will dropped.
    news = (1..count.to_i).each_with_object([]) { |n, memo| memo << { title: 'News title', content: "No. #{n} news content" } }
    request.reply.news(news) do |article, n, index| # article is return object
      article.item title: "#{index} #{n[:title]}", description: n[:content], pic_url: 'http://www.baidu.com/img/bdlogo.gif', url: 'http://www.baidu.com/'
    end
  end

  on :event, with: 'subscribe' do |request|
    request.reply.text "#{request[:FromUserName]} subscribe now"
  end

  # When unsubscribe user scan qrcode qrscene_xxxxxx to subscribe in public account
  # notice user will subscribe public account at same time, so wechat won't trigger subscribe event any more
  on :scan, with: 'qrscene_xxxxxx' do |request, ticket|
    request.reply.text "Unsubscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # When subscribe user scan scene_id in public account
  on :scan, with: 'scene_id' do |request, ticket|
    request.reply.text "Subscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # When no any on :scan responder can match subscribe user scaned scene_id
  on :event, with: 'scan' do |request|
    if request[:EventKey].present?
      request.reply.text "event scan got EventKey #{request[:EventKey]} Ticket #{request[:Ticket]}"
    end
  end

  # When enterprise user press menu BINDING_QR_CODE and success to scan bar code
  on :scan, with: 'BINDING_QR_CODE' do |request, scan_result, scan_type|
    request.reply.text "User #{request[:FromUserName]} ScanResult #{scan_result} ScanType #{scan_type}"
  end

  # Except QR code, wechat can also scan CODE_39 bar code in enterprise account
  on :scan, with: 'BINDING_BARCODE' do |message, scan_result|
    if scan_result.start_with? 'CODE_39,'
      message.reply.text "User: #{message[:FromUserName]} scan barcode, result is #{scan_result.split(',')[1]}"
    end
  end

  # When user click the menu button
  on :click, with: 'BOOK_LUNCH' do |request, key|
    request.reply.text "User: #{request[:FromUserName]} click #{key}"
  end

  # When user sent the imsage
  on :image do |request|
    request.reply.image(request[:MediaId]) # Echo the sent image to user
  end

  # When user sent the voice
  on :voice do |request|
    request.reply.voice(request[:MediaId]) # Echo the sent voice to user
  end

  # When user sent the video
  on :video do |request|
    nickname = wechat.user(request[:FromUserName])['nickname'] # Call wechat api to get sender nickname
    request.reply.video(request[:MediaId], title: 'Echo', description: "Got #{nickname} sent video") # Echo the sent video to user
  end

  # When user sent location
  on :location do |request|
    request.reply.text("#{request[:Location_X]}, #{request[:Location_Y]}") # replay the GPS location
  end

  on :event, with: 'unsubscribe' do |request|
    request.reply.text "#{request[:FromUserName]} can not receive this message"
  end

  # When user enter the app / agent app
  on :event, with: 'enter_agent' do |request|
    request.reply.text "#{request[:FromUserName]} enter agent app now"
  end

  # When batch job create/update user (incremental) finished.
  on :batch_job, with: 'sync_user' do |request, batch_job|
    request.reply.text "sync_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job replace user (full sync) finished.
  on :batch_job, with: 'replace_user' do |request, batch_job|
    request.reply.text "replace_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job invent user finished.
  on :batch_job, with: 'invite_user' do |request, batch_job|
    request.reply.text "invite_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job replace department (full sync) finished.
  on :batch_job, with: 'replace_party' do |request, batch_job|
    request.reply.text "replace_party job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # Any not match above will fail to below
  on :fallback, respond: 'fallback message'
end
