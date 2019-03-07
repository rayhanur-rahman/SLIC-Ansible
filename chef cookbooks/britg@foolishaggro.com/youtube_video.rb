class YoutubeVideo

  FEED_URL = "https://gdata.youtube.com/feeds/api/users/foolishaggro/uploads?alt=json&fields=entry(title,content,published,media:group(media:player,media:thumbnail,yt:duration))&max-results=10"
  PLAYLIST_URL = "https://gdata.youtube.com/feeds/api/playlists/PLjG5_CnrWHc8kVGwtMxz58Vhck_gq2fvL?alt=json&fields=entry(title,content,published,media:group(media:player,media:thumbnail,yt:duration))&max-results=10"

  attr_accessor :feed_data, :thumbnail_url, :video_url, :title,
    :description, :duration, :published_at

  class << self
    def get_videos
      @videos = []
      raw = RestClient.get(FEED_URL) rescue nil
      return @videos unless raw.present?
      @feed = JSON.parse(raw)
      @feed["feed"]["entry"].each do |entry|
        @videos << YoutubeVideo.new(entry)
      end
      @videos
    end
  end

  def initialize feed_data
    @feed_data = feed_data
    parse_feed_data
  end

  def parse_feed_data _data = nil
    _data ||= @feed_data
    @published = _data["published"]["$t"]
    @title = _data["title"]["$t"]
    @description = _data["content"]["$t"]
    @video_url = _data["media$group"]["media$player"][0]["url"]
    @thumbnail_url = _data["media$group"]["media$thumbnail"][0]["url"]
    @duration = _data["media$group"]["yt$duration"]
  end

end