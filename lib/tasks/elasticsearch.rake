require 'elasticsearch/rails/tasks/import'

namespace :elasticsearch do
  desc "Reindexes all the elasticsearch models for development"
  task :reindex => :environment do
    begin
      # Please update this list based your requirements
      DO_NOT_INDEX = [Response]
      files = Dir.glob("#{Rails.root}/app/models/*")
      files.each do |file|
        if file =~ /\.rb/
          file_name_with_ext = file.split('/').last
          filename, ext = file_name_with_ext.split('.')

          if filename.camelcase.constantize.ancestors.include?(Elasticsearch::Model) &&
              !DO_NOT_INDEX.include?(filename.camelcase.constantize)
            STDOUT.puts "Indexing model: #{filename.camelcase}..."
            klass = filename.camelcase.constantize
            klass.import(force: true)
          end
        end
      end
    rescue => e
      STDOUT.puts("#{e.message}")
      STDOUT.puts("#{e.backtrace}")
    end
  end
end

#Response.__elasticsearch__.index_document
