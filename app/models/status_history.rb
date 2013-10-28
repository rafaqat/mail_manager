=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Used to keep track of an objects status so that we can add more behaviour such as actual history of statuses if we so choose.

classes using this should define 'default_status', 'valid_statuses'

=end

module StatusHistory  
  # defines what happens when you change a status ... currently updates status and records a timestamp
  def change_status(new_status,save_record=true)
    raise "Invalid Status (#{new_status}) valid statuses: #{valid_statuses.join(',')}" unless self.class.valid_statuses.include?(new_status.to_s)
    return if new_status.eql?(status)
    self[:status] = new_status.to_s
    self[:status_changed_at] = Time.now.utc
    save if save_record
  end

  # default list of statuses ... in most cases should be overridden
  def self.included(base)
    Rails.logger.warn "Including statuses for #{base.class.name} #{base.name rescue "Blarg"}"
    base.class_eval %Q|
  # sets the initial status of an object if not set
  class_attribute :valid_statuses, :default_status
  def self.override_statuses(valid,default)
    Rails.logger.debug "Overriding Statuses for " + self.class.name + " - " + (self.name rescue "Blarg") + ", " +
      valid.inspect + ", " + default
    self.valid_statuses = valid
    self.default_status = default
  end
  override_statuses(['active', 'inactive', 'deleted'],'active')
  |
  end


  def status
    return self[:status].to_s unless self[:status].blank?
    self[:status] = default_status
  end
  
  def status=(new_status)
    return if status.eql?(new_status.to_s)
    change_status(new_status)
  end
  
  def status_changed_at=(whatever)
    raise "Invalid status change - use change_status(status) valid statuses: #{valid_statuses.join(',')}"
  end
  
  def set_default_status
    return unless status.blank?
    self[:status_changed_at] = Time.now.utc
    self[:status] = default_status
    Rails.logger.debug "Setting Default Status to #{default_status} #{self.name rescue "Not a class?"} #{self.class.name}"
    self[:status]
  end
  
end
