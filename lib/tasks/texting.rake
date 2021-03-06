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

task :update_test => :environment do
  Facebook.update_all
  Song.update_songs
  Album.update_all_covers
end

task :update_recom => :environment do
  e = Facebook.find_by_name("Edward Mehr")
  e.update_recommendations
end

task :delete_recom => :environment do
  Recommendation.all.each do |rec|
    rec.destroy
  end
end

task :user_listens => :environment do
  puts Facebook.count
end

task :update_songs => :environment do
  Song.update_songs
end

task :run_common_song => :environment do
  before = Time.now
  g = Facebook.find_by_name("Gabe Audick") 
  s = Facebook.users_with_common_song g
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  puts s.size.to_s
  s.each do |obj|
    puts obj.name + " : " + obj.song_count.to_s;
  end
  
  before = Time.now
  s = Facebook.users_with_common_song_among_friends g
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  puts s.size.to_s
  s.each do |obj|
    puts obj.name + " : " + obj.song_count.to_s;
  end
  
end

task :run_song_based_on_sorted_listens_for_user => :environment do
  before = Time.now
  g = Facebook.find_by_name("Gabe Audick") 
  s = Song.song_based_on_sorted_listens_for_user g
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  s.each do |obj|
    puts obj.title + " : " + obj.listen_count.to_s;
  end
  
end

task :run_song_based_on_sorted_listens_for_user_that_are_not_common_with_the_other_since => :environment do
  before = Time.now
  e = Facebook.find_by_name("Edward Mehr")
  g = Facebook.find_by_name("Gabe Audick")
  last_time_gabe_listened = g.listens.find(:first, :order => "start_time DESC") 
  s = Song.song_based_on_sorted_listens_for_user_that_are_not_common_with_the_other_since(g,e,last_time_gabe_listened.start_time-1.month).limit(50)
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  s.each do |obj|
    puts obj.title + " : " + obj.listen_count.to_s;
  end
  
end


task :update_tiny_song_id => :environment do
  Song.update_tiny_song_id
end

task :updating_user_pic => :environment do
  Facebook.all.each do |user|
    user.update_pic
  end
end

task :updating_album_cover => :environment do
  Album.update_all_covers
end

task :testing_parsing => :environment do
  c = Curl::Easy.perform("http://open.spotify.com/artist/1Dvfqq39HxvCJ3GvfeIFuT")
  tag = c.body_str.match /<img id=\"cover-art\" src=\".*\"/
  link = tag[0][25..tag[0].size]
  link = link[0..link.size-2]
  puts link
end


task :testing_recommendation => :environment do
  Facebook.find(:all,:conditions => ["is_friend_access = ?", false]).each do |user|
    user.update_recommendations
  end
end 

task :run_update_song_characteristics => :environment do
  Song.update_song_characteristics
end

task :run_echonest_perfom => :environment do
  Echonest.perform
end

task :deleting_errors_from_job_q => :environment do
  Delayed::Job.find(:all, :conditions => "last_error is not null").each do |err|
    err.destroy
  end
end

task :deleting_songs_from_job_q => :environment do
  Delayed::Job.find(:all, :conditions => "handler like '%Song%'").limit(100).each do |song|
    song.destroy
  end
end