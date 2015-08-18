class String
  def slugize
    self.downcase.gsub(/[^a-zA-Z0-9]/, '-').gsub(/-{2,}/,'-').gsub(/\-$/,'')
  end
end
