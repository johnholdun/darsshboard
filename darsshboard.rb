#! /usr/bin/env ruby

# find some help

require 'rubygems'
require 'open-uri'
require 'crack'
require 'haml'

# figure stuff out

api_url = "http://www.tumblr.com/api/dashboard"
email, password = ARGV
num = 20
summary_length = 40
output = 'dashboard.rss'

# get those guys

xml = open("#{api_url}?email=#{email}&password=#{password}&num=#{num}").read
tumblr = Crack::XML.parse(xml)

# cut them up

items = tumblr['tumblr']['posts']['post'].map do |post|
  type = post['type'].to_sym
  
  title_field = case type
    when :regular, :conversation
      :title
    else
      nil
  end
  
  if title_field
    title_field = "#{type}_#{title_field}"
    title = post[title_field]
  end

  description_field = case type
    when :regular
      :body
    when :photo, :audio, :video
      :caption
    when :link, :quote, :conversation
      :text
  end
  
  description_field = "#{type}_#{description_field}"
  description = post[description_field]
  
  case type
    when :photo
      description = "<p><img src=\"#{post['photo_url'].first}\"></p>" + description
  end
  
  if title.blank?
    title = description.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ')
    if title.size > summary_length
      title = title[0 .. summary_length - 1] + '...'
    end
  end
  
  {
    :title => "#{post['tumblelog']}: #{title}",
    :description => description,
    :link => post['url-with-slug'],
    :pubdate => post['date']
  }
end

# spit into this cup

template = File.read('rss.haml')
File.open(output, 'w'){ |f| f.write(Haml::Engine.new(template).render(Object.new, :items => items)) }
