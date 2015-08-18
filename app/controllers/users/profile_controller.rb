#TODO: Figure out what to do with this.  Backdrop resource?
class Users::ProfileController < ApplicationController

  #TODO: This could be a restful resource like user backdrop
  def customize_view
    @profile = current_user.profile.nil? ? current_user.build_profile : current_user.profile
    @user = User.find(params[:user_id])
    @lists = List.where(:user_id => @user.id)
    @following = @user.following
    @followers = @user.followers
    @most_popular = @user.lists.most_popular.limit_5
    @themes = ProfileTheme.all
  end

  def save_customization
    if !(params[:theme_image].nil? || params[:theme_image].blank?)
      if params[:profile][:background_image].nil? || params[:profile][:background_image].blank?
        # params[:profile][:background_image] = File.open("public/#{params[:theme_image]}")
        # if the theme is used, we cannot store the EC2 image reference here...
        params[:profile][:theme_image] = params[:theme_image]
        # uploaded image trumps theme?
      end
    end
    if current_user.profile.nil?
      @profile = current_user.build_profile(params[:profile])
      @profile.save
    else
      @profile = current_user.profile.update_attributes(params[:profile])
    end
    redirect_to customization_user_profile_path, :notice => 'Customization saved.'
  end
end