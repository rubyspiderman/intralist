web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec QUEUE=avatar_updator,background_indexer rake resque:work