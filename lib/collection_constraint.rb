class CollectionConstraint
  def matches?(request)
    group_param = request.params[:group]
    return false if group_param.blank?
    return true unless group_param.match?(/^ark/)

    begin
      return Group.find(group_param) ? true : false
    rescue LdapMixin::LdapException
      return false
    end
  end
end
