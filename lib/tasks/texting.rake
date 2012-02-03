task :delete_update_for_user => :environment do
  Facebook.find(:all, :conditions => "last_updated IS NOT NULL").each do |user|
    user.last_updated=nil
    user.save!
  end
end

task :count_update_for_user => :environment do
  puts Facebook.find(:all, :conditions => "last_updated IS NOT NULL").count
end

task :count_listens => :environment do
  puts Listen.count
end

task :update => :environment do
  Facebook.update_all
end

task :update_recom => :environment do
  e = Facebook.find_by_name("Edward Mehr")
  e.update_recommendations
end

task :user_listens => :environment do
  puts Facebook.count
end

task :update_songs => :environment do
  Song.update_songs
end

task :run_common_song => :environment do
  before = Time.now
  e = Facebook.find_by_name("Edward Mehr")
  g = Facebook.find_by_name("Gabe Audick") 
  s = e.list_of_friends_with_most_in_common 
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  puts s.size.to_s
  s.each do |obj|
    puts obj[0].name + " : " + obj[1].to_s
  end
end

task :update_tiny_song_id => :environment do
  Song.update_tiny_song_id
end

