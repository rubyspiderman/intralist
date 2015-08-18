# Requires all the search modules located in the lib/searchable folder
Dir.glob("#{Rails.root}/lib/searchable/*").each do |file|
  require file
end