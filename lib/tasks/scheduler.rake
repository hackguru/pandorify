task :update => :environment do
  puts "Enqueueing user info and songs"
  Delayed::Job.enqueue Facebook
  puts "Enqueueing song info"
  Delayed::Job.enqueue Song
  puts "Enqueueing album covers"
  Delayed::Job.enqueue Album
  puts "Done"
end
