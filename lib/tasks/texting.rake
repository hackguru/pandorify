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
  e = Facebook.find_by_name("Gabe Audick")
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
  e = Facebook.find_by_name("Edward Mehr")
  g = Facebook.find_by_name("Gabe Audick") 
  s = g.list_of_friends_with_most_in_common
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  puts s.size.to_s
  s.each do |obj|
    puts obj[0].name + " : " + obj[1].to_s
  end

  s = g.list_of_people_with_most_in_common
  after = Time.now
  puts before.to_s + after.to_s
  puts (after - before).to_s
  puts s.size.to_s
  s.each do |obj|
    puts obj[0].name + " : " + obj[1].to_s
  end
  # s = g.list_of_friends_with_most_in_common.limit(100) 
  # after = Time.now
  # puts before.to_s + after.to_s
  # puts (after - before).to_s
  # puts s.size.to_s
  # s.each do |obj|
  #   puts obj[0].name + " : " + obj[1].to_s
  # end
end

task :run_common_song_new => :environment do
  before = Time.now
  g = Facebook.find_by_name("Gabe Audick") 
  s = g.users_with_common_song
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



