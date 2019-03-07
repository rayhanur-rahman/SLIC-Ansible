class ScoresController < ApplicationController

  skip_before_filter :verify_authenticity_token

  # &type => level|player
  # &player_guid
  def index
    if level_id.present?
      get_level_scores
    else
      get_player_scores
    end

    render :json => @resp
  end

  def create
    if !score.present?
      @score = FgScore.create(:player_guid => player_guid,
                              :level_id => level_id,
                              :milliseconds => milliseconds)
    else
      score.update_attributes(:milliseconds => milliseconds)
    end

    render :json => { :result => "success" }
  end

  protected

  def player_guid
    params[:player_guid]
  end

  def level_id
    params[:level_id]
  end

  def milliseconds
    params[:milliseconds]
  end

  def score
    @score ||= FgScore.where(:player_guid => player_guid,
                             :level_id => level_id).first
  end

  def get_level_scores
    @player_time = score.try(:milliseconds)
    @leaders = FgScore.leaders(level_id)
    @resp = { :player_time => @player_time, :leaders => @leaders }
  end

  def get_player_scores
    @level_times = FgScore.level_times(player_guid)
    @resp = { :levels => @level_times }
  end

end