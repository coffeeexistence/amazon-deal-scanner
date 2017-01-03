class QueryBuilder
  
  def self.query_string_from_hash(params)
    params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')
  end
  
end