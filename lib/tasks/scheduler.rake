desc "Mail the digests"
task :digest_mailer => :environment do
  users = User.where(:send_notification_email => true)
  users.each do |u|
    daily_notifications = u.notifications.daily
    if daily_notifications.count > 0
      NotificationMailer.digest(u, daily_notifications).deliver
    end
  end
end