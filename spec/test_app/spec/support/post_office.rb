module PostOffice
  def self.start_post_office
    return if `lsof -i TCP:25000 | grep LISTEN | wc -l`.to_i == 1
    unless(@post_office_pipe.present?)
      @post_office_pipe = IO.popen("post_office -s 25000 -p 11000")
      5.times do
        break if `lsof -i TCP:25000 | grep LISTEN | wc -l`.to_i == 1
        sleep 0.1
      end
      Rails.logger.debug "Opened post office! SMTP: 2500 POP: 11000" if `lsof -i TCP:25000 | grep LISTEN | wc -l`.to_i == 1
    end
  end
end
