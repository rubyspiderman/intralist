if ENV["RAILS_ENV"] == "production"
  HOSTNAME = "http://www.intralist.com"
else
  HOSTNAME = "http://server.dev"
end