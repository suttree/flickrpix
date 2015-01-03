class FlickrpixMailer < ActionMailer::Base
  require 'open-uri'

  def send_daily_email(urls)
    @urls = urls

    @urls.each do |url|
      attachments.inline[ url[:image] ] = open(url[:image]).read
    end

    mail(:to => 'duncan.gough@gmail.com', :from => 'duncan.gough+flickrpix@gmail.com', :subject => "flickrpix for #{Date.today.strftime('%b %d, %Y')}")
  end
end
