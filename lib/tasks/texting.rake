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

task :user_listens => :environment do
  puts Facebook.count
end

task :update_songs => :environment do
  Song.update_popularity_all
end

task :run_common_song => :environment do
  e = Facebook.find_by_name("Edward Mehr")
  g = Facebook.find_by_name("Gabe Audick")
  s = Song.song_based_on_sorted_listens_for_user e
  s1= e.listens.song_based_on_sorted_listens
  puts s.size + " vs " + s1.size
end
