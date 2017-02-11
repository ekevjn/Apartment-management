class TowersSearchTerm
  attr_reader :where_clause, :where_args

  def initialize(search_term)
    search_term = search_term.downcase
    @where_clause = ""
    @where_args = {}
    if search_term =~ /@/
      build_for_email_search(search_term)
    else
      build_for_name_search(search_term)
    end
  end

  def build_for_name_search(search_term)
    @where_clause << case_insensitive_search(:name)
    @where_args[:name] = starts_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:subdomain)}"
    @where_args[:subdomain] = starts_with(search_term)

    @where_clause << " OR #{case_insensitive_search(:email)}"
    @where_args[:email] = starts_with(search_term)
  end

  def build_for_email_search(search_term)
    @where_clause << case_insensitive_search(:email)
    @where_args[:email] = search_term
  end

  def starts_with(search_term)
    search_term + "%"
  end

  def case_insensitive_search(field_name)
    "lower(#{field_name}) like :#{field_name}"
  end
end
