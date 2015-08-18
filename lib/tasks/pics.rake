namespace :pics do
  desc "Fix directory location of pictures"
  task :item_update => :environment do
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id => 'AKIAIMY6I6LF6GMHKAKA',
      :aws_secret_access_key => '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'
    })

    bucket = "intralist-uploads-prod"

    puts "Using bucket: #{bucket}"
    List.all.each do |l|
      if l.images.count > 0
        l.items.each do |i|
          if i.picture.path.to_s != ""
            new_full_path = i.picture.path.to_s
            filename = new_full_path.split('/')[-1].split('?')[0]
            thumb_filename = "thumb_#{filename}"
            original_file_path = "items/#{filename}"
            original_thumb_file_path = "items/#{thumb_filename}"
            puts "attempting to retrieve: #{original_file_path}"
            # copy original item
            begin
              connection.copy_object(bucket, original_file_path, bucket, new_full_path, 'x-amz-acl' => 'public-read')
              puts "we just copied: #{original_file_path}"
            rescue
              puts "couldn't find: #{original_file_path}"
            end
            # copy thumb
            begin
              connection.copy_object(bucket, original_thumb_file_path, bucket, "uploads/item/picture/#{i.id}/#{thumb_filename}", 'x-amz-acl' => 'public-read')
              puts "we just copied: #{original_thumb_file_path}"
            rescue
              puts "couldn't find thumb: #{original_thumb_file_path}"
            end
          end
        end
      end
    end
  end
  desc "Populate the image URL"
  task :image_url => :environment do
    List.all.each do |l|
      puts "starting with list: #{l.name}"
      if l.images.count > 0
        l.items.each do |i|
          if i.picture && i.picture.length > 1 
            puts "updating picture path for: #{i.picture}"
            i.image_url = "https://intralist-uploads-prod.s3.amazonaws.com/uploads/item/picture/#{i.id}/#{i.picture}"
            puts "updated the path for: #{i.picture}"
          end
        end
      end
      l.save
      puts "saved changes to list: #{l.name}"
    end
  end

  desc "Regenerate images"
  task :regenerate_images => :environment do
    List.all.each_with_index do |list, index|
      puts index
      list.items.each do |item|
        begin
          if item.image_url
            uploader = ItemUploader.new
            uploader.download! item.image_url
            uploader.store!
            item.image_url = uploader.url
            item.save!
          end
        rescue
          puts "rescuing"
        end
      end
    end
  end
end
