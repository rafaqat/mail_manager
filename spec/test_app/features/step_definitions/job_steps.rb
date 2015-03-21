Given(/^I clear the job queue$/) do
  Delayed::Job.delete_all
end

Given(/^I set jobs to be delayed$/) do
  Delayed::Worker.delay_jobs = true 
end

