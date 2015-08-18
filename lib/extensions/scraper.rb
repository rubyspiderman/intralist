class Scraper
  require 'open-uri'

  BLACKLIST = ["sprite", "icon", "transparent", "pixel", "button", "ads", "doubleclick", "gravatar"]

  class << self
    attr_reader :host, :scheme
  end

  def self.scrape(options = {})
    begin
      @response = { "status" => "ok", "title" => '', "description" => '', "images" => [] }
      url = options[:url]
      url = "http://#{url}" unless url.match(/^https?:\/\//) || Rails.env == "test"
      headers = {}
      if Rails.env == "production"
        headers = { :allow_redirections => :safe,
                    :read_timeout => 5,
                    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0" }
      end
      resource = open(url, headers)
      if resource.content_type.include? "image"
        @response['images'] << url
      else
        @page = Nokogiri::HTML(resource)
        @host = resource.respond_to?(:base_uri) ? resource.base_uri.host : nil
        @scheme = resource.respond_to?(:base_uri) ? resource.base_uri.scheme : "http"
        @base_path = resource.respond_to?(:base_uri) ? resource.base_uri.path : nil
        @base_path = @base_path.split('/')[1..-2].try(:join, '/') if @base_path
        @image_limit = options[:image_limit]
        get_title
        get_description
        get_images
      end
    rescue Exception => e
      @response = { "status" => "fail", "message" => e.message }
      @page = @host = @scheme = nil;
    end
    @response
  end

  class << self
    private

    def get_title
      @response["title"] = @page.title
    end

    def get_description
      @page.css("meta").each do |meta|
        if meta.attributes['name'] && meta.attributes['name'].value.downcase == "description"
          @response["description"] = meta.attributes['content'].value
        end
      end
    end

    def get_images
      @page.css("meta[property='og:image']").each { |node| parse_image(node, 'content') }
      unless @response["images"].present?
        @page.css('img').each { |img| parse_image(img, 'src') }
        @page.xpath('//*[@itemprop="image"]').each { |node| parse_image(node, 'content') }
      end
    end

    def parse_image(node, val)
      if node.attributes[val].present? && node.attributes[val].value.present?
        path = URI.escape(node.attributes[val].value)
        path = attach_host_scheme_to(path)
        path = normalize_url(path)
        unless @response["images"].include?(node.attributes[val].value) || Scraper::BLACKLIST.any? { |blacklist| path.downcase.index(blacklist) }
          @response['images'] << path if under_returned_images_limit?
        end
      end
    end

    def attach_host_scheme_to(path)
      uri = URI.parse(path)
      if !uri.host.present? || !uri.scheme.present?
        path.gsub!(/\/\//, '/')
        path = path[0] == "/" ? path[1..-1] : "#{@base_path}/#{path}"
        if !uri.host.present? && !uri.scheme.present?
          path = "#{scheme}://#{host}/#{path}"
        elsif uri.host.present? && !uri.scheme.present?
          path = "#{scheme}://#{path}"
        end
      end
      path
    end

    def under_returned_images_limit?
      if @image_limit
        @response['images'].size < @image_limit.to_i
      else
        true
      end
    end

    private

    def normalize_url(url)
      url = url.gsub(/(?<!:)[\/\.]+\//, '/')
    end
  end
end
