class NotificationMailer < ActionMailer::Base
  default from: "digest@intralist.com"
  layout 'mailer'

  def digest(user, notifications)
    @user = user
    @notifications = notifications
    mail(:to => @user.email, :subject => 'Recent activity on Intralist')
  end

  def share_list(user, list)
    @user = user
    @list = list
    mail(:to => @user, :subject => 'View Intralist list')
  end
end
