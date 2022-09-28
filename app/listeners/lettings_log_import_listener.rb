class LettingsLogImportListener
  # include Wisper::Publisher

  def on_events_import_started(run_id)
    puts "LettingsLogs::ImportListener STARTING RUN -> #{run_id}"
  end

  def on_events_import_finished(run_id)
    puts "LettingsLogs::ImportListener FINISHED RUN -> #{run_id}"
  end  

  def on_events_import_item_processed(run_id, processor)
    puts "LettingsLogs::ImportListener ITEM PROCESSED -> #{run_id} old_id: #{processor.old_id}, discrepency?: #{processor.discrepancy?}"
  
    redis = Redis.new
    obj = redis.get(run_id)
    logs_import = Marshal.load(obj)
    puts "GOT FROM REDIS: total: #{logs_import.total}"

    logs_import.num_saved += 1

    if processor.discrepancy?
      logs_import.discrepancies << processor.old_id
    end

    redis.set(run_id, Marshal.dump(logs_import))
    
    if last_item?(logs_import)
      collate_results_and_update_db(logs_import)
      send_email_with_results(logs_import)
      # broadcast(::Import::FINISHED, run_id)
    end
  end  

  def last_item?(logs_import)
    logs_import.total == (logs_import.num_saved + logs_import.num_skipped)
  end

  def collate_results_and_update_db(logs_import)
    logs_import.finished_at = Time.zone.now
    logs_import.duration_seconds = (logs_import.finished_at - logs_import.started_at).seconds.to_i
    logs_import.save!
  end

  def send_email_with_results(logs_import)
    # TODO
  end
end
