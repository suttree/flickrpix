class FlickrpixMailer < ActionMailer::Base
  def send_daily_email(urls)
    @urls = urls

    mail(:to => 'duncan.gough@gmail.com', :from => 'duncan.gough+flickrpix@gmail.com', :subject => "flickrpix for #{Date.today.strftime('%b %d, %Y')}")
  end
end
