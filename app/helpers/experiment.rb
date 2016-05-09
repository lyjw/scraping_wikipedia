require 'nokogiri'
require 'net/http'

# Nokogiri creates a URI object to parse the provided uri/url
uri  = URI("http://www.denverpost.com/frontpage")

# It makes a request to the uri and saves the response body
body = Net::HTTP.get(uri)

# Nokogiri parses the HTML and use CSS selectors to find all links in list elements
document = Nokogiri::HTML(body)
links    = document.css('li a')

# print each interesting looking link
links.each do |link|
  next if link.text.empty? || link['href'].empty?
  puts link.text, "  #{link['href']}", "\n"
end

# pry at the bottom so we can play with it
require "pry"
binding.pry
