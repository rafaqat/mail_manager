Given(/^(\d+) bounces exist$/) do |count|
  count.to_i.times{FactoryGirl.create(:bounce)} 
end

