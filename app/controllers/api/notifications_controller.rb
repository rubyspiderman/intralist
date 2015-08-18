class Api::NotificationsController < Api::BaseController
  def destroy
    user = current_user
    head 403 unless user
    status = user.notifications.delete_all ? 200 : 400
    head status
  end
end
