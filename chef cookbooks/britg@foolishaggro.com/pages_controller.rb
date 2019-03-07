class PagesController < ActionController::Base

  layout "pages"

  def index
    @admin_ids = User.where(:admin => true).map(&:id)
    @videos = videos
    @topics = Topic.by_newest
                   .visible
                   .where(:user_id => @admin_ids,
                          :archetype => Archetype.default)
                   .where("category_id not in (5, 8, 9, 11)")
                   .limit(10)
  end

  def game
    @page_name = params[:game]

    render @page_name
  end

  def about

  end

  def contact

  end

  protected

  def videos
    YoutubeVideo.get_videos
  end

end