module ApplicationHelper
  include Authentication::HelperMethods
  
  def str_to_bool (arg)
    return true if arg == true || arg =~ (/(true|t|yes|y|1)$/i)
    return false if arg == false || arg.blank? || arg =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{arg}\"")
  end

end
