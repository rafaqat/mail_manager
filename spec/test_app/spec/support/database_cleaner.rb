RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    if ActiveRecord::Base.connection.adapter_name =~ /sqlite/i
      #Rails.logger.debug "Setting cleaning strategy to truncation: sqlite"
      DatabaseCleaner.strategy = :truncation # sqlite3 doesn't support nested transactions :transaction
    elsif ActiveRecord::Base.connection.adapter_name =~ /postgres/i
      DatabaseCleaner.strategy = :truncation # sqlite3 doesn't support nested transactions :transaction
    else
      #Rails.logger.debug "Setting cleaning strategy to transaction(activerecord)"
      DatabaseCleaner.strategy = :transaction # assume a transactional database (we're using active_record)
      #DatabaseCleaner.strategy = :truncation # assume a transactional database (we're using active_record)
    end
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
