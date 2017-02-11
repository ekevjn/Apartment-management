module CommonModule

  # return true if string parameter is an integer
  def is_integer(str)
    !!Integer(str)
  rescue ArgumentError, TypeError
    false
  end

  # open excel, csv
  def open_spreadsheet file
    case File.extname File.basename file.path
    when ".csv" then Roo::CSV.new file.path
    when ".xls" then Roo::Excel.new file.path
    when ".xlsx" then Roo::Excelx.new file.path
    else raise 'Định dạng file không đúng'
    end
  end

  # export to csv
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |record|
        csv << record.attributes.values_at(*column_names)
      end
    end
  end

  # check a ground finish paying finances or not
  def exist_finances?(ground)
    current_service(ground).present? || current_water(ground).present? || current_vehicle_finances(ground).present?
  end

  # check current finances for service
  def current_service(ground)
    Service.find_by('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end

  # check current finances for water
  def current_water(ground)
    Water.find_by('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end

  # check all current vehicle finances
  def current_vehicle_finances(ground)
    VehicleFinance.where('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end
end
