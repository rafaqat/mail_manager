module PostOffice
  def self.start_post_office(smtp = 25000, pop = 11000) 
    return if `lsof -i TCP:#{smtp} | grep LISTEN | wc -l`.to_i == 1
    unless(@post_office_pipe.present?)
      @post_office_pipe = IO.popen("post_office -s #{smtp} -p #{pop}")
      5.times do
        break if `lsof -i TCP:#{smtp} | grep LISTEN | wc -l`.to_i == 1
        sleep 0.1
      end
      Rails.logger.debug "Opened post office! SMTP: #{smtp} POP: #{pop}" if `lsof -i TCP:#{smtp} | grep LISTEN | wc -l`.to_i == 1
    end
  end
end
