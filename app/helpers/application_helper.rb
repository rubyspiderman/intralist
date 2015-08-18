module ApplicationHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def nav_link(link_text, link_path, add_class = '', method = '')
    class_name = current_page?(link_path) ? 'active' : ''
    content_tag(:li, :class => class_name + " " + add_class) do
      method == 'delete' ? link_to(link_text, link_path, :method => method) : link_to(link_text, link_path)
    end
  end

  def page_nav(link_text, path)
    link_to_unless_current(link_text, path) do
      content_tag(:p, link_text)
    end
  end

  def flash_message(flash_name, msg)
    css_class = case flash_name
    when /notice/ then "alert-message alert-success"
    when /error/ then "alert-message alert-error"
    when /alert/ then "alert-message alert-info"
    end
    content_tag :div, content_tag(:div, msg, :id => "flash_#{flash_name}", :class => css_class), :class => 'alert-message-container'
  end

  def has_profile_image?(user)
    if user.profile && !user.profile.avatar.blank?
      true
    else
      false
    end
  end

  def has_pics(list)
    # this could be refeactored to not make a database call
    list.images.count > 0
  end

  def first_pic(list)
    list.items.where(:picture.exists => true).first.picture.thumb.url
  end

  def enlarge_photo(user)
    case user.profile.image_display
    when "facebook"
      large_img = user.profile.avatar.gsub(/\?(.*)/, "?type=large")
    when "twitter"
      large_img = user.profile.avatar
    when "upload"
      large_img = user.profile.avatar
    else
      large_img = image_path "annonymous_user.jpg"
    end
  end
  
  def avatar_url(user)
    case user.profile.image_display
    when "facebook"
      thumb_img = user.profile.facebook_image
    when "twitter"
      thumb_img = user.profile.twitter_image
    when "upload"
      thumb_img = user.profile.image.thumb.url
    else
      thumb_img = image_path "annonymous_user.jpg"
    end
    return thumb_img
  end
end
