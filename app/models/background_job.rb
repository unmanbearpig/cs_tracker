
class BackgroundJob
  attr_reader :klass, :key

  STATUSES = [:not_scheduled, :scheduled, :running, :completed, :failed]

  def initialize klass, key
    @klass = klass
    @key = key
  end


  def running!
    self.status = :running
  end

  def scheduled!
    self.status = :scheduled
  end

  def completed!
    self.status = :completed
  end

  def failed!
    self.status = :failed
  end


  def running?
    status == :running
  end

  def scheduled?
    status != :not_scheduled
  end

  def completed?
    status == :completed
  end

  def failed?
    status == :failed
  end


  def running_at
    event_time :running
  end

  def scheduled_at
    event_time :scheduled
  end

  def completed_at
    event_time :completed
  end

  def failed_at
    event_time :failed
  end

  def error
    store.get 'error'
  end

  def error= error
    store.set 'error', "#{error.to_s}\n#{error.backtrace}"
  end

  def status
    return :not_scheduled if expired?
    raw_status
  end

  def raw_status
    status_string = store.get('status')
    return :not_scheduled unless status_string
    status = status_string.to_sym
    status
  end

  def expired?
    if raw_status != :not_scheduled
      Time.now - scheduled_at > klass.timeout
    end
  end

  def results_count
    store.llen 'result'
  end

  def results
    store.lrange 'result', 0, -1
  end

  def push_result result
    store.rpush 'result', result
  end

  def enqueue *args
    scheduled!
    klass.perform_async key, *args
  end

  def self.enqueue klass, key, *args
    job = new klass, key
    job.enqueue *args
    job
  end

  def event_time status
    fail "Invalid status" unless STATUSES.include? status
    unix_time = store.get "#{status}_at"
    return unless unix_time
    Time.at unix_time.to_i
  end

  protected

  def status= status
    fail "Invalid status" unless STATUSES.include? status
    store.set 'status', status
    set_event_time status, Time.now
  end

  def set_event_time status, time
    fail "Invalid status" unless STATUSES.include? status
    store.set "#{status}_at", time.to_i
  end

  def erase_job
    store.del *all_possible_keys
  end

  def all_possible_keys
    keys = []
    keys << STATUSES.map { |s| "#{s}_at" }
    keys << 'status'
    keys << 'result'
  end

  def store
    @store ||= Redis::Namespace.new "#{klass.to_s}:#{key}"
  end

end
