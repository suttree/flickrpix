desc "Send daily flickrpix email"
task :flickrpix => :environment do
  config = ConfigStore.new(File.join(Rails.root, '.flickr'))

  FlickRaw.api_key = ENV['FLICKR_API_KEY']
  FlickRaw.shared_secret = ENV['FLICKR_API_SECRET']

  token = flickr.get_request_token

  if config['token'] && config['secret']
    flickr.access_token = config['token']
    flickr.access_secret = config['secret']
  else
    auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

    puts "Open this url in your process to complete the authentication process : #{auth_url}"
    puts "Copy here the number given when you complete the process."
    verify = gets.strip

    begin
      flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
      login = flickr.test.login

      config.update({
          'token'  => token['oauth_token'],
          'secret' => token['oauth_token_secret']
      })

      puts 'Run this script again, now that you are authorised'
      exit(0)
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
      exit
    end
  end

  id = flickr.people.findByUsername(:username => ENV['FLICKR_API_USERNAME']).id

  list = flickr.people.getPhotos( :user_id => id, :min_taken_date => Time.now.to_i - (395 * 86400), :max_taken_date => Time.now.to_i - (365 * 86400) )

  urls = []
  list.each do |photo|
    info = flickr.photos.getInfo(:photo_id => photo['id'])
    urls << {:page => FlickRaw.url_photopage(info), :image => FlickRaw.url_z(info)}
  end

  random_pics = urls.sample(5)
  FlickrpixMailer.send_daily_email(random_pics).deliver!
end
