CarrierWave.configure do |config|
  config.asset_host = "http://d11klizz3i72ef.cloudfront.net" if Rails.env.production?
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => '11111111111111111111111111',       # required
    :aws_secret_access_key  => '22222222222222222222222222',                        # required
    :region                 => 'us-1111-2',                  # optional, defaults to 'us-east-1'
    # :host                   => 's3.amazonaws.com',             # optional, defaults to nil
    # :endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
  }
  if Rails.env.development? || Rails.env.test?
    config.fog_directory  = 'intralist-uploads-dev'
  end
  if Rails.env.production?
    config.fog_directory = 'intralist-uploads-prod'
  end

  config.fog_public     = true                               # optional, defaults to true
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}  # optional, defaults to {}

end
