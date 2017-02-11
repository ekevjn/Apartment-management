class GroundHistory < ActiveRecord::Base
  # relationships
  belongs_to :ground
  belongs_to :citizen

  # headers for excel
  HEADERS = ["id",  "Mặt bằng", "Cư dân", "Ngày đến", "Ngày rời đi" ]

  HEADER_COLUMNS = %w(id ground_name citizen_name come_date end_date)

  # methods
  def ground_name
    if ground.present?
      ground.name
    else
      ''
    end
  end

  def citizen_name
    if citizen.present?
      citizen.name
    else
      ''
    end
  end

  def come_date_text
    if come_date.present?
      come_date.strftime("%d/%m/%Y")
    else
      ''
    end
  end

  def end_date_text
    if end_date.present?
      end_date.strftime("%d/%m/%Y")
    else
      ''
    end
  end


  def self.search(search)
    if search
      grounds  = Ground.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      citizens = Citizen.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("ground_id in (:ground_ids) or citizen_id in (:citizen_ids)",
        { :ground_ids => grounds.map(&:id), :citizen_ids => citizens.map(&:id) })
    else
      all
    end
  end
end
