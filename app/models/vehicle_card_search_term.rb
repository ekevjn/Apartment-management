class VehicleCardSearchTerm
  attr_reader :where_clause, :where_args

  def initialize(search_term)
    search_term = search_term.downcase
    @where_clause = ""
    @where_args = {}
    build_for_ground_id_search(search_term)
  end

  def build_for_ground_id_search(search_term)
    @where_clause << case_insensitive_search(:ground_id)
    @where_args[:ground_id] = starts_with(search_term)
  end

  def starts_with(search_term)
    search_term + "%"
  end

  def case_insensitive_search(field_name)
    "CAST(#{field_name} AS TEXT) like :#{field_name}"
  end
end
