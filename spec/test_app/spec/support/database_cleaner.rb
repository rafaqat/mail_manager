RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    if ActiveRecord::Base.connection.adapter_name =~ /sqlite/
      DatabaseCleaner.strategy = :truncation # sqlite3 doesn't support nested transactions :transaction
    else
      DatabaseCleaner.strategy = :transaction # assume a transactional database (we're using active_record)
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
