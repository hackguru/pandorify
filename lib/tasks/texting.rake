task :delete_update_for_user do
  Facebook.find(:all, :conditions => "last_updated IS NOT NULL").each do |user|
    user.last_updated=nil
    user.save!
  end
end

task :count_update_for_user do
  puts Facebook.find(:all, :conditions => "last_updated IS NOT NULL").count
end

task :count_listens do
  puts Listen.count
end

task :update do
  Facebook.update_all
end
