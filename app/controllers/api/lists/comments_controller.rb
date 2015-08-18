class Api::Lists::CommentsController < Api::BaseController
  before_filter :authenticate_user!, :except => [:index]

  #TODO:This should take pagination and offset params when necessary
  def index
    comments = list.comments.desc(:created_at)
    comments = comments[5, (comments.length-1)]

    render json: comments
  end

  #TODO: background creation, deletion to prevent race with deletion
  def create
    comment = Comment.new(:content => params[:content],
                          :user_id => current_user.id,
                          :image => avatar_url(current_user),
                          :commentable => list,
                          :cid => params[:cid])
    status = comment.save ? 201 : 400

    unless current_user == list.user
      Notification.new_comment(list.user, current_user, list)
      mentions = get_mentions(params[:content])
      Notification.new_mention(mentions, current_user, list) unless mentions.empty?
    end

    head status
  end

  def update
    comment = list.find_comment(params[:id])
    head 403 unless comment.user_id == current_user.id

    status = comment.update_attributes(:content => params[:content]) ? 200 : 400
    head status
  end

  def destroy
    comment = list.find_comment(params[:id])
    head 403 unless comment.user_id == current_user.id

    status = comment.destroy ? 200 : 400
    head status
  end

  def get_mentions(content)
    mentions = content.scan(/(@\S+)/).flatten
    users = []
    unless mentions.empty?
      mentions.each do |mention|
        user = User.where(username: mention.gsub("@", "")).first
        users.push(user) unless user.nil?
      end
      return users
    else
      return []
    end
  end

end
