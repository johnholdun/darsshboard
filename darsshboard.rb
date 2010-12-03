#! /usr/bin/env ruby

# find some help

require 'rubygems'
require 'open-uri'
require 'json'
require 'haml'

# figure stuff out

api_url = "http://www.tumblr.com/api/dashboard/json"
email, password, format = ARGV
num = 50

# get those guys

json = open("#{api_url}?email=#{email}&password=#{password}&num=#{num}").read.gsub(/(^var tumblr_api_read = |;$)/, '')
tumblr = JSON.parse json.gsub(/\\u([0-9A-F]{4})/i, '&#x\1;')

# slice and dice

items = tumblr['posts'].map do |post|
  type = post['type'].to_sym
  
  title_field = case type
    when :regular, :conversation
      :title
    when :link
      :text
    else
      nil
  end
  
  if title_field
    title_field = "#{type}-#{title_field}"
    title = post[title_field].strip
    title = nil if title == ''
  end
    
  if title.nil?
    title = (type == :regular ? 'Post' : type.to_s.capitalize)
  end

  description_field = case type
    when :regular
      :body
    when :photo, :audio, :video
      :caption
    when :quote, :conversation
      :text
    when :link
      :description
  end
  
  description = ''
  
  if description_field
    description_field = "#{type}-#{description_field}"
    description = post[description_field] || ''
  end
  
  case type
    when :photo
      img = "<img src=\"#{post['photo-url-500']}\">"
      
      photo_href = post['photo-link-url'] || post['photo-url-1280']

      if photo_href
        img = "<a href=\"#{photo_href}\">#{img}</a>"
      end
      
      description = "<p>#{img}</p>" + description
      
    when :audio, :video
      description = post["#{type}-player"] + description
      
    when :quote
      description += "<p><em>&mdash; #{post['quote-source']}</em></p>"
      
    when :answer
      description = "<p><strong>#{post['question']}</strong></p> #{post['answer']}"
      
    when :link
      title += " &rsaquo;"
      description += "<p><a href=\"#{post['url-with-slug']}\">#</a></p>"
  end
  
  # lol inline styles
  description += '<div style="overflow: hidden; background: #EEE; -webkit-border-radius: 4px; -moz-border-radius: 4px; padding: 4px;">'
  
  if post['tags']
    description += '<p style="margin: 0; padding: 0; float: left; font-style: italic; color: #555; font-size: 0.75em; line-height: 1.333em;">' + post['tags'].map{ |t| "##{t}" }.join(' ') + '</p>'
  end
  
  like_button_uri = "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%0F%00%00%00%0E%08%06%00%00%00%F0%8AF%EF%00%00%00%19tEXtSoftware%00Adobe%20ImageReadyq%C9e%3C%00%00%01RIDATx%DA%9C%92MK%02Q%14%86%DF%7BG%FBX%95%9A%E5G%0D%A2%94%A1%A1%82c%60Z%89n%C2EA%9B%B6%FD%B4%B6m*%8A%12%A2%0C%AAU%0B!%A4%2C%FBP%10%24%11%A9))%1B%CD%9B%B3%10%D4%0Ct%9E%D5%B9%2F%E7%E1%1E8%870%C6P%FE%FCb%A7%17WH%3FeQ%A9H%D0jF%10Z%10%E0%B4%5BI%E9UdG'%97%C8%E6%F2%A0%94%C2l%D4c%C9%EF%85%957%13%F2-U%D9%D6%F6%3E%F2%2FEt%E2%17%5CH%3Dd%F0%26~%B4%E5%1CG%B1%B9%B1%0Ar%7D%9Bf%3B%87q%F4%8B%DDf%01%7D%CC%E4%A0%84B%B1%04*IUEr%BD%5E%07%1D%D3%8E*%92%87%87%06A%A7%AD%BC%22%D9%C2%9B%40%A7L%13%E0%CD%86%BED%15%C7Ap%3B%E4%D5Q%12%8D%041%A0V%F7%2C%87%02%02%F4%3A%0D%A1%F2%C30%AE%23k%2B%CB%3D%89n%C7%0C%82%F3%1E%22%D7D%BE%B0%26%89%E4%1D%3B8%3EGk%D6%CA%DC%AC%0D%EB%D1%B0%3C%EE_Y%E6%E6%FE%99%ED%C6%E2%A8%D5~%DAr%9F%C7%89h%24%00%D2%A0%99%91n%BF%E4%F2%05%B6%17%3BC%E3%AE%A1V%A9%10%5E%F4%C1%EFu%91%CE%3E%F2%DF%88%E2%7B%99%25%92%A9%C6%26%8C%B0Y%26I%B7%9E_%01%06%00%DD%25rL%5C%06%95%E4%00%00%00%00IEND%AEB%60%82"
  description += "<a style=\"float: right; margin: -4px; padding: 4px; overflow: hidden; text-decoration: none; width: 15px; height: 15px;\" href=\"http://tumblr.com/like/#{post['reblog-key']}?id=#{post['id']}&redirect_to=/likes\"><img src=\"#{like_button_uri}\" alt=\"Like this post on Tumblr\" title=\"Like this post on Tumblr\"></a>"
  
  description += '</div>'
  
  # NO, we don't want summaries, summaries are the worst
  
  # summary_length = 40
  # if title.blank?
  #   title = description.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ')
  #   if title.size > summary_length
  #     title = title[0 .. summary_length - 1] + '...'
  #   end
  # end
  
  {
    :title => "#{post['tumblelog']['title']} - #{title}",
    :description => description,
    :link => post['link-url'] || post['url-with-slug'],
    :pubdate => post['date']
  }
end

# spit into this cup

format = format.to_s.downcase
formats = %w[rss html]
if !formats.include? format
  format = formats.first
end

template = File.read(File.join 'output', 'templates', "#{format}.haml")
output = File.join( 'output', "dashboard.#{format}")

File.open(output, 'w'){ |f| f.write(Haml::Engine.new(template).render(Object.new, :items => items)) }
