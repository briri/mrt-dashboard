module ApplicationHelper
  def clean_id(id)
    if (md = id.to_s.match(/^(http:\/\/)(.*)$/)) then
      return URI.escape(md[2], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    else
      return id.to_s
    end
  end

  def maybe_link(val, raw=nil)
    if val.kind_of? RDF::URI then
      return "<a href=\"/show/#{clean_id(val)}#{if raw then "?raw" else "" end}\">#{val}</a>".html_safe
    else
      return val
    end
  end
end
