class Api::NotificationsController < Api::BaseController
  before_filter :authenticate_user!
  #TODO: test

  def index
  end

  def destroy
    current_user.notifications.delete_all
    head 200
  end
end
