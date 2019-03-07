class FgScore < ActiveRecord::Base

  class << self

    def leaders level_id
      where(:level_id => level_id).order("milliseconds asc").limit(10)
    end

    def level_times player_guid
      where(:player_guid => player_guid).order("level_id asc")
    end

  end

  def serializable_hash opts = {}
     super((opts||{}).merge(:only => [:player_guid, :level_id, :milliseconds]))
  end

end
