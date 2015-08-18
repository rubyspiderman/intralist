module ListsHelper
    def user_bookmarked(list)
      if current_user.bookmarks.where("resource_id" => list.id).first
        return true
      else 
        return false
      end
    end

    def tags_to_list(list)
      ul = "<ul class='tags'>"
      ul << list.tags.map {|t| '<li>' + link_to('#' + t.name, tag_path(t.name)) + '</li>'}.join
      ul << "</ul>"
    end

    def url_me(link)
      unless link[/^http:\/\//] || link[/^https:\/\//]
        link = 'http://' + link
      else
        return link
      end
    end

    def follows?(user)
      current_user.follows?(user)
    end

    def list_owner?(list)
      if user_signed_in? && list.user.id == current_user.id
        true
      else
        false
      end
    end
end
