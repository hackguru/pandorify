task :delete_update_for_user
  Facebook.find(:all, :conditions => "last_updated IS NOT NULL").each do |user|
    user.last_updated=nil
    user.save!
  end
end

task :count_update_for_user
  puts Facebook.find(:all, :conditions => "last_updated IS NOT NULL").count
end

task :count_listens
  puts Listen.count
end

task :update
  Facebook.update_all
end
