class BackgroundJobWorker
  include Sidekiq::Worker

  attr_reader :key

  sidekiq_options retry: 4

  def self.enqueue key, *args
    BackgroundJob.enqueue self, key, *args
  end

  def self.timeout
    self::TIMEOUT || 2.minutes
  end

  def self.job key
    BackgroundJob.new self, key
  end

  def self.status key
    BackgroundJob.new(self, key).status
  end

  def self.keys
    BackgroundJob.keys self
  end

  def job
    @job ||= self.class.job key
  end

  def perform key, *args
    @key = key

    return if job.running?

    job.running!

    do_the_job key, *args

    job.completed!
  rescue => error
    job.failed!
    job.error = error
    raise
  end

end
