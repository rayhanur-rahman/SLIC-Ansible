class DeleteWorkJob < ActiveJob::Base
  queue_as :high

  def perform(publisher_id)
    ActiveRecord::Base.connection_pool.with_connection do
      if publisher_id == "all"
        Work.destroy_all
      elsif publisher_id.present?
        Work.where(publisher_id: publisher_id).destroy_all
      end
    end
  end
end
