class Lock
  class LockException < Exception
  end
  def self.with_lock(name, timeout=5, max_attempts=1, &block)
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      begin
        lock = get_lock(connection,name,timeout,max_attempts)
        raise LockException.new("Failed to obtain lock #{name} in #{timeout} secs") unless lock
        yield lock
      ensure
        is_released = release_lock(connection,name)
        Rails.logger.warn "Warning: lock #{name} not released!" unless is_released.values.include?('1')
      end
    end
  end
  
  private
  
  def self.name_prefix
    "#{MailManager.site_url}-#{Rails.env}"
  end
  
  def self.get_lock(connection,name,timeout,max_attempts)
    attempts = 0
    lock = {}
    while !lock.values.include?('1') and attempts < max_attempts do 
      attempts += 1
      lock = connection.select_one("SELECT GET_LOCK('#{name_prefix}-#{name}',#{timeout})")
    end
    lock.values.detect{|value| value.to_s.eql?('1')}
  end
  
  def self.release_lock(connection,name)
    connection.select_one("SELECT RELEASE_LOCK('#{name_prefix}-#{name}')")
  end
end
