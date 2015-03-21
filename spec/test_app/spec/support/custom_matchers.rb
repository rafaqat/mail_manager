RSpec::Matchers.define :match_attributes do |expected|
  match do |actual|
    success = true
    expected.each_pair do |key,value|
      # check if its a boolean
      success = if !!actual.send(key) == actual.send(key)
        actual.send(key) == (value != 0)
      elsif actual.send(key).is_a?(Time)
        actual.send(key).utc.to_i == value.utc.to_i
      else
        actual.send(key) == value
      end
      break unless success
    end
    success
  end
end
