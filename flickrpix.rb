#! /usr/bin/env ruby

# TODO
# - better OAuth
# - select 5 random pix and post them somewhere

require 'flickraw'
require 'rubygems'
require 'active_support'

FlickRaw.api_key = ENV['FLICKR_API_KEY']
FlickRaw.shared_secret = ENV['FLICKR_API_SECRET']

token = flickr.get_request_token
auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

puts "Open this url in your process to complete the authication process : #{auth_url}"
puts "Copy here the number given when you complete the process."
verify = gets.strip

begin
  flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
  login = flickr.test.login
  puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end

id = flickr.people.findByUsername(:username => ENV['FLICKR_API_USERNAME']).id
puts id

list = flickr.people.getPhotos( :user_id => id, :min_taken_date => Time.now.to_i - (395 * 86400), :max_taken_date => Time.now.to_i - (365 * 86400) )
list.each do |photo|
  info = flickr.photos.getInfo(:photo_id => photo['id'])
  puts FlickRaw.url_photopage(info).inspect
end
