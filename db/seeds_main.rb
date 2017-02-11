if Admin.find_by_email("admin@example.com").nil?
  Admin.create!(email: "admin@example.com",
    password: "password",
    password_confirmation: "password")
end

if Tower.all.count <= 5
  5.times do |i|
    Tower.create!(
      name: Faker::Name.name,
      area: Faker::Number.number(3) +  "x" + Faker::Number.number(3),
      address: Faker::Address.street_address,
      phone: Faker::PhoneNumber.cell_phone,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      password: 'password',
      password_confirmation: 'password',
      symbol: Faker::Lorem.word,
      fax: Faker::PhoneNumber.phone_number,
      taxcode: Faker::Number.number(10),
      subdomain: Faker::Internet.domain_word + Faker::Number.number(3),
      status: Faker::Lorem.word,
      manager_name: Faker::Name.name,
      management_board: Faker::Company.name,
      bank_no: Faker::Number.number(12),
      receiver_name: Faker::Name.name,
      bank_name: Faker::Company.name + " bank",
      bank_eng: Faker::Company.name + " bank",
      payment_date: 1,
      price_water_lv1: 8000,
      price_water_lv2: 10000,
      price_water_lv3: 12000,
      price_service: 800,
      price_hygiene: 7000,
      del_flg: 0
    )
  end
end
# if Building.all.count <= 100
#   10.times do |i|
#     Building.create!(
#       name: Faker::Name.name,
#       num_floors: 69
#       )
#   end
# end

Account.create!(email: "account@example.com",
    password: "password",
    password_confirmation: "password")

# if Ground.all.count <= 10
#   10.times do |i|
#     Ground.create!(
#       name: Faker::Name.name,
#       area_length: Faker::Number.number(2),
#       area_width: Faker::Number.number(2),
#       kind: "Room",
#       status: "Đang sử dụng",
#       building_id: Building.first.id,
#       num_rooms: Faker::Number.number(1),
#       num_citizens: Faker::Number.number(1),
#       num_citizen_cards: Faker::Number.number(1),
#       charge_time: Faker::Date.between(2.days.ago, Date.today),
#       del_flg: 0
#     )
#   end
# end

# if Citizen.all.count <= 10
#   100.times do |i|
#     Citizen.create!(
#       name: Faker::Name.name,
#       ground_id: Ground.first.id,
#       phone: Faker::PhoneNumber.cell_phone,
#       email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
#       gender: 1,
#       dob: Faker::Time.backward(14000, :evening),
#       nationality: Faker::Address.country,
#       is_water_deal: 0,
#       del_flg: 0
#       )
#   end
# end

# # forein key to Ground
# Ground.all.each do |g|
#   g.owner_id = Citizen.first.id
#   g.save
# end

# if CitizenCard.all.count <= 10
#   10.times do |i|
#     CitizenCard.create!(
#       ground_id: Ground.first.id,
#       status: "Available",
#       del_flg: 0
#       )
#   end
# end

# if Facility.all.count <= 10
#   10.times do |i|
#     Facility.create!(
#       name: Faker::Name.name,
#       status: "Available",
#       position: "Floor" + Faker::Number.number(1),
#       building_id: Building.first.id,
#       guarantee_time: Faker::Date.forward(2155),
#       guarantee_company: Faker::Company.name,
#       buy_time: Faker::Date.backward(1434),
#       del_flg: 0
#       )
#   end
# end

# Water.all.each do |water|
#   water.water_num = Faker::Number.number(2)
#   water.save!
# end

# if VehicleCard.all.count <= 10
#   10.times do |i|
#     VehicleCard.create!(
#       vehicle_type: "Car",
#       ground_id: Ground.first.id,
#       citizen_id: Citizen.first.id,
#       charge_time: Faker::Date.backward(143),
#       created_fee: Faker::Number.number(3).to_i * 1000,
#       outdate_time: Faker::Date.forward(2155),
#       registered_time: Faker::Date.backward(143),
#       status: "Available",
#       license_no: "L" + Faker::Number.number(8) + ".No",
#       description: Faker::Hipster.sentence,
#       del_flg: 0
#     )
#   end
# end

# if VehicleFinance.all.count <= 10
#   10.times do |i|
#     VehicleFinance.create!(
#       vehicle_card_id: VehicleCard.first.id,
#       ground_id: Ground.first.id,
#       citizen_id: Citizen.first.id,
#       debt: Faker::Number.number(3).to_i * 1000,
#       paid: Faker::Number.number(3).to_i * 1000,
#       fee: Faker::Number.number(3).to_i * 1000,
#       started_time: Faker::Date.backward(143),
#       is_current: true
#     )
#   end
# end

# create tower with no information at all
if !Tower.find_by_subdomain('golden').present?
  Tower.create!(
    name: 'golden',
    area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
    address: Faker::Address.street_address,
    phone: "0052455566",
    email: "golden@example.com",
    password: 'password',
    password_confirmation: 'password',
    symbol: 'golden',
    fax: Faker::PhoneNumber.phone_number,
    taxcode: Faker::Number.number(10),
    subdomain: 'golden',
    status: 'available',
    manager_name: Faker::Name.name,
    management_board: Faker::Company.name,
    bank_no: Faker::Number.number(12),
    receiver_name: Faker::Name.name,
    bank_name: Faker::Company.name + " bank",
    bank_eng: Faker::Company.name + " bank",
    del_flg: 0
  )
end

# creat tower to close finances
# Prepare data to preview
if !Tower.find_by_subdomain('close').present?
  # create tower
  day = Date.today.next_day.day
  day = 28 if day > 28
  Tower.create!(
    name: 'close',
    area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
    address: Faker::Address.street_address,
    phone: "878978767",
    email: "close@example.com",
    password: 'password',
    password_confirmation: 'password',
    symbol: 'close',
    fax: Faker::PhoneNumber.phone_number,
    taxcode: Faker::Number.number(10),
    subdomain: 'close',
    status: 'available',
    manager_name: Faker::Name.name,
    management_board: Faker::Company.name,
    bank_no: Faker::Number.number(12),
    receiver_name: Faker::Name.name,
    bank_name: Faker::Company.name + " bank",
    bank_eng: Faker::Company.name + " bank",
    payment_date: day,
    price_water_lv1: 8000,
    price_water_lv2: 10000,
    price_water_lv3: 12000,
    price_service: 8000,
    price_hygiene: 7000,
    price_bicycle: 30000,
    price_electric_bicycle: 40000,
    price_motorbike: 60000,
    price_car_4_seat: 100000,
    price_car_7_seat: 150000,
    del_flg: 0
  )

  # switch to subdomain database
  Apartment::Tenant.switch!("close")

  # create building
  Building.create!(
    name: "Dom A",
    num_floors: 5
  )
  Building.create!(
    name: "Dom B",
    num_floors: 5
  )

  # create grounds first floor
  12.times do |i|
    name = (i < 10) ? "A10" : "A1"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create grounds second floor
  12.times do |i|
    name = (i < 10) ? "A20" : "A2"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Đất kinh doanh",
      floor: 2,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create grounds third floor
  12.times do |i|
    name = (i < 10) ? "A30" : "A3"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Kiot ẩm thực",
      floor: 3,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  12.times do |i|
    name = (i < 10) ? "A40" : "A4"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 4,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  12.times do |i|
    name = (i < 10) ? "B10" : "B1"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom B").id,
      num_rooms: 3,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create citizens
  40.times do |i|
    Citizen.create!(
      name: Faker::Name.name,
      ground_id: (i + 1),
      phone: Faker::PhoneNumber.cell_phone,
      government_id: Faker::Number.number(12),
      hometown: Faker::Address.city,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      gender: (i % 2),
      dob: Faker::Date.backward(143),
      nationality: 'Việt Nam',
      is_water_deal: false,
      del_flg: 0
    )
  end

  # Set owner to ground
  40.times do |i|
    g = Ground.find_by_id(i+1)
    g.owner_id = i + 1
    g.save
  end

  # create service lastmonth
  Ground.count.times do |i|
    Service.create!(
      ground_id: (i+1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: true
    )
  end

  # create water lastmonth
  Ground.count.times do |i|
    Water.create!(
      ground_id: (i+1),
      water_no: Faker::Number.number(1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: true
    )
  end

  # create vehicle cards
  Citizen.count.times do |i|
    c = Citizen.find_by(:id => (i+1))
    VehicleCard.create!(
      card_no: "CV." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[(i%5)],
      ground_id: c.ground.id,
      citizen_id: c.id,
      started_time: Faker::Date.backward(143),
      created_fee: Faker::Number.number(3).to_i * 1000,
      outdate_time: Faker::Date.forward(2155),
      registered_time: Faker::Date.backward(143),
      status: VehicleCard::STATUS[0],
      license_no: "L" + Faker::Number.number(8) + ".No",
      description: Faker::Hipster.sentence
    )
  end

  # create vehicle finances last month
  VehicleCard.count.times do |i|
    VehicleFinance.create!(
      vehicle_card_id: (i+1),
      debt: Faker::Number.number(2).to_i * 1000,
      paid: Faker::Number.number(2).to_i * 1000,
      started_time: Date.today.last_month,
      is_current: true
    )
    vehicle_card = VehicleCard.find_by(:id => (i+1))
    vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
  end

  # Switch to main database
  Apartment::Tenant.switch
end


# Prepare data to preview
if !Tower.find_by_subdomain('royal').present?
  # create tower
  Tower.create!(
    name: 'royal',
    area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
    address: Faker::Address.street_address,
    phone: "01208441160",
    email: "royal@example.com",
    password: 'password',
    password_confirmation: 'password',
    symbol: 'royal',
    fax: Faker::PhoneNumber.phone_number,
    taxcode: Faker::Number.number(10),
    subdomain: 'royal',
    status: 'available',
    manager_name: Faker::Name.name,
    management_board: Faker::Company.name,
    bank_no: Faker::Number.number(12),
    receiver_name: Faker::Name.name,
    bank_name: Faker::Company.name + " bank",
    bank_eng: Faker::Company.name + " bank",
    payment_date: 3,
    price_water_lv1: 8000,
    price_water_lv2: 10000,
    price_water_lv3: 12000,
    price_service: 8000,
    price_hygiene: 7000,
    price_bicycle: 30000,
    price_electric_bicycle: 40000,
    price_motorbike: 60000,
    price_car_4_seat: 100000,
    price_car_7_seat: 150000,
    del_flg: 0
  )

  # switch to subdomain database
  Apartment::Tenant.switch!("royal")

  # create building
  Building.create!(
    name: "Dom A",
    num_floors: 5
  )
  Building.create!(
    name: "Dom B",
    num_floors: 5
  )
  Building.create!(
    name: "Dom C",
    num_floors: 5
  )
  Building.create!(
    name: "Dom D",
    num_floors: 5
  )

  # create grounds first floor
  12.times do |i|
    name = (i < 10) ? "A10" : "A1"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create grounds second floor
  12.times do |i|
    name = (i < 10) ? "A20" : "A2"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Đất kinh doanh",
      floor: 2,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create grounds third floor
  12.times do |i|
    name = (i < 10) ? "A30" : "A3"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Kiot ẩm thực",
      floor: 3,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  12.times do |i|
    name = (i < 10) ? "A40" : "A4"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 4,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  12.times do |i|
    name = (i < 10) ? "B10" : "B1"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom B").id,
      num_rooms: 3,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create facilities
  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: Facility::STATUS[1],
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom A").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: "Chưa sử dụng",
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom B").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: "Bị hỏng",
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom A").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  #Seeds for maintains
  20.times do |i|
    Maintain.create!(
    facility_id: Facility.find_by_status(Facility::STATUS[1]).id,
    fixed_time: Faker::Time.backward(365, :morning),
    price: Faker::Number.number(3).to_i * 1000,
    description: "Người đã tiến hành việc sửa chữa là " + Faker::Pokemon.name
    )
  end

  20.times do |i|
    Maintain.create!(
    facility_id: Facility.find_by_status("Bị hỏng").id,
    fixed_time: Faker::Time.backward(365, :morning),
    price: Faker::Number.number(3).to_i * 1000,
    description: "Người đã tiến hành việc sửa chữa là " + Faker::Pokemon.name
    )
  end

  # create citizens
  40.times do |i|
    Citizen.create!(
      name: Faker::Name.name,
      ground_id: (i + 1),
      phone: Faker::PhoneNumber.cell_phone,
      government_id: Faker::Number.number(12),
      hometown: Faker::Address.city,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      gender: (i % 2),
      dob: Faker::Date.backward(143),
      nationality: 'Việt Nam',
      is_water_deal: false,
      del_flg: 0
    )
  end

  10.times do |i|
    Citizen.create!(
      name: Faker::Name.name,
      ground_id: (10 - i),
      phone: Faker::PhoneNumber.cell_phone,
      government_id: Faker::Number.number(12),
      hometown: Faker::Address.city,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      gender: ((i+1) % 2),
      dob: Faker::Time.backward(14000, :evening),
      nationality: Faker::Address.country,
      is_water_deal: true,
      del_flg: 0
    )
  end

  # Set owner to ground
  40.times do |i|
    g = Ground.find_by_id(i+1)
    g.owner_id = i + 1
    g.save
  end

  # create service lastmonth
  Ground.count.times do |i|
    Service.create!(
      ground_id: (i+1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: false
    )
  end

  # create water lastmonth
  Ground.count.times do |i|
    Water.create!(
      ground_id: (i+1),
      water_no: Faker::Number.number(1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: false
    )
  end

  # create service current month
  25.times do |i|
    ground = Ground.find(i+1).update(:status => Ground::STATUS_USED)
    Service.create!(
      ground_id: (i+1),
      debt: 0,
      paid: 0,
      started_time: Date.today,
      is_current: true
    )
  end

  # create water current month
  25.times do |i|
    Water.create!(
      ground_id: (i+1),
      water_no: Faker::Number.number(2),
      debt: 0,
      paid: 0,
      started_time: Date.today,
      is_current: true
    )
  end

  # create vehicle cards
  Citizen.count.times do |i|
    c = Citizen.find_by(:id => (i+1))
    VehicleCard.create!(
      card_no: "CV." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[(i%5)],
      ground_id: c.ground.id,
      citizen_id: c.id,
      started_time: Faker::Date.backward(143),
      created_fee: Faker::Number.number(3).to_i * 1000,
      outdate_time: Faker::Date.forward(2155),
      registered_time: Faker::Date.backward(143),
      status: VehicleCard::STATUS[0],
      license_no: "L" + Faker::Number.number(8) + ".No",
      description: Faker::Hipster.sentence
    )
  end

  # create more vehicle cards for 12 citizen
  12.times do |i|
    c = Citizen.find_by(:id => (i+1))
    VehicleCard.create!(
      card_no: "CV." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[3],
      ground_id: c.ground.id,
      citizen_id: c.id,
      started_time: Faker::Date.backward(143),
      created_fee: Faker::Number.number(2).to_i * 1000,
      outdate_time: Faker::Date.forward(2155),
      registered_time: Faker::Date.backward(143),
      status: VehicleCard::STATUS[0],
      license_no: "L" + Faker::Number.number(6) + ".No",
      description: Faker::Hipster.sentence
    )
  end

  # create vehicle finances last month
  VehicleCard.count.times do |i|
    VehicleFinance.create!(
      vehicle_card_id: (i+1),
      debt: Faker::Number.number(2).to_i * 1000,
      paid: Faker::Number.number(2).to_i * 1000,
      started_time: Date.today.last_month,
      is_current: false
    )
    vehicle_card = VehicleCard.find_by(:id => (i+1))
    vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
  end

  # create vehicle finances current month
  VehicleCard.count.times do |i|
    VehicleFinance.create!(
      vehicle_card_id: (i+1),
      ground_id: (i+1),
      debt: Faker::Number.number(2).to_i * 1000,
      paid: Faker::Number.number(2).to_i * 1000,
      started_time: Date.today,
      is_current: true
    )
  end

  # create citizen cards
  Ground.count.times do |i|
    CitizenCard.create!(
      card_no: "C." + Faker::Number.number(6),
      ground_id: (i+1),
      status: CitizenCard::STATUS_AVAILABLE
    )
  end

  # Switch to main database
  Apartment::Tenant.switch
end

# Prepare data to preview for import excel
if !Tower.find_by_subdomain('vincom').present?
  # create tower
  Tower.create!(
    name: 'vincom',
    area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
    address: "114 Mai Hắc Đế, Hai Bà Trưng",
    phone: "01208441160",
    email: "vincom@example.com",
    password: 'password',
    password_confirmation: 'password',
    symbol: 'vincom',
    fax: Faker::PhoneNumber.phone_number,
    taxcode: Faker::Number.number(10),
    subdomain: 'vincom',
    status: 'đang sử dụng',
    manager_name: "Nguyễn Văn An",
    management_board: "Vinhomes Serviced Residences",
    bank_no: Faker::Number.number(12),
    receiver_name: Faker::Name.name,
    bank_name: "Ngân hàng Á Châu",
    bank_eng: "ACB Bank",
    payment_date: 3,
    price_water_lv1: 6000,
    price_water_lv2: 10000,
    price_water_lv3: 12000,
    price_service: 8000,
    price_hygiene: 7000,
    price_bicycle: 30000,
    price_electric_bicycle: 40000,
    price_motorbike: 60000,
    price_car_4_seat: 100000,
    price_car_7_seat: 150000,
    del_flg: 0
  )

  # switch to subdomain database
  Apartment::Tenant.switch!("vincom")

  # create building
  Building.create!(
    name: "Dom A",
    num_floors: 5
  )
  Building.create!(
    name: "Dom B",
    num_floors: 5
  )
  Building.create!(
    name: "Dom C",
    num_floors: 5
  )
  Building.create!(
    name: "Dom D",
    num_floors: 5
  )

  # create grounds first floor
  10.times do |i|
    Ground.create!(
      name: "A10#{i}",
      area_length: Faker::Number.number(1),
      area_width: Faker::Number.number(1),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4
    )
  end

  # create grounds second floor
  10.times do |i|
    Ground.create!(
      name: "A20#{i}",
      area_length: Faker::Number.number(1),
      area_width: Faker::Number.number(1),
      kind: "Căn hộ",
      floor: 2,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4
    )
  end

  # create grounds third floor
  10.times do |i|
    Ground.create!(
      name: "A30#{i}",
      area_length: Faker::Number.number(1),
      area_width: Faker::Number.number(1),
      kind: "Căn hộ",
      floor: 3,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4
    )
  end

  # create grounds fourth floor
  10.times do |i|
    Ground.create!(
      name: "A40#{i}",
      area_length: Faker::Number.number(1),
      area_width: Faker::Number.number(1),
      kind: "Đất kinh doanh",
      floor: 4,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create grounds fifth floor
  10.times do |i|
    Ground.create!(
      name: "A50#{i}",
      area_length: Faker::Number.number(1),
      area_width: Faker::Number.number(1),
      kind: "Kiot ẩm thực",
      floor: 4,
      building_id: Building.find_by_name("Dom A").id,
      num_rooms: 4,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  12.times do |i|
    name = (i < 10) ? "B10" : "B1"
    Ground.create!(
      name: "#{name}#{i}",
      area_length: Faker::Number.number(2),
      area_width: Faker::Number.number(2),
      kind: "Căn hộ",
      floor: 1,
      building_id: Building.find_by_name("Dom B").id,
      num_rooms: 3,
      num_citizens: 0,
      num_citizen_cards: 0,
      del_flg: 0
    )
  end

  # create facilities
  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: Facility::STATUS[1],
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom A").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: "Chưa sử dụng",
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom B").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  10.times do |i|
    Facility.create!(
      name: Faker::Name.name,
      status: "Bị hỏng",
      position: "Floor " + Faker::Number.digit,
      building_id: Building.find_by_name("Dom A").id,
      guarantee_time: Faker::Time.forward(365, :morning),
      guarantee_company: Faker::Company.name,
      buy_time: Faker::Time.backward(365, :morning),
      del_flg: 0
    )
  end

  #Seeds for maintains
  20.times do |i|
    Maintain.create!(
    facility_id: Facility.find_by_status(Facility::STATUS[1]).id,
    fixed_time: Faker::Time.backward(365, :morning),
    price: Faker::Number.number(3).to_i * 1000,
    description: "Người đã tến hành việc sửa chữa là " + Faker::Pokemon.name
    )
  end

  20.times do |i|
    Maintain.create!(
    facility_id: Facility.find_by_status("Bị hỏng").id,
    fixed_time: Faker::Time.backward(365, :morning),
    price: Faker::Number.number(3).to_i * 1000,
    description: "Người đã tến hành việc sửa chữa là " + Faker::Pokemon.name
    )
  end

  # create citizens
  40.times do |i|
    Citizen.create!(
      name: Faker::Name.name,
      ground_id: (i + 1),
      phone: Faker::PhoneNumber.cell_phone,
      government_id: Faker::Number.number(12),
      hometown: Faker::Address.city,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      gender: (i % 2),
      dob: Faker::Date.backward(143),
      nationality: 'Việt Nam',
      is_water_deal: false,
      del_flg: 0
    )
  end

  10.times do |i|
    Citizen.create!(
      name: Faker::Name.name,
      ground_id: (10 - i),
      phone: Faker::PhoneNumber.cell_phone,
      government_id: Faker::Number.number(12),
      hometown: Faker::Address.city,
      email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
      gender: ((i+1) % 2),
      dob: Faker::Time.backward(14000, :evening),
      nationality: Faker::Address.country,
      is_water_deal: true,
      del_flg: 0
    )
  end

  # Set owner to ground
  40.times do |i|
    g = Ground.find_by_id(i+1)
    g.owner_id = i + 1
    g.save
  end

  # create service lastmonth
  Ground.count.times do |i|
    Service.create!(
      ground_id: (i+1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: false
    )
  end

  # create water lastmonth
  Ground.count.times do |i|
    Water.create!(
      ground_id: (i+1),
      water_no: Faker::Number.number(1),
      debt: 0,
      paid: 0,
      started_time: Date.today.last_month,
      is_current: false
    )
  end

  # create service current month
  25.times do |i|
    ground = Ground.find(i+1).update(:status => Ground::STATUS_USED)
    Service.create!(
      ground_id: (i+1),
      debt: 0,
      paid: 0,
      started_time: Date.today,
      is_current: true
    )
  end

  # create water current month
  25.times do |i|
    Water.create!(
      ground_id: (i+1),
      water_no: Faker::Number.number(2),
      debt: 0,
      paid: 0,
      started_time: Date.today,
      is_current: true
    )
  end

  # create vehicle cards
  Citizen.count.times do |i|
    c = Citizen.find_by(:id => (i+1))
    VehicleCard.create!(
      card_no: "CV." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[(i%5)],
      ground_id: c.ground.id,
      citizen_id: c.id,
      started_time: Faker::Date.backward(143),
      created_fee: Faker::Number.number(3).to_i * 1000,
      outdate_time: Faker::Date.forward(2155),
      registered_time: Faker::Date.backward(143),
      status: VehicleCard::STATUS[0],
      license_no: "L" + Faker::Number.number(8) + ".No",
      description: Faker::Hipster.sentence
    )
  end

  # create more vehicle cards for 12 citizen
  12.times do |i|
    c = Citizen.find_by(:id => (i+1))
    VehicleCard.create!(
      card_no: "CV." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[3],
      ground_id: c.ground.id,
      citizen_id: c.id,
      started_time: Faker::Date.backward(143),
      created_fee: Faker::Number.number(2).to_i * 1000,
      outdate_time: Faker::Date.forward(2155),
      registered_time: Faker::Date.backward(143),
      status: VehicleCard::STATUS[0],
      license_no: "L" + Faker::Number.number(6) + ".No",
      description: Faker::Hipster.sentence
    )
  end

  # create vehicle finances last month
  VehicleCard.count.times do |i|
    VehicleFinance.create!(
      vehicle_card_id: (i+1),
      debt: Faker::Number.number(2).to_i * 1000,
      paid: Faker::Number.number(2).to_i * 1000,
      started_time: Date.today.last_month,
      is_current: false
    )
    vehicle_card = VehicleCard.find_by(:id => (i+1))
    vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
  end

  # create vehicle finances current month
  VehicleCard.count.times do |i|
    VehicleFinance.create!(
      vehicle_card_id: (i+1),
      ground_id: (i+1),
      debt: Faker::Number.number(2).to_i * 1000,
      paid: Faker::Number.number(2).to_i * 1000,
      started_time: Date.today,
      is_current: true
    )
  end

  # create citizen cards
  Ground.count.times do |i|
    CitizenCard.create!(
      card_no: "C." + Faker::Number.number(6),
      ground_id: (i+1),
      status: CitizenCard::STATUS_AVAILABLE
    )
  end

  # Switch to main database
  Apartment::Tenant.switch
end
