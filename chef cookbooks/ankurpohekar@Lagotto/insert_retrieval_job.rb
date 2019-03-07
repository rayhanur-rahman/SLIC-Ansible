class InsertRetrievalJob < ActiveJob::Base
  queue_as :critical

  def perform(source)
    ActiveRecord::Base.connection_pool.with_connection do
      source.insert_retrievals
    end
  end
end
