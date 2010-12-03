#! /usr/bin/env ruby

# find some help

require 'rubygems'
require 'open-uri'
require 'json'
require 'haml'

# figure stuff out

api_url = "http://www.tumblr.com/api/dashboard/json"
email, password, format = ARGV
num = 20

# get those guys

json = open("#{api_url}?email=#{email}&password=#{password}&num=#{num}").read.gsub(/(^var tumblr_api_read = |;$)/, '')
tumblr = JSON.parse json.gsub(/\\u([0-9A-F]{4})/i, '&#x\1;')

# slice and dice

items = tumblr['posts'].map do |post|
  type = post['type'].to_sym
  
  title_field = case type
    when :regular, :conversation
      :title
    else
      nil
  end
  
  if title_field
    title_field = "#{type}-#{title_field}"
    title = post[title_field]
  else
    title = type.to_s.capitalize
  end

  description_field = case type
    when :regular
      :body
    when :photo, :audio, :video
      :caption
    when :link, :quote, :conversation
      :text
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
  end
  
  if post['tags']
    description += '<p class="tags"><em>' + post['tags'].map{ |t| "##{t}" }.join(' ') + '</em></p>'
  end
  
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
    :description => c(description),
    :link => post['url-with-slug'],
    :pubdate => post['date']
  }
end

# spit into this cup

format = format.downcase
formats = %w[rss html]
if !formats.include? format
  format = formats.first
end

template = File.read(File.join 'output', 'templates', "#{format}.haml")
output = File.join( 'output', "dashboard.#{format}")

File.open(output, 'w'){ |f| f.write(Haml::Engine.new(template).render(Object.new, :items => items)) }
