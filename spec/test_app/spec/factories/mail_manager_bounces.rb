FactoryGirl.define do
  factory :bounce, :class => 'MailManager::Bounce' do
    status {random_value([:needs_manual_intervention,:unprocessed,:dismissed,
      :resolved,:invalid
    ])}
    #status_changed_at {Time.now}
    #bounce_message 
    #comments 
    #message nil
    #mailing nil
  end

end
