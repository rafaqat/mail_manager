module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name, routing=nil)
    case page_name
    
    when /the homepage/
      '/'
    
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    # added by script/generate pickle path
    when /the unsubscribe by email address page/
      '/unsubscribe_by_email_address'
    when /^the (.+?) page$/                                         # translate to named route
      path_words = $1
      begin
        routing.send("#{path_words.downcase.gsub(' ','_')}_path")
      rescue => e
        mail_manager.send("#{path_words.downcase.gsub(' ','_')}_path")
      end
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
