ActiveRecord::Base.transaction do

  if Admin.find_by_email("admin@gotower.net").blank?
    Admin.create!(email: "admin@gotower.net",
      password: "password",
      password_confirmation: "password")
  end

  if Tower.all.count <= 1
    4.times do |i|
      del_flg = 0
      if i == 0
        name = 'The Pride'
        subdomain = 'pride'
        email = 'theride@gmail.com'
        manager_name = 'Trần Văn Hiển'
        street_address = 'Tố Hữu, Hà Đông, Hà Nội'
        management_board = "Ban quản trị The Pride"
        bank_name = 'Ngân hàng VietcomBank'
        bank_eng = 'VietcomBank'
      elsif i == 1
        name = 'Dream Town'
        subdomain = 'dream'
        email = 'dream@gmail.com'
        manager_name = "Nguyễn Văn Cừ"
        street_address = 'Tây Mỗ, Từ Liêm, Hà Nội'
        management_board = "Ban quản trị Dream Town"
        bank_name = 'Ngân hàng Tiên Phong'
        bank_eng = 'TP Bank'
      elsif i == 2
        name = 'Complex Hà Đông'
        subdomain = 'complexhadong'
        email = 'complexhadong@gmail.com'
        manager_name = "Lê Hoàng Đạo"
        street_address = "Hà Đông, Hà Nội"
        management_board = "Ban quản trị Complex Hà Đông"
        bank_name = 'Ngân hàng Á Châu'
        bank_eng = 'ACB Bank'
      else
        name = 'Xa La'
        subdomain = 'xala'
        email = 'xala@gmail.com'
        manager_name = "Vũ Duy Khánh"
        street_address = "Khu đô thị Xa La, Phúc La, Hà Đông, Hà Nội"
        management_board = "Ban quản trị Xa La"
        bank_name = 'Ngân hàng Tiên Phong'
        bank_eng = 'TP Bank'
        del_flg = 1
      end

      Tower.create!(
        name: name,
        area: Faker::Number.number(3) +  "x" + Faker::Number.number(3),
        address: street_address,
        phone: Faker::PhoneNumber.cell_phone,
        email: email,
        password: 'password',
        password_confirmation: 'password',
        symbol: subdomain,
        fax: Faker::PhoneNumber.phone_number,
        taxcode: Faker::Number.number(10),
        subdomain: subdomain,
        status: 'Đang hoạt động',
        manager_name: manager_name,
        management_board: management_board,
        bank_no: Faker::Number.number(12),
        receiver_name: manager_name,
        bank_name: bank_name,
        bank_eng: bank_eng,
        payment_date: 1,
        price_water_lv1: 8000,
        price_water_lv2: 10000,
        price_water_lv3: 12000,
        price_service: 800,
        price_hygiene: 7000,
        del_flg: del_flg
      )
    end
  end

  # # Prepare empty data for subdomain
  # if !Tower.find_by_subdomain('golden').present?
  #   Tower.create!(
  #     name: 'golden',
  #     area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
  #     address: "137 Xuân Thủy, Cầu Giấy, Hà Nội",
  #     phone: "0052455566",
  #     email: "golden@gmail.com",
  #     password: 'password',
  #     password_confirmation: 'password',
  #     symbol: 'golden',
  #     fax: Faker::PhoneNumber.phone_number,
  #     taxcode: Faker::Number.number(10),
  #     subdomain: 'golden',
  #     status: 'Đang sử dụng',
  #     manager_name: "Phạm Tuấn Anh",
  #     management_board: "Ban quản lí Golden",
  #     bank_no: Faker::Number.number(12),
  #     receiver_name: "Phạm Tuấn Anh",
  #     bank_name: 'Ngân hàng Tiên Phong',
  #     bank_eng: 'TP bank',
  #     del_flg: 0
  #   )
  # end

  # create tower to close finances 1
  if !Tower.find_by_subdomain('rainbowlinhdam').present?
    name = 'Rainbow Linh Đàm'
    subdomain = 'rainbowlinhdam'
    email = 'rainbowlinhdam@gmail.com'
    manager_name = "Nguyễn Huy Hoàng"
    street_address = "Khu đô thị Bắc Linh Đàm, Đại Kim, Hoàng Mai, Hà Nội"
    management_board = "Ban quản trị Rainbow Linh Đàm"
    bank_name = 'Ngân hàng VietcomBank'
    bank_eng = 'VietcomBank'
    # create tower
    day = Date.today.next_day.day
    day = 28 if day > 28

    Tower.create!(
      name: name,
      area: Faker::Number.number(3) +  "x" + Faker::Number.number(3),
      address: street_address,
      phone: Faker::PhoneNumber.cell_phone,
      email: email,
      password: 'password',
      password_confirmation: 'password',
      symbol: subdomain,
      fax: Faker::PhoneNumber.phone_number,
      taxcode: Faker::Number.number(10),
      subdomain: subdomain,
      status: 'Đang hoạt động',
      manager_name: manager_name,
      management_board: management_board,
      bank_no: Faker::Number.number(12),
      receiver_name: manager_name,
      bank_name: bank_name,
      bank_eng: bank_eng,
      payment_date: day,
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
    Apartment::Tenant.switch!("rainbowlinhdam")

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
        debt: 0,
        paid: 0,
        started_time: Date.today.last_month,
        is_current: true
      )
      vehicle_card = VehicleCard.find_by(:id => (i+1))
      vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
    end

    # Switch to main database
    Apartment::Tenant.switch
  end

  # create tower to close finances 2
  if !Tower.find_by_subdomain('dormitory').present?
    # create tower
    day = Date.today.next_day.day
    day = 28 if day > 28
    Tower.create!(
      name: 'dormitory',
      area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
      address: "Km 29 đại lộ Thăng Long, Thạch Hòa, Thạch Thất, Hà Nội",
      phone: "878978767",
      email: "dormitory@gmail.com",
      password: 'password',
      password_confirmation: 'password',
      symbol: 'dormitory',
      fax: Faker::PhoneNumber.phone_number,
      taxcode: Faker::Number.number(10),
      subdomain: 'dormitory',
      status: 'Đang sử dụng',
      manager_name: "Đàm Quang Minh",
      management_board: "Ban quản trị FPT",
      bank_no: Faker::Number.number(12),
      receiver_name: "Đàm Quang Minh",
      bank_name: 'Ngân hàng Tiên Phong',
      bank_eng: 'TP bank',
      payment_date: day,
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
    Apartment::Tenant.switch!("dormitory")

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
        debt: 0,
        paid: 0,
        started_time: Date.today.last_month,
        is_current: true
      )
      vehicle_card = VehicleCard.find_by(:id => (i+1))
      vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
    end

    # Switch to main database
    Apartment::Tenant.switch
  end

  # Prepare main data to preview
  if !Tower.find_by_subdomain('royal').present?
    # create tower
    Tower.create!(
      name: 'Royal City',
      area: Faker::Number.number(3) +  " x " + Faker::Number.number(3),
      address: "72 Nguyễn Trãi, Thanh Xuân, Hà Nội",
      phone: "0967006666",
      email: "royal@example.com",
      password: 'password',
      password_confirmation: 'password',
      symbol: 'royal',
      fax: Faker::PhoneNumber.phone_number,
      taxcode: Faker::Number.number(10),
      subdomain: 'royal',
      status: 'Đang sử dụng',
      manager_name: "Phạm Nhật Vượng",
      management_board: "Ban quản lí Royal City",
      bank_no: Faker::Number.number(12),
      receiver_name: "Phạm Nhật Vượng",
      bank_name: "VietcomBank",
      bank_eng: "VietcomBank",
      picture: Rails.root.join("db/images/logo/royal.jpg").open,
      payment_date: 3,
      price_water_lv1: 6000,
      price_water_lv2: 10000,
      price_water_lv3: 12000,
      price_service: 6000,
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

    2.times do |i|
      if i == 0
        email = "subaccount"
      else
        email = "subroyal"
      end
      Account.create!(email: "#{email}@gotower.net",
        password: "password",
        password_confirmation: "password"
      )
    end

    # buildings
    3.times do |i|
      Building.create!(
        name: "Tòa R#{i+1}",
        num_floors: 5
      )
    end

    3.times do |t|
      buidlding_name = "Tòa R#{t+1}"
      5.times do |f|
        floor = f + 1
        if t == 2 && floor == 4
          kind = "Kiot ẩm thực"
        elsif t == 2 && floor == 5
          kind = "Đất kinh doanh"
        else
          kind =  "Căn hộ"
        end
        10.times do |i|
          Ground.create!(
            name: "R#{t+1}-#{floor}0#{i}",
            area_length: Faker::Number.number(1).to_i + 1,
            area_width: Faker::Number.number(1).to_i + 1,
            kind: kind,
            floor: floor,
            building_id: Building.find_by_name(buidlding_name).id,
            num_rooms: Faker::Number.number(1)
          )
        end
      end
    end

    # deactive grounds
    10.times do |i|
      Ground.create!(
        name: "R1-60#{i}",
        area_length: Faker::Number.number(1).to_i + 1,
        area_width: Faker::Number.number(1).to_i + 1,
        kind: "Đất kinh doanh",
        floor: 1,
        building_id: Building.find_by_name("Tòa R1").id,
        num_rooms: Faker::Number.number(1),
        del_flg: 1
      )
    end

    10.times do |i|
      g = Ground.find_by(:name => "R1-10#{i}")
      g.images = [ Rails.root.join("db/images/ground-r1-10#{i}-1.jpg").open,
                   Rails.root.join("db/images/ground-r1-10#{i}-2.jpg").open,
                   Rails.root.join("db/images/ground-r1-10#{i}-3.jpg").open ]
      g.save!
    end

    10.times do |i|
      g = Ground.find_by(:name => "R1-20#{i}")
      g.images = [ Rails.root.join("db/images/ground-r1-20#{i}.jpg").open ]
      g.save!
    end

    # fake hometowns
    fake_hometowns = [ "Hà Nội", "Đà Nẵng", "Bắc Ninh", "Vinh", "Bắc Giang",
        "Hà Tĩnh", "Nghệ An", "Hải Phòng", "Thanh Hóa", "Hà Giang" ]
    # main citizens for demo
    5.times do |i|
      if i == 0
        name = "Trần Lê Ngọc Huy"
        email = 'ngochuydev@gmail.com'
      elsif i == 1
        name = "Chu Quang Long"
        email = 'gnolmon@gmail.com'
      elsif i == 2
        name = "Nguyễn Công Sơn"
        email = 'sonncse03032@gmail.com'
      elsif i == 3
        name = "Hồ Việt Tuấn"
        email = 'vinamanapart@gmail.com'
      elsif i == 4
        name = "Vũ Đăng Trung"
        email = 'pearlohuy2@gmail.com'
      end
      Citizen.create!(
        name: name,
        ground_id: (i + 1),
        phone: Faker::PhoneNumber.cell_phone,
        government_id: Faker::Number.number(12),
        hometown: fake_hometowns[Faker::Number.number(1).to_i],
        email: email,
        gender: (i % 2),
        dob: Faker::Date.backward(365 * 30),
        nationality: 'Việt Nam',
        is_water_deal: true
      )
    end

    fake_names = [ "Vũ Thị Bạch Xuyến", "Hoàng Lan Anh", "Ngọ Thị Lan Anh", "Phạm Thị Chinh", "Bùi Văn Chính", "Hoàng Duy Đại", "Nguyễn Thị Đào", "Nguyễn Hữu Đức", "Nguyễn Thị Dung", "Đinh Thị Duyên", "Hồ Thị Gấm", "Đào Thị Giang", "Dương Thị Giảng", "Nguyễn Thị Hải", "Thân Thị Hằng", "Phạm Ngọc Hanh", "Nguyễn Thị Huế", "Phạm Thị Huế", "Trần Thị Thu Hương", "Phùng Thị Hường", "Nguyễn Thị Huyên", "Hoàng Thị Thanh Huyền", "Nguyễn Thị Huyền", "Hà Thị Lành", "Lê Thị Liên", "Nguyễn Thị Thùy Linh", "Nguyễn Thị Châu Loan", "Trịnh Văn Lộc", "Nguyễn Thanh Mai", "Đoàn Thị Quỳnh Mai", "Hoàng Thị Na", "Vũ Thị Thanh Nga", "Vũ Thị Kim Ngân", "Nguyễn Thị Thúy Ngân", "Bùi Thị Ngọc", "Đinh Thị Ngọt", "Trương Thị Hồng Nhung", "Nguyễn Thị Nữ", "Nguyễn Thị Oanh", "Nguyễn Thị Phương", "Cấn Đỗ Như Quyên", "Nguyễn Thị Quỳnh", "Phạm Văn Sang", "Trần Thị Thắm", "Nguyễn Thị Thu Thanh", "Phạm Thị Thanh", "Vũ Thị Thảo", "Nguyễn Thị Thảo", "Hoàng Thị Tới", "Nguyễn Thị Tuyến", "Tô Thị Ngọc Ánh", "Bùi Thị Thu Hà", "Nguyễn Thị Hải", "Lê Thị Thúy Hạnh", "Bùi Thị Mai Hồng", "Nguyễn Thị Huyền", "Nguyễn Thị Thành Lý", "Trần Thị Trà Mi", "Trần Thị Ngọc", "Khuất Minh Nguyệt", "Trần Thị Minh Phương", "Nguyễn Thị Thơm", "Đặng Thị Thanh Thúy", "Tạ Thị Vụ", "Nguyễn Thị Yến", "Phan Thanh Diệp", "Hoàng Thị Mai", "Trần Thị Oanh", "Nguyễn Quốc Nhật", "Nguyễn Văn Việt", "Nguyễn Thanh Bình", "Nguyễn Nhật Tân", "Nguyễn Đức Thiện", "Nguyễn Trung Thao", "Đỗ Thị Dung", "Nguyễn Hồng Nhâm", "Trần Thị Phượng", "Nguyễn Thị Hải", "Trương Thị Mến", "Nguyễn Thị Hậu", "Đỗ Thị Kim Trang", "Vũ Thị Thu Hương", "Nguyễn Thị Bích  Ngọc", "Nguyễn Thị Hồng", "Nguyễn Thị Vương", "Ngô Thị Hải  Hà", "Trương Thu  Hằng", "Võ Thị Bích  Ngà", "Nguyễn Thị Hoa", "Trần Thị Nhàn", "Nguyễn Thị Thùy Linh", "Lê Thị Ngọc Hoa", "Nguyễn Thị Liên", "Hoàng Thị Nga", "Trịnh Thị Thúy Quỳnh", "Phạm Văn Tuyên", "Nguyễn Lập Đức", "Hứa Thị Lan Giang", "Ngô Thị Lan Anh", "Phạm Thị Loan", "Nghiêm Thị Kim Oanh", "Trịnh Thị Thanh", "Nguyễn Văn Tuân", "Lương Thanh Yên", "Mai Hoàn Thu", "Khuất Thị Thu Trang", "Nguyễn Thị Ơn", "Nguyễn Thanh An", "Vũ Thị Nhài", "Nguyễn Thị Mai", "Phạm Thị Liên", "Vũ Thanh Cầm", "Nguyễn Trung Anh Tuấn", "Vũ Thị Hường", "Nguyễn Thị Hồng Vân", "Phan Thị Mỹ Hạnh", "Nhữ Thị Minh Châu", "Nguyễn Thị Thanh Loan", "Bùi Thị Thu Hiền", "Lê Thị Huế", "Vũ Thị Luyên", "Nguyễn Thị Ánh Diễm", "Nguyễn Thị Thủy", "Đậu Thị Thương", "Trần Quyết Thắng", "Lê Phương Thảo", "Phạm Thị Viền", "Bùi Mai Hương", "Lê Thị Tuyết", "Vũ Thị Thu", "Huỳnh Thị Phương Linh", "Dương Minh Tân", "Nguyễn Thị Huyền", "Nguyễn Thị Hữu", "Phan Thị Lam Hồng", "Nguyễn Thị Bích", "Vũ Thị Thêu", "Đoàn Thị Vân Anh", "Đồng Thị Diệu Thu", "Nguyễn Thị Hoài", "Bùi Thị Thủy", "Lê Thị Quỳnh", "Lê Thị Hà", "Ninh Thị Thu", "Nguyễn Thị Liễu", "Hoàng Thị Lý", "Vũ Thị Kim Dung", "Nguyễn Thị Việt Anh", "Ngô Thị Hiền", "Nguyễn Thị Ngọc Hân", "Đỗ Thị Minh Huệ", "Phạm Duy Huy Bình", "Nguyễn Thị Hằng", "Cao Thị Thúy Hải", "Hán Thị Huệ", "Hoàng Thị Lan Anh", "Nguyễn Thị Thu Hà", "Phạm Trọng Thưởng", "Đỗ Văn Thế", "Trần Thị Thu Trang", "Đỗ Thị Thu", "Vũ Thị Thanh Hoan", "Nguyễn Thị Thắm", "Thiều Kim Hoàn", "Nguyễn Thị Thu Thủy", "Trần thị Hà", "Nguyễn Thu Hoài", "Lê Thị Trang", "Nguyễn Thị Vân Anh", "Nguyễn Thị Ngọc Ly", "Trần Anh Nhàn", "Đỗ Thị Nghĩa Tình", "Nguyễn Thị Phương", "Nguyễn Thị Thúy Hằng", "Phạm Thị Thúy", "Lê Thị Kim Anh", "Trịnh Duy Hùng", "Đỗ Thị Hồng", "Nguyễn Thị Huyền Trang", "Phùng Thị Thái", "Mai Thanh Khả", "Phùng Thị Mai Phương", "Phùng Thị Vân", "Võ Thị Hạnh", "Lê Thị Hồng Nhung", "Nguyễn Thế Xuân", "Nguyễn Thị Thu Mai", "Nguyễn Thị Thùy Linh", "Vũ Thị Duyên", "Đào Thị Hường", "Nguyễn Thị Hường", "Lê Thị Trang", "Bùi Thị Thương", "Đỗ Thị Phương", "Chu Thị Ngọc Thanh", "Trương Đức Hải", "Giang Thi Thoa", "Nguyễn Thị Trang", "Trần Quốc Toản", "Đặng Anh Tuấn" ]
    # citizens
    200.times do |i|
      ground_id = i + 1
      ground_id = i - 99 if i > 100
      Citizen.create!(
        name: fake_names[i],
        ground_id: ground_id,
        phone: Faker::PhoneNumber.cell_phone,
        government_id: Faker::Number.number(12),
        hometown: fake_hometowns[Faker::Number.number(1).to_i],
        email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
        gender: (i % 2),
        dob: Faker::Date.backward(365 * 30),
        nationality: 'Việt Nam',
        is_water_deal: ((i % 5 == 0) ? true : false)
      )
    end

    # deactive citizens
    deactive_citizen_names = [ "Trần Chung Thành", "Bùi Văn Phúc", "Phạm Văn Tú", "Nguyễn Nhật Minh", "Nguyễn Phan Anh", "Chu Văn Khánh", "Nguyễn Đức Nhật", "Trần Đăng Quân", "Lê Minh Tú", "Trần Quốc Tuấn" ]
    10.times do |i|
      Citizen.create!(
        name: deactive_citizen_names[i],
        phone: Faker::PhoneNumber.cell_phone,
        government_id: Faker::Number.number(12),
        hometown: fake_hometowns[Faker::Number.number(1).to_i],
        email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
        gender: (i % 2),
        dob: Faker::Date.backward(365 * 30),
        nationality: 'Việt Nam',
        is_water_deal: false,
        del_flg: 1
      )
    end

    more_citizen_names = [ "Nguyễn Trọng Quỳnh", "Lê Chí Công", "Đỗ Minh Thắng", "Đào Thị Hương Lan", "Trần Đức Minh", "Nguyễn Đồng Tuấn Hải", "Đỗ Ngọc Điều", "Trương Gia Huy", "Triệu Hải Nam", "Nguyễn Thùy Dương", "Mai Thị Hải Yến", "Phan Thế Cầm", "Bùi Minh Quang", "Đỗ Hải Yến", "Nguyễn Thị Chúc", "Đặng Thị Bình", "Trịnh Quốc Thăng", "Nguyễn Thị Dung", "Đoàn Xuân Lâm", "Đoàn Bích Phương", "Đỗ Xuân Thanh Vương", "Nguyễn Lê Hưng", "Trần Khánh Như", "Nguyễn Thị Thùy Dương", "Phạm Ngọc Huyền", "Phùng Thị Hạnh", "Nguyễn Việt Phương Trinh", "Nguyễn Thị Tường Vân", "Bùi Cẩm Chi", "Hoàng Minh Kiên", "Nguyễn Minh Duy", "Nguyễn Thế Tú", "Bùi Ngọc Thắng", "Nguyễn Thị Dung", "Hoàng Thị Hải Vân", "Đỗ Duy Tiệp", "Nguyễn Thị Chinh", "Vũ Ngọc Lương", "Vũ Ngọc Trung", "Nguyễn Trọng Đức" ]
    20.times do |i|
      Citizen.create!(
        name: more_citizen_names[i],
        ground_id: (i + 121),
        phone: Faker::PhoneNumber.cell_phone,
        government_id: Faker::Number.number(12),
        hometown: fake_hometowns[Faker::Number.number(1).to_i],
        email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
        gender: (i % 2),
        dob: Faker::Date.backward(365 * 30),
        nationality: 'Việt Nam',
        is_water_deal: ((i % 5 == 0) ? true : false)
      )
    end

    citizen_no_ground_names = [ "Bùi Văn Nam", "Cấn Việt Đoàn", "Đặng Hòa Hảo", "Đặng Hoàng Hiệp", "Đào Khắc Mạnh" ]
    5.times do |i|
      Citizen.create!(
        name: citizen_no_ground_names[i],
        phone: Faker::PhoneNumber.cell_phone,
        government_id: Faker::Number.number(12),
        hometown: fake_hometowns[Faker::Number.number(1).to_i],
        email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}",
        gender: (i % 2),
        dob: Faker::Date.backward(365 * 50),
        nationality: 'Việt Nam',
        is_water_deal: false
      )
    end

    # facilities - đã sử dụng
    fake_facilities = [ "Bàn tiếp tân",
        "Camera R1-1", "Camera R1-2", "Camera R1-3", "Camera R1-4", "Camera R1-5",
        "Camera R2-1", "Camera R2-2", "Camera R2-3", "Camera R2-4", "Camera R2-5",
        "Camera R3-1", "Camera R3-2", "Camera R3-3", "Camera R3-4", "Camera R3-5",
        "Thang máy R1", "Thang máy R2", "Thang máy R3",
        "Sân bóng", "Quạt trần R1",  "Quạt trần R2",  "Quạt trần R3",
        "Điều hòa R1", "Điều hòa R2", "Điều hòa R3" ]

    fake_facility_locations = [ "Sảnh chờ tòa R1",
      "Tầng 1 tòa R1", "Tầng 2 tòa R1", "Tầng 3 tòa R1", "Tầng 4 tòa R1", "Tầng 5 tòa R1",
      "Tầng 1 tòa R2", "Tầng 2 tòa R2", "Tầng 3 tòa R2", "Tầng 4 tòa R2", "Tầng 5 tòa R2",
      "Tầng 1 tòa R3", "Tầng 2 tòa R3", "Tầng 3 tòa R3", "Tầng 4 tòa R3", "Tầng 5 tòa R3",
      "Trung tâm tòa R1", "Trung tâm tòa R2", "Trung tâm tòa R3",
      "Trước tòa R2", "Sảnh chờ tòa R1", "Sảnh chờ tòa R2", "Sảnh chờ tòa R3",
      "Sảnh chờ tòa R1", "Sảnh chờ tòa R2", "Sảnh chờ tòa R3" ]

    25.times do |i|
      if fake_facilities[i].include?('R2')
        building_name = "Tòa R2"
      elsif fake_facilities[i].include?('R3')
        building_name = "Tòa R3"
      else
        building_name = "Tòa R1"
      end
      Facility.create!(
        name: fake_facilities[i],
        status: Facility::STATUS[1],
        position: fake_facility_locations[i],
        building_id: Building.find_by_name(building_name).id,
        buy_time: Faker::Time.backward(365),
        guarantee_time: Faker::Time.forward(365),
        guarantee_company: "Công ty " + Faker::Company.name,
        del_flg: 0
      )
    end

    # facilities - còn mới
    new_fake_facilities = [ "Sân gôn", "Hồ bơi", "Ghế dài", "Bàn tròn", "Máy tính" ]

    new_fake_facility_locations = [ "Sau tòa R3", "Trung tâm của tòa R1",
        "Sảnh chờ R1", "Sảnh chờ R1", "Sảnh chở R1" ]

    5.times do |i|
      if i == 0
        building_name = "Tòa R3"
      else
        building_name = "Tòa R1"
      end
      Facility.create!(
        name: new_fake_facilities[i],
        status: Facility::STATUS[0],
        position: new_fake_facility_locations[i],
        building_id: Building.find_by_name(building_name).id,
        buy_time: Faker::Time.backward(365),
        guarantee_time: Faker::Time.forward(365),
        guarantee_company: "Công ty " + Faker::Company.name,
        del_flg: 0
      )
    end

    # facilities - bị hỏng
    broken_fake_facilities = [ "Tivi", "Máy đánh giày", "Ghế chờ", "Cây thông" ]

    4.times do |i|
      building_name = "Tòa R1"
      Facility.create!(
        name: broken_fake_facilities[i],
        status: Facility::STATUS[2],
        position: "Sảnh chở R1",
        building_id: Building.find_by_name(building_name).id,
        buy_time: Faker::Time.backward(365),
        guarantee_time: Faker::Time.forward(365),
        guarantee_company: "Công ty " + Faker::Company.name,
        del_flg: 0
      )
    end

    # maintains
    34.times do |i|
      facility = Facility.find_by_id(i+1)
      fixed_time = Faker::Time.between(facility.buy_time, facility.guarantee_time)
      Maintain.create!(
        facility_id: facility.id,
        fixed_time: fixed_time,
        price: Faker::Number.number(3).to_i * 1000,
        description: "Người đã tiến hành việc sửa chữa là " + fake_names[Faker::Number.between(0, 150)]
      )
    end

    # citizen cards
    Ground.count.times do |i|
      CitizenCard.create!(
        card_no: "CC." + Faker::Number.number(6),
        ground_id: (i+1),
        status: CitizenCard::STATUS_AVAILABLE
      )
    end

    # vehicle cards
    (Citizen.count - 50 ).times do |i|
      c = Citizen.find_by(:id => (i+1))
      registered_time = Faker::Date.backward(365)
      vehicle_type =  VehicleCard::VEHICLE_TYPE[(i%5)]

      VehicleCard.create!(
        card_no: "VC." + Faker::Number.number(6),
        vehicle_type: vehicle_type,
        ground_id: c.ground.id,
        citizen_id: c.id,
        started_time: registered_time,
        created_fee: Faker::Number.number(3).to_i * 1000,
        registered_time: registered_time,
        outdate_time: Faker::Date.forward(365),
        status: VehicleCard::STATUS_AVAILABLE,
        license_no: "L. " + Faker::Number.number(8),
        description: "#{vehicle_type} của cư dân #{c.name}."
      )
    end

    # vehicle finances for 1 year
    VehicleCard.count.times do |i|
      VehicleFinance.create!(
        vehicle_card_id: (i+1),
        debt: 0,
        paid: 0,
        started_time: Date.today.last_year.beginning_of_month,
        is_current: false
      )
    end

    11.times do |t|
      started_time = Date.today.last_year.beginning_of_month + (t+1).months
      VehicleCard.count.times do |i|
        if i > 0 && i <= 32 && i % 4 == 0 && t > 8
          lastest_vehicles = VehicleFinance.where("vehicle_card_id = #{i+1}").order(id: :desc)
          lastest_vehicle = lastest_vehicles.first
          VehicleFinance.create!(
            vehicle_card_id: (i+1),
            debt: (lastest_vehicle.debt + lastest_vehicle.fee - lastest_vehicle.paid),
            paid: 0,
            started_time: started_time,
            num_debt: (lastest_vehicle.num_debt + 1),
            is_current: false
          )
        else
          VehicleFinance.create!(
            vehicle_card_id: (i+1),
            debt: 0,
            paid: 0,
            started_time: started_time,
            is_current: false
          )
        end
      end
    end

    # current vehicle finance
    VehicleCard.count.times do |i|
      started_time = Date.today.beginning_of_month
      if i > 0 && i <= 32 && i % 4 == 0
        lastest_vehicles = VehicleFinance.where("vehicle_card_id = #{i+1}").order(id: :desc)
        lastest_vehicle = lastest_vehicles.first
        VehicleFinance.create!(
          vehicle_card_id: (i+1),
          debt: (lastest_vehicle.debt + lastest_vehicle.fee - lastest_vehicle.paid),
          paid: 0,
          started_time: started_time,
          num_debt: (lastest_vehicle.num_debt + 1),
          is_current: true
        )
      else
        VehicleFinance.create!(
          vehicle_card_id: (i+1),
          debt: 0,
          paid: 0,
          started_time: started_time,
          is_current: true
        )
      end
    end

    101.times do |i|
      g = Ground.find_by(:id => (i+1))
      g.status = Ground::STATUS_USED
      g.save!
    end

    # service for 1 year
    100.times do |i|
      Service.create!(
        ground_id: (i+1),
        debt: 0,
        paid: 0,
        started_time: Date.today.last_year.beginning_of_month,
        is_current: false
      )
    end

    11.times do |t|
      started_time = Date.today.last_year.beginning_of_month + (t+1).months
      100.times do |i|
        if i > 0 && i <= 32 && i % 4 == 0 && t > 8
          lastest_services = Service.where("ground_id = #{i+1}").order(id: :desc)
          lastest_service = lastest_services.first
          Service.create!(
            ground_id: (i+1),
            debt: (lastest_service.debt + lastest_service.fee - lastest_service.paid),
            paid: 0,
            started_time: started_time,
            num_debt: (lastest_service.num_debt + 1),
            is_current: false
          )
        else
          Service.create!(
            ground_id: (i+1),
            debt: 0,
            paid: 0,
            started_time: started_time,
            is_current: false
          )
        end
      end
    end

    # current service
    100.times do |i|
      started_time = Date.today.beginning_of_month
      if i > 0 && i <= 32 && i % 4 == 0
        lastest_services = Service.where("ground_id = #{i+1}").order(id: :desc)
        lastest_service = lastest_services.first
        Service.create!(
          ground_id: (i+1),
          debt: (lastest_service.debt + lastest_service.fee - lastest_service.paid),
          paid: 0,
          started_time: started_time,
          num_debt: (lastest_service.num_debt + 1),
          is_current: true
        )
      else
        Service.create!(
          ground_id: (i+1),
          debt: 0,
          paid: 0,
          started_time: started_time,
          is_current: true
        )
      end
    end

    # water for 1 year
    100.times do |i|
      Water.create!(
        ground_id: (i+1),
        debt: 0,
        paid: 0,
        water_no: Faker::Number.number(1),
        started_time: Date.today.last_year.beginning_of_month,
        is_current: false
      )
    end

    11.times do |t|
      started_time = Date.today.last_year.beginning_of_month + (t+1).months
      100.times do |i|
        lastest_waters = Water.where("ground_id = #{i+1}").order(id: :desc)
        lastest_water = lastest_waters.first
        if i > 0 && i <= 32 && i % 4 == 0 && t > 8
          Water.create!(
            ground_id: (i+1),
            debt: (lastest_water.debt + lastest_water.fee - lastest_water.paid),
            paid: 0,
            water_no: lastest_water.water_no + Faker::Number.between(4, 30),
            started_time: started_time,
            num_debt: (lastest_water.num_debt + 1),
            is_current: false
          )
        else
          Water.create!(
            ground_id: (i+1),
            debt: 0,
            paid: 0,
            water_no: lastest_water.water_no + Faker::Number.between(4, 30),
            started_time: started_time,
            is_current: false
          )
        end
      end
    end

    # current water
    100.times do |i|
      started_time = Date.today.beginning_of_month
      lastest_waters = Water.where("ground_id = #{i+1}").order(id: :desc)
      lastest_water = lastest_waters.first
      if i > 0 && i <= 32 && i % 4 == 0
        Water.create!(
          ground_id: (i+1),
          debt: (lastest_water.debt + lastest_water.fee - lastest_water.paid),
          paid: 0,
          water_no: lastest_water.water_no + Faker::Number.between(4, 30),
          started_time: started_time,
          num_debt: (lastest_water.num_debt + 1),
          is_current: true
        )
      else
        Water.create!(
          ground_id: (i+1),
          debt: 0,
          paid: 0,
          water_no: lastest_water.water_no + Faker::Number.between(4, 30),
          started_time: started_time,
          is_current: true
        )
      end
    end

    VehicleCard.create!(
      card_no: "VC." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[4],
      ground_id: Citizen.first.ground.id,
      citizen_id: Citizen.first.id,
      started_time: Faker::Date.backward(365),
      created_fee: Faker::Number.number(3).to_i * 1000,
      registered_time: Faker::Date.backward(365),
      outdate_time: Faker::Date.forward(365),
      status: VehicleCard::STATUS_AVAILABLE,
      license_no: "L. " + Faker::Number.number(8),
      description: "Chưa có mô tả"
    )

    VehicleCard.create!(
      card_no: "VC." + Faker::Number.number(6),
      vehicle_type: VehicleCard::VEHICLE_TYPE[4],
      ground_id: Citizen.second.ground.id,
      citizen_id: Citizen.second.id,
      started_time: Faker::Date.backward(365),
      created_fee: Faker::Number.number(3).to_i * 1000,
      registered_time: Faker::Date.backward(365),
      outdate_time: Faker::Date.forward(365),
      status: VehicleCard::STATUS_AVAILABLE,
      license_no: "L. " + Faker::Number.number(8),
      description: "Chưa có mô tả"
    )

    Post.create!(title: '"ĐẶC ĐIỂM NHẬN DIỆN” CỦA GIỚI THƯỢNG LƯU',
    content: '<p><em>Thomas C. Corley - t&aacute;c giả cuốn s&aacute;ch b&aacute;n chạy &ldquo;Rich Habits -Th&oacute;i quen gi&agrave;u c&oacute;&rdquo; cho biết, người th&agrave;nh c&ocirc;ng thường c&oacute; th&oacute;i quen kết nối để ph&aacute;t triển mối quan hệ với những người th&agrave;nh c&ocirc;ng kh&aacute;c. Thực tế cũng phản ảnh điều tương tự: những người gi&agrave;u c&oacute; sẽ t&igrave;m đến những người gi&agrave;u c&oacute; kh&aacute;c theo c&aacute;ch &ldquo;định vị&rdquo; ri&ecirc;ng của họ. Dưới đ&acirc;y l&agrave; những đặc điểm nhận diện chung thường thấy của giới thượng lưu:</em></p>

<p><strong><em>Sở hữu bất động sản &ldquo;khủng&rdquo;</em></strong></p>

<p>Những người gi&agrave;u c&oacute; v&agrave; th&agrave;nh c&ocirc;ng lu&ocirc;n sở hữu một hoặc nhiều biệt thự, căn hộ hạng sang. Đ&acirc;y kh&ocirc;ng những l&agrave; nơi để họ tận hưởng cuộc sống thoải m&aacute;i với đầy đủ tiện nghi, gi&uacute;p họ lấy lại năng lượng v&agrave; tinh thần, m&agrave; c&ograve;n l&agrave; quy chuẩn để khẳng định đẳng cấp, địa vị x&atilde; hội v&agrave; thương hiệu c&aacute; nh&acirc;n. Một nơi ở xứng tầm sẽ gi&uacute;p họ g&acirc;y ảnh hưởng t&iacute;ch cực đối với c&ocirc;ng ch&uacute;ng v&agrave; x&atilde; hội, từ đ&oacute; mang lại sự thịnh vượng v&agrave; thăng tiến cho cuộc sống lẫn sự nghiệp. Donald Trump &ndash; &ocirc;ng tr&ugrave;m bất động sản Mỹ, hiện l&agrave; ứng vi&ecirc;n s&aacute;ng gi&aacute; cho cuộc chạy đua v&agrave;o Nh&agrave; trắng v&agrave;o th&aacute;ng 11 &ndash; l&agrave; minh chứng ti&ecirc;u biểu cho điều n&agrave;y. Ở tuổi 70, Trump sở hữu khối t&agrave;i sản trị gi&aacute; gần 9 tỷ USD với t&ograve;a th&aacute;p Trump, nằm ở vị tr&iacute; trung t&acirc;m th&agrave;nh phố New York. Vị tỷ ph&uacute; bất động sản c&ograve;n l&agrave; chủ nh&acirc;n của căn hộ penthouse tr&ecirc;n tầng cao nhất của t&ograve;a nh&agrave;, với tầm nh&igrave;n đắt gi&aacute; hướng ra trung t&acirc;m.</p>

<p><strong><em>Sưu tập xế hộp đẳng cấp</em></strong></p>

<p>B&ecirc;n cạnh nh&agrave; v&agrave; biệt thự triệu đ&ocirc;, những người gi&agrave;u c&oacute; thường c&oacute; một bộ sưu tập xe sang đắt gi&aacute;. Đ&acirc;y kh&ocirc;ng đơn thuần l&agrave; phương tiện di chuyển, m&agrave; c&ograve;n l&agrave; mảnh gh&eacute;p kh&ocirc;ng thể thiếu trong bức tranh tổng thể của cuộc sống giới thượng lưu.</p>

<p>Với bộ sưu tập gồm to&agrave;n thương hiệu nổi tiếng như Mercedes- Benz, Porsche, Audi, BMW, Lamborghini&hellip; ch&agrave;ng danh thủ Cristiano Ronaldo li&ecirc;n tiếp được giới truyền th&ocirc;ng săn đ&oacute;n v&agrave; nhắc t&ecirc;n bởi đẳng cấp kh&ocirc;ng chỉ được định vị ở t&agrave;i năng b&oacute;ng đ&aacute; của m&igrave;nh. Năm 2015, h&igrave;nh ảnh Cristiano Ronaldo l&aacute;i chiếc Mercedes-Benz C220 CDI y&ecirc;u th&iacute;ch đến buổi huấn luyện tại Real Madrid đ&atilde; g&acirc;y ấn tượng mạnh mẽ trong l&ograve;ng fan h&acirc;m mộ. &Iacute;t ai biết được rằng, danh h&agrave;i Rowan Atkinson với vai diễn để đời &quot;Mr. Bean&quot; l&agrave; chủ nh&acirc;n của nhiều chiếc xế hộp đắt tiền. Trong đ&oacute;, phương tiện đi lại h&agrave;ng ng&agrave;y của &ocirc;ng l&agrave; sự lu&acirc;n phi&ecirc;n giữa chiếc Audi A8 v&agrave; Mercedes-Benz E500.</p>

<p><strong><em>Sẵn s&agrave;ng chi tiền cho sở th&iacute;ch c&aacute; nh&acirc;n</em></strong></p>

<p>Sưu tầm đồng hồ đắt gi&aacute;, mua sắm quần &aacute;o, gi&agrave;y d&eacute;p, t&uacute;i x&aacute;ch của những thương hiệu nổi tiếng, tổ chức những bữa tiệc xa xỉ, bao trọn to&agrave;n bộ h&ograve;n đảo trong kỳ nghỉ m&aacute;t để được tự do trong kh&ocirc;ng gian ri&ecirc;ng, cầu h&ocirc;n bằng những chiếc nhẫn kim cương triệu đ&ocirc;&hellip; l&agrave; những &ldquo;th&oacute;i quen&rdquo; chi ti&ecirc;u thường gặp của giới thượng lưu, nhằm khẳng định đẳng cấp v&agrave; mức độ gi&agrave;u c&oacute;.</p>

<p>Tuy nhi&ecirc;n, nh&igrave;n chung việc sở hữu biệt thự, căn hộ v&agrave; xế hộp hạng sang vẫn l&agrave; hai &ldquo;đặc điểm nhận diện&rdquo; kh&ocirc;ng thể thiếu của những người gi&agrave;u c&oacute;, nổi tiếng.&nbsp;Ngay tại Việt Nam, điều n&agrave;y cũng thể hiện r&otilde; n&eacute;t qua việc &ldquo;săn l&ugrave;ng&rdquo; nh&agrave; v&agrave; xe sang ở giới thượng lưu. Trong v&agrave;i th&aacute;ng vừa qua, thị trường bất động sản như trải qua &ldquo;cơn địa chấn&rdquo; khi dự &aacute;n Vinhomes Golden River của tập đo&agrave;n Vingroup ch&iacute;nh thức ra mắt, với số lượng chỉ 3000 căn. Dự &aacute;n n&agrave;y ngay lập tức thiết lập một ti&ecirc;u chuẩn mới về căn hộ, biệt thự hạng sang khi chiếm giữ vị tr&iacute; đắc địa: tọa lạc ngay trong l&ograve;ng quận 1, l&agrave; khu đ&ocirc; thị sinh th&aacute;i ven s&ocirc;ng duy nhất ph&aacute; vỡ quy luật &ldquo;ngoại &ocirc;&rdquo; c&oacute; quy m&ocirc; đầu tư lớn nhất, đẳng cấp nhất từ trước đến nay của Tập đo&agrave;n Vingroup. Kh&ocirc;ng những thế, đ&acirc;y c&ograve;n l&agrave; dự &aacute;n sở hữu&nbsp;&ldquo;bộ ba quyền lực&rdquo; hiếm hoi:&nbsp;vị tr&iacute; khu trung t&acirc;m; kế cận mặt nước (nằm ven s&ocirc;ng S&agrave;i G&ograve;n); c&oacute; tuyến t&agrave;u điện ngầm chạy qua &ndash; những gi&aacute; trị n&agrave;y gi&uacute;p đảm bảo khả năng tăng gi&aacute; lớn v&agrave; bền vững, theo ph&acirc;n t&iacute;ch của CBRE Việt Nam v&agrave; Savills Việt Nam.</p>

<p><img alt="Nghênh Nhà Vàng Rước Xe Sang" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/bttt/bttt-t8.jpeg" width="600" /></p>

<p>Điều đặc biệt, Chủ đầu tư đ&atilde; thỏa m&atilde;n th&uacute; vui sở hữu &ldquo;bộ đ&ocirc;i&rdquo; quyền lực nh&agrave; v&agrave; xe sang khi đưa ra chương tr&igrave;nh &ldquo;Ngh&ecirc;nh nh&agrave; v&agrave;ng, rước xe sang&rdquo;, mua nh&agrave; Vinhomes Golden River, tr&uacute;ng Mercedes- Benz S500L. Với đẳng cấp được thiết lập r&otilde; r&agrave;ng, Vinhomes Golden River được dự đo&aacute;n sẽ l&agrave; trung t&acirc;m của tinh hoa thượng lưu, xứng tầm với đẳng cấp của giới nh&agrave; gi&agrave;u Việt Nam trong hiện tại lẫn tương lai.</p>

<p><strong>&ldquo;CƠ HỘI SỞ HỮU BỘ Đ&Ocirc;I QUYỀN LỰC &ndash; NH&Agrave; V&Agrave; XE SANG&rdquo;</strong></p>

<p>Nhằm khẳng định đẳng cấp sống thượng lưu của kh&aacute;ch h&agrave;ng, Vinhomes Golden River tổ chức chương tr&igrave;nh bốc thăm tr&uacute;ng trưởng &ldquo;Ngh&ecirc;nh nh&agrave; v&agrave;ng &ndash; rước xe sang&rdquo; với giải thưởng l&agrave; Mercedes-Benz S500L &ndash; chiếc xe&nbsp;nằm trong danh s&aacute;ch xế hộp đắt gi&aacute; được giới doanh nh&acirc;n gi&agrave;u c&oacute;, ch&iacute;nh kh&aacute;ch, người nổi tiếng tr&ecirc;n khắp thế giới săn đ&oacute;n.</p>

<p>Theo đ&oacute;, tất cả kh&aacute;ch h&agrave;ng đ&atilde; đặt cọc v&agrave; k&yacute; hợp đồng mua b&aacute;n Nh&agrave; ở tại Vinhomes Golden River sẽ nhận được một phiếu bốc thăm ghi m&atilde; số dự thưởng. Kh&aacute;ch h&agrave;ng sở hữu nhiều sản phẩm hoặc mua sớm sẽ c&oacute; cơ hội tr&uacute;ng thưởng cao hơn. Hai vị chủ nh&acirc;n may mắn đầu ti&ecirc;n rước xe sang về nh&agrave; sẽ được c&ocirc;ng bố trong đợt bốc thăm đầu ti&ecirc;n diễn ra v&agrave;o ng&agrave;y 31/8 tới đ&acirc;y.</p>
')

    Post.create!(title: 'VINGROUP LÀ CHỦ ĐẦU TƯ BẤT ĐỘNG SẢN UY TÍN NHẤT VIỆT NAM 2016',
      content: '<p><strong><em>Tập đo&agrave;n Vingroup vừa được b&igrave;nh chọn l&agrave; doanh nghiệp dẫn đầu trong Top 10 chủ đầu tư bất động sản uy t&iacute;n nhất Việt Nam năm 2016 do Vietnam Report thực hiện. Đ&acirc;y l&agrave; chủ đầu tư h&agrave;ng loạt dự &aacute;n đ&ocirc; thị quy m&ocirc; h&agrave;ng đầu Việt Nam: Times City, Royal City, Vinhomes Riverside, Vinhomes Gardenia, Vinhomes Central Park, Vinhomes Dragon Bay&hellip; v&agrave; nhiều tổ hợp TTTM &ndash; Shophouse tại c&aacute;c tỉnh th&agrave;nh tr&ecirc;n cả nước.</em></strong></p>

<p><strong><em><img alt="vietnam-report-2016-1-central-park.jpg" height="362" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/vietnam-report-2016-1-central-park.jpg" width="650" /></em></strong></p>

<p>Trong Bảng xếp hạng Top 10 Chủ đầu tư bất động sản uy t&iacute;n v&agrave; Top 5 c&ocirc;ng ty tư vấn, m&ocirc;i giới bất động sản uy t&iacute;n năm 2016 vừa được C&ocirc;ng ty cổ phần B&aacute;o c&aacute;o đ&aacute;nh gi&aacute; Việt Nam (Vietnam Report) c&ocirc;ng bố ng&agrave;y 22/3/2016, Vingroup vinh dự được b&igrave;nh chọn l&agrave; chủ đầu tư bất động sản uy t&iacute;n nhất Việt Nam. Xếp sau Vingroup l&agrave; c&aacute;c chủ đầu tư t&ecirc;n tuổi như H&ograve;a Ph&aacute;t, Novaland, Ph&uacute; Mỹ Hưng, Him Lam&hellip;</p>

<p>Top 10 Chủ đầu tư bất động sản uy t&iacute;n năm 2016 l&agrave; bảng xếp hạng mới nhất của Vietnam Report - c&ocirc;ng ty b&aacute;o c&aacute;o xếp hạng uy t&iacute;n nhất Việt Nam. Bảng xếp hạng được đưa ra dựa tr&ecirc;n kết quả nghi&ecirc;n cứu độc lập, khoa học v&agrave; kh&aacute;ch quan của Vietnam Report theo c&aacute;c ti&ecirc;u ch&iacute; ch&iacute;nh: năng lực t&agrave;i ch&iacute;nh thể hiện tr&ecirc;n b&aacute;o c&aacute;o t&agrave;i ch&iacute;nh đ&atilde; kiểm to&aacute;n năm gần nhất; uy t&iacute;n của doanh nghiệp tr&ecirc;n truyền th&ocirc;ng, số lượng v&agrave; tiến độ thực hiện dự &aacute;n, tỷ lệ giao dịch th&agrave;nh c&ocirc;ng, gi&aacute; b&aacute;n của c&aacute;c dự &aacute;n&hellip;</p>

<p><img alt="vietnam-report-2016-2.jpg" height="285" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/vietnam-report-2016-2.jpg" width="570" /></p>

<p>Tập đo&agrave;n Vingroup l&agrave; chủ đầu tư của h&agrave;ng loạt dự &aacute;n lớn như khu đ&ocirc; thị Times City, Royal City, Vinhomes Riverside, Vinhomes Gardenia tại H&agrave; Nội, dự &aacute;n Vinhomes Central Park tại TPHCM, dự &aacute;n Vinhomes Dragon Bay tại Quảng Ninh v&agrave; nhiều tổ hợp TTTM &ndash; Shophouse tại c&aacute;c tỉnh th&agrave;nh cả nước.</p>

<p>Điểm ưu việt của c&aacute;c sản phẩm bất động sản của Vingroup l&agrave; lu&ocirc;n đảm bảo cam kết về tiến độ, chất lượng x&acirc;y dựng v&agrave; hệ thống hạ tầng, tiện &iacute;ch đồng bộ v&agrave; chất lượng dịch vụ vượt trội. Đặc biệt, c&aacute;c khu đ&ocirc; thị Vinhomes lu&ocirc;n đi đầu trong việc thiết lập một hệ thống an ninh chặt chẽ, hệ thống ph&ograve;ng ch&aacute;y chữa ch&aacute;y hiện đại, đảm bảo m&ocirc;i trường sống an to&agrave;n cho kh&aacute;ch h&agrave;ng. B&ecirc;n cạnh đ&oacute;, chủ đầu tư li&ecirc;n tục chủ động n&acirc;ng cao chất lượng sống tại c&aacute;c khu đ&ocirc; thị như tăng độ phủ xanh, ph&aacute;t triển dự &aacute;n theo m&ocirc; h&igrave;nh smarthomes&hellip;, g&oacute;p phần kiến tạo cuộc sống đẳng cấp cho cư d&acirc;n.</p>

<p><img alt="vietnam-report-2016-3.jpg" height="322" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/vietnam-report-2016-3.jpg" width="570" /></p>

<p>Việc Vingroup được Vietnam Report đ&aacute;nh gi&aacute; l&agrave; chủ đầu tư bất động sản uy t&iacute;n nhất Việt Nam tiếp tục khẳng định uy t&iacute;n, tầm v&oacute;c của Tập đo&agrave;n tr&ecirc;n thị trường. Trước đ&oacute;, Vingroup đ&atilde; li&ecirc;n tục được giới chuy&ecirc;n m&ocirc;n v&agrave; thị trường đ&aacute;nh gi&aacute; l&agrave; nh&agrave; ph&aacute;t triển bất động sản h&agrave;ng đầu Việt Nam, th&ocirc;ng qua c&aacute;c bảng xếp hạng v&agrave; giải thưởng uy t&iacute;n. Th&aacute;ng 10/2015, thương hiệu bất động sản Vinhomes của Vingroup đ&atilde; được h&atilde;ng định gi&aacute; thương hiệu h&agrave;ng đầu thế giới Brand Finance b&igrave;nh chọn v&agrave;o Top 10 thương hiệu đắt gi&aacute; nhất Việt Nam v&agrave; l&agrave; thương hiệu bất động sản duy nhất trong Top 10. Th&aacute;ng 9/2015, Euromoney &ndash; tổ chức t&agrave;i ch&iacute;nh uy t&iacute;n to&agrave;n cầu cũng đồng loạt vinh doanh Vingroup ở 3 hạng mục giải thưởng bất động sản danh gi&aacute;: Chủ đầu tư tốt nhất Việt Nam, Chủ đầu tư dự &aacute;n phức hợp tốt nhất Việt Nam v&agrave; Chủ đầu tư dự &aacute;n du lịch nghỉ dưỡng tốt nhất Việt Nam.</p>

<p>Trong nước, cả 3 khu đ&ocirc; thị do Vingroup ph&aacute;t triển l&agrave; Times City, Royal City, Vinhomes Riverside cũng đ&atilde; được b&aacute;o Đầu Tư v&agrave; c&ocirc;ng ch&uacute;ng b&igrave;nh chọn v&agrave;o Top 3 &ldquo;Khu đ&ocirc; thị đ&aacute;ng sống nhất Việt Nam&rdquo; năm 2015.</p>

<p>C&aacute;c danh hiệu danh gi&aacute; do c&aacute;c tổ chức uy t&iacute;n trao tặng đ&atilde; khẳng định quy m&ocirc; v&agrave; tầm v&oacute;c h&agrave;ng đầu của Vingroup; đồng thời cho thấy vị thế dẫn dắt của Tập đo&agrave;n tr&ecirc;n thị trường bất động sản Việt Nam ./.</p>

<p><strong>Th&ocirc;ng tin tham khảo:</strong></p>

<p><em>B&ecirc;n cạnh bảng xếp hạng Top 10 Chủ đầu tư bất động sản uy t&iacute;n, Vingroup c&ograve;n c&oacute; t&ecirc;n trong Top đầu nhiều bảng xếp hạng kh&aacute;c Vietnam Report c&ocirc;ng bố như: Top 10 doanh nghiệp nộp thuế lớn nhất Việt Nam, Top 5 doanh nghiệp tư nh&acirc;n lớn nhất Việt Nam....&nbsp;</em></p>
')

    Post.create!(title: 'VINHOMES GARDENIA RA MẮT KHU BIỆT THỰ VÀ NHÀ PHỐ THƯƠNG MẠI',
      content: '<p><strong><em>S&aacute;ng ng&agrave;y 16/01/2016, C&ocirc;ng ty TNHH Kinh doanh Bất động sản Vinhomes 2 tổ chức sự kiện giới thiệu khu The Botanica thuộc Dự &aacute;n Vinhomes Gardenia tại kh&aacute;ch sạn Lotte, H&agrave; Nội. Tại sự kiện, chủ đầu tư sẽ giới thiệu chuy&ecirc;n s&acirc;u về khu The Botanica với sản phẩm biệt thự, biệt thự liền kề v&agrave; shophouse c&ugrave;ng nhiều ch&iacute;nh s&aacute;ch ưu đ&atilde;i hấp dẫn.</em></strong></p>

<p>The Botanica l&agrave; ph&acirc;n khu thấp tầng gồm biệt thự, biệt thự liền kề, shophouse thuộc dự &aacute;n khu đ&ocirc; thị phức hợp Vinhomes Gardenia - dự &aacute;n đầu ti&ecirc;n của Vingroup tại khu vực T&acirc;y H&agrave; Nội. The Botanica được đơn vị h&agrave;ng đầu thế giới &ndash; West Green Design (Canada) thiết kế thiết kế theo phong c&aacute;ch t&acirc;n cổ điển. Nằm dọc hai b&ecirc;n trục cảnh quan ch&iacute;nh v&agrave; xen kẽ giữa c&aacute;c tiện &iacute;ch của dự &aacute;n Vinhomes Gardenia như vườn hoa s&uacute;ng, đồi hoa, s&acirc;n chơi trẻ em, l&agrave;n xe đạp th&acirc;n thiện, s&acirc;n tennis, đường chạy bộ&hellip;, The Botanica sở hữu tầm nh&igrave;n tuyệt đẹp, tho&aacute;ng rộng v&agrave; xanh m&aacute;t.</p>

<p><img alt="Trục vườn tại Khu Biệt thự Vinhomes Gardenia The Botanica" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Gardenia/pic/tt1.jpg" width="600" /></p>

<p>&nbsp;</p>

<p>Với số lượng hạn chế chỉ 38 căn biệt thự song lập, diện t&iacute;ch đất từ 277,6m2 đến 381,6m2, biệt thự The Botanica được đ&aacute;nh gi&aacute; l&agrave; đẹp nhất tại khu vực Mỹ Đ&igrave;nh bởi vị tr&iacute; nằm đối xứng qua trục cảnh quan ch&iacute;nh tuyệt đẹp, hướng ra vườn hoa s&uacute;ng, đ&agrave;i phun nước, vườn BBQ, vườn th&uacute; cưng v&agrave; nhiều cảnh quan tiện &iacute;ch độc đ&aacute;o kh&aacute;c, khu biệt thự Điểm nhấn của The Botanica l&agrave; hệ thống c&aacute;c tiểu cảnh nước độc đ&aacute;o, kh&ocirc;ng chỉ gi&uacute;p điều h&ograve;a kh&ocirc;ng kh&iacute; tự nhi&ecirc;n m&agrave; c&ograve;n mang đến kh&ocirc;ng gian xanh m&aacute;t cho chủ nh&acirc;n biệt thự. Khu biệt thự The Botanica hứa hẹn mang đến cuộc sống l&atilde;ng mạn v&agrave; đẳng cấp nhất cho c&aacute;c chủ nh&acirc;n tương lai.</p>

<p><img alt="Cảnh quan chan hòa cây xanh tại Vinhomes Gardenia The Botanica" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Gardenia/pic/U4.jpg" width="600" /></p>

<p>Nằm bao quanh khu biệt thự, khu biệt thự liền kề The Botanica sẽ mang lại cuộc sống năng động m&agrave; kh&ocirc;ng k&eacute;m phần y&ecirc;n tĩnh ri&ecirc;ng tư cho gia chủ. Cư d&acirc;n c&oacute; thể ngắm nh&igrave;n phố x&aacute; lộng lẫy, h&agrave;o hoa m&agrave; vẫn cảm nhận được bầu kh&ocirc;ng kh&iacute; trong l&agrave;nh tại khu biệt thự liền kề The Botanica.</p>

<p>Chuỗi biệt thự liền kề tại ph&acirc;n khu The Botanica gồm 154 căn, mỗi căn gồm 4 tầng với diện đất từ 74,5m2 đến 320m2. Chuỗi biệt thự liền kề được bố tr&iacute; rất gần c&aacute;c tiện &iacute;ch thể thao như bể bơi ngo&agrave;i trời The Botanica, s&acirc;n cầu l&ocirc;ng, l&agrave;n đường th&acirc;n thiện, s&acirc;n chơi trẻ em&hellip;, n&ecirc;n sẽ mang tới sự thuận tiện tối đa cho c&aacute;c hoạt động vui chơi giải tr&iacute; của cư d&acirc;n.</p>

<p><img alt="Khu biệt thự liền kề tại  Vinhomes Gardenia The Botanica" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Gardenia/pic/TT8.jpg" width="600" /></p>

<p>Đặc biệt, tại The Botanica, lần đầu ti&ecirc;n Tập đo&agrave;n Vingroup ra mắt thị trường H&agrave; Nội c&aacute;c căn nh&agrave; phố thương mại Shophouse ri&ecirc;ng biệt v&agrave; độc đ&aacute;o với 4,5 tầng/căn, diện t&iacute;ch đất từ 88,5m2 đến 262,7m2. Chức năng &ldquo;k&eacute;p&rdquo; &ndash; vừa kinh doanh tại tầng 1, vừa sinh hoạt thuận tiện &ldquo;một bước ra phố&rdquo; tại c&aacute;c tầng tr&ecirc;n l&agrave; ưu điểm nổi trội của loại h&igrave;nh bất động sản n&agrave;y. Nhờ đ&oacute;, shophouse c&oacute; gi&aacute; trị thương mại cao m&agrave; vẫn ph&ugrave; hợp với tập qu&aacute;n sinh hoạt l&acirc;u đời cũng như m&ocirc; h&igrave;nh kinh tế vừa v&agrave; nhỏ của người Việt. Với thiết kế hợp l&yacute;, thuận lợi cho gia chủ bố tr&iacute; kh&ocirc;ng gian sinh hoạt v&agrave; kinh doanh, tiềm năng sinh lời cực kỳ hấp dẫn, 172 căn nh&agrave; phố thương mại shophouse tại The Botanica hứa hẹn l&agrave; sản phẩm h&uacute;t Kh&aacute;ch của dự &aacute;n.</p>

<p><img alt="Shophouse Nhà phố thương mại tại Vinhomes Gardenia The Botanica" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Gardenia/pic/TT10.jpg" width="600" /></p>

<p>The Botanica - Vinhomes Gardenia cũng l&agrave; nơi c&oacute; mật độ d&acirc;n cư rất thấp, ph&ugrave; hợp với những người y&ecirc;u th&iacute;ch cuộc sống an nhi&ecirc;n, tĩnh tại. B&ecirc;n cạnh kh&ocirc;ng gian trong l&agrave;nh, tinh khiết, hệ thống cảnh quan xanh m&aacute;t, hệ thống dịch vụ tiện &iacute;ch đồng bộ cho mọi lứa tuổi sẽ đ&aacute;p ứng nhu cầu sống tiện nghi m&agrave; vẫn thư th&aacute;i với ph&ograve;ng kh&aacute;m Vinmec, si&ecirc;u thị VinMart, khu phố mua sắm, trường học mầm non v&agrave; tiểu học Vinschool, ph&ograve;ng gym, s&acirc;n chơi trẻ em, thư viện, vườn nướng BBQ, vườn tiệc cho gia đ&igrave;nh; v&agrave; vườn chơi cờ, vườn th&aacute;i cực quyền cho cha mẹ, &ocirc;ng b&agrave;&hellip;</p>

<table>
  <tbody>
    <tr>
      <td>
      <p><strong>Lễ ra mắt hai khu The Botanica thuộc dự &aacute;n Vinhomes Gardenia sẽ diễn ra v&agrave;o 9h00 s&aacute;ng ng&agrave;y 16/01/2016 tại kh&aacute;ch sạn Lotte, 54 Liễu Giai, H&agrave; Nội</strong>.</p>

      <p>Tham dự sự kiện v&agrave; đăng k&yacute; đặt mua biệt thự, biệt thự liền kề, shophouse tại The Botanica, kh&aacute;ch h&agrave;ng sẽ được hưởng những ch&iacute;nh s&aacute;ch ưu đ&atilde;i hấp dẫn, bao gồm:</p>

      <ul>
        <li><em>Tặng g&oacute;i rau sạch của VinEco trong 3 th&aacute;ng;</em></li>
        <li><em>Tặng 01 suất học bổng tại trường mầm non hoặc tiểu học trị gi&aacute; 50 triệu đồng;</em></li>
        <li><em>Được hỗ trợ vay vốn l&ecirc;n tới 70% gi&aacute; trị nh&agrave; trong 25 năm với l&atilde;i suất ưu đ&atilde;i 0% tới 12 th&aacute;ng kể từ ng&agrave;y giải ng&acirc;n của khoản vay đầu ti&ecirc;n;</em></li>
      </ul>

      <p><em>Đặc biệt, kh&aacute;ch h&agrave;ng đăng k&yacute; trước 31/01/2016 sẽ được tặng g&oacute;i dịch vụ quản l&yacute; 03 năm</em></p>

      <p>Để biết th&ecirc;m th&ocirc;ng tin chi tiết về dự &aacute;n, Qu&yacute; kh&aacute;ch vui l&ograve;ng li&ecirc;n hệ đại l&yacute; ph&acirc;n phối khu biệt thự, biệt thự liền kề v&agrave; shophouse The Botanica: Li&ecirc;n minh c&aacute;c s&agrave;n BĐS G5, Homes Real Estate.</p>

      <p><strong>Hotline: 1800 1186</strong></p>

      <p><strong>Website:&nbsp;</strong><a href="http://www.vinhomesgardenia.vn/"><strong>www.vinhomesgardenia.vn</strong></a></p>
      </td>
    </tr>
  </tbody>
</table>
')

    Post.create!(title: 'CHÍNH THỨC GIỚI THIỆU KHU NHÀ MẪU CĂN HỘ THE ARCADIA - VINHOMES GARDENIA',
      content: '<p><strong><em>S&aacute;ng ng&agrave;y 26/3/2016, C&ocirc;ng ty TNHH Kinh doanh Bất động sản Vinhomes 2 ch&iacute;nh thức tổ chức sự kiện khai trương v&agrave; đ&oacute;n tiếp kh&aacute;ch thăm quan khu căn hộ mẫu đẳng cấp The Arcadia &ndash; Vinhomes Gardenia. Khu căn hộ mẫu được đặt tại văn ph&ograve;ng giao dịch của dự &aacute;n, tại tầng 2, t&ograve;a R6, Khu đ&ocirc; thị Royal City, 72A Nguyễn Tr&atilde;i, H&agrave; Nội.</em></strong></p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p><em><img alt="VHGD_CH-mau_2_small.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/BaiViet/2016/VHGD-CH-mau/VHGD_CH-mau_2_small.jpg" width="600" /></em></p>

<p>&nbsp;</p>

<p><em>Phối cảnh căn hộ mẫu The Arcadia &ndash; Vinhomes Gardenia</em></p>

<p>&nbsp;</p>

<p><em>&nbsp;</em></p>

<p>&nbsp;</p>

<p>Khu nh&agrave; mẫu căn hộ The Arcadia thuộc dự &aacute;n Vinhomes Gardenia sẽ trưng b&agrave;y v&agrave; giới thiệu căn hộ mẫu theo ti&ecirc;u chuẩn b&agrave;n giao (chưa bao gồm nội thất) v&agrave; căn hộ với thiết kế nội thất tham khảo, nhằm gi&uacute;p c&aacute;c cư d&acirc;n tương lai dễ d&agrave;ng h&igrave;nh dung được kh&ocirc;ng gian sống đẳng cấp của m&igrave;nh. Mỗi căn hộ đều được trang bị đầy đủ nội thất cao cấp như: s&agrave;n gỗ c&ocirc;ng nghiệp cao cấp, điều h&ograve;a &acirc;m trần hai chiều, thiết bị vệ sinh hạng sang, kh&oacute;a th&ocirc;ng minh ba lớp bảo vệ&hellip;Ngay từ b&acirc;y giờ, kh&aacute;ch h&agrave;ng đ&atilde; c&oacute; thể li&ecirc;n hệ c&aacute;c đại l&yacute; ph&acirc;n phối ch&iacute;nh thức để đặt lịch thăm quan v&agrave; trải nghiệm &ldquo;tổ ấm ban mai&rdquo; n&agrave;y.</p>

<p>&nbsp;</p>

<p>&nbsp;<img alt="Quảng trường mua sắm The Arcadia Vinhomes Gardenia" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/BaiViet/2016/VHGD-CH-mau/03_Qu-ng-tr-ng-mua-s-m.jpg" width="600" /></p>

<p>&nbsp;</p>

<p><em>Phối cảnh khu căn hộ The Arcadia &ndash; Vinhomes Gardenia</em></p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>Khu đ&ocirc; thị Vinhomes Gardenia c&oacute; quy m&ocirc; 17,6 hecta được quy hoạch đối xứng qua trục đường H&agrave;m Nghi, hướng ra Đại lộ Thăng Long. Dự &aacute;n tọa lạc tại một trong những vị tr&iacute; v&agrave;ng của Mỹ Đ&igrave;nh - tr&aacute;i tim của khu vực ph&iacute;a T&acirc;y H&agrave; Nội, kết nối đồng bộ với hạ tầng giao th&ocirc;ng v&agrave; trung t&acirc;m h&agrave;nh ch&iacute;nh - thương mại hiện đại trong tương lai. Lấy cảm hứng từ đ&oacute;a nh&agrave;i t&acirc;y thanh khiết, &ldquo;Th&agrave;nh phố Ban Mai - Vinhomes Gardenia&rdquo; được thiết kế dựa tr&ecirc;n nguy&ecirc;n tắc xanh &ndash; trong l&agrave;nh v&agrave; c&acirc;n bằng do hai thương hiệu thiết kế nổi tiếng thế giới CPG (Singapore) v&agrave; West Green Design (Canada) tư vấn.&nbsp;</p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>Khu căn hộ -&nbsp;<strong>The Arcadia</strong>&nbsp;nằm tại trục đường ch&iacute;nh H&agrave;m Nghi, cạnh khu biệt thự liền kề thương mại v&agrave; shophouse s&ocirc;i động. 3 t&ograve;a căn hộ The Arcadia được thiết kế th&ocirc;ng tho&aacute;ng ph&ugrave; hợp với xu hướng kiến tr&uacute;c gần gũi thi&ecirc;n nhi&ecirc;n ti&ecirc;n tiến tr&ecirc;n thế giới, sở hữu hệ thống tiện &iacute;ch nội khu đồng bộ, đa dạng như s&acirc;n tennis, s&acirc;n chơi trẻ em, vườn nướng BBQ, quầy bar nổi&hellip; Căn hộ The Arcadia được thiết kế từ 54m2 đến 146,8m2, gồm 1 đến 4 ph&ograve;ng ngủ c&oacute; tầm nh&igrave;n tho&aacute;ng rộng, nhiều khe s&aacute;ng v&agrave; cửa đ&oacute;n gi&oacute;, bảo đảm đối lưu kh&ocirc;ng kh&iacute;. Đặc biệt, m&ocirc; h&igrave;nh căn hộ duplex &ndash; căn hộ th&ocirc;ng tầng độc đ&aacute;o với diện t&iacute;ch/s&agrave;n từ 98m2 - 102m2 lần đầu ti&ecirc;n được Vinhomes giới thiệu sẽ mang lại kh&ocirc;ng gian sống hiện đại, tiện nghi v&agrave; ri&ecirc;ng tư.</p>

<p>&nbsp;</p>

<p>&nbsp;<img alt="Bể bơi The Arcadia Vinhomes Gardenia" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/BaiViet/2016/VHGD-CH-mau/CC2.jpg" width="600" /></p>

<p>&nbsp;</p>

<p><em>Bể bơi trung t&acirc;m d&agrave;i 50m tại khu căn hộ The Arcadia &ndash; Vinhomes Gardenia</em></p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>&nbsp;</p>

<p>B&ecirc;n cạnh hai ph&acirc;n khu nh&agrave; ở, dự &aacute;n Vinhomes Gardenia sẽ ph&aacute;t triển hệ thống 66 tiện &iacute;ch v&agrave; dịch vụ nội khu đồng bộ như ph&ograve;ng kh&aacute;m Vinmec, trường mầm non v&agrave; tiểu học Vinschool, si&ecirc;u thị Vinmart&hellip; c&ugrave;ng 10 khu vườn độc đ&aacute;o nhằm đ&aacute;p ứng tốt nhất tiện &iacute;ch sống cho cư d&acirc;n. Vinhomes Gardenia hứa hẹn sẽ l&agrave; th&agrave;nh phố đ&aacute;ng sống nhất khu vực T&acirc;y H&agrave; Nội.</p>

<p>&nbsp;</p>

<p><em>&nbsp;</em></p>

<p>&nbsp;</p>

<table>
  <tbody>
    <tr>
      <td>
      <p><strong>Sự kiện Khai trương khu căn hộ mẫu đẳng cấp The Arcadia - Vinhomes Gardenia&nbsp;</strong>sẽ diễn ra v&agrave;o 09h00 ng&agrave;y 26/03/2016 tại tầng 2, t&ograve;a R6, Khu đ&ocirc; thị Royal City, 72A Nguyễn Tr&atilde;i, H&agrave; Nội.</p>

      <p>Đăng k&yacute; thăm quan nh&agrave; mẫu v&agrave; đặt mua căn hộ The Arcadia, kh&aacute;ch h&agrave;ng sẽ được hưởng những ch&iacute;nh s&aacute;ch ưu đ&atilde;i hấp dẫn, bao gồm:</p>

      <ul>
        <li><em>Tặng g&oacute;i rau sạch của VinEco trong 3 th&aacute;ng;</em></li>
        <li><em>Tặng 01 suất học bổng tại trường mầm non hoặc tiểu học Vinschool trị gi&aacute; 50 triệu đồng;</em></li>
        <li><em>Được hỗ trợ vay vốn l&ecirc;n tới 70% gi&aacute; trị căn hộ với l&atilde;i suất ưu đ&atilde;i 0%&nbsp;&aacute;p dụng từ thời điểm giải ng&acirc;n đến 31/3/2018&nbsp;.</em></li>
      </ul>

      <p><em>Đặc biệt, kh&aacute;ch h&agrave;ng đăng k&yacute; đặt mua nh&agrave; trước 31/03/2016 sẽ được nhận qu&agrave; tặng lộc xu&acirc;n may mắn l&agrave; 01 c&acirc;y v&agrave;ng.</em></p>

      <p>Tham dự sự kiện khai trương ng&agrave;y 26/3, kh&aacute;ch h&agrave;ng sẽ c&oacute; cơ hội nhận được qu&agrave; tặng bốc thăm may mắn từ đại l&yacute; ph&acirc;n phối với tổng gi&aacute; trị l&ecirc;n đến hơn 200 triệu, bao gồm: 1 giải nhất l&agrave; 1 xe m&aacute;y SH, 3 giải nh&igrave; mỗi giải l&agrave; 1 iPad, 5 giải ba mỗi giải 1 iPad mini.</p>

      <p>Để biết th&ecirc;m th&ocirc;ng tin chi tiết về sự kiện Khai trương khu căn hộ mẫu The Arcadia v&agrave; sản phẩm căn hộ đẳng cấp The Arcadia, Qu&yacute; kh&aacute;ch vui l&ograve;ng li&ecirc;n hệ c&aacute;c Đại l&yacute; ph&acirc;n phối ch&iacute;nh thức: Minh Hưng Land, Viethousing, EZ Việt Nam.</p>

      <p><strong><em>Hotline: 1800 1186</em></strong></p>

      <p><em>Website:&nbsp;</em><a href="http://www.vinhomesgardenia.vn/"><em>www.vinhomesgardenia.vn</em></a></p>
      </td>
    </tr>
  </tbody>
</table>
')

    Post.create!(title: 'MỞ BÁN TÒA CĂN HỘ ĐẮT GIÁ NHẤT TIMES CITY',
      content: '<p><strong>Ng&agrave;y 26/3/2016, t&ograve;a căn hộ h&ocirc;̣i tụ nhi&ecirc;̀u ưu đi&ecirc;̉m đắt giá nhất dự &aacute;n Vinhomes Times City - Park Hill Premium sẽ được mở bán tại Trung t&acirc;m &acirc;̉m thực và h&ocirc;̣i nghị qu&ocirc;́c t&ecirc;́ Almaz.</strong></p>

<p>Tọa lạc tại trung t&acirc;m khu đ&ocirc; thị Times City, t&ograve;a Park 10 - Master Premium c&oacute; vị tr&iacute; đắc địa với tầm nh&igrave;n 4 mặt tho&aacute;ng, hướng ra quảng trường nhạc nước và hướng nhìn sang h&ecirc;̣ th&ocirc;́ng cảnh quan theo phong cách resort của Park Hill. Từ Park 10 - Master Premium, cư d&acirc;n c&oacute; thể kết nối thuận tiện tới c&aacute;c ph&acirc;n khu quan trọng trong khu đ&ocirc; thị như bệnh viện, trường học, trung t&acirc;m mua sắm, vui chơi giải tr&iacute;, hệ thống shophouse&hellip;</p>

<p><img alt="p10-2.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Times-City/ParkHill_premium/p10-2.jpg" width="550" /></p>

<p><em>T&ograve;a Park 10 c&oacute; vị thế đắc địa tại trung t&acirc;m của khu đ&ocirc; thị Times City, đ&aacute;p ứng ưu việt cho cu&ocirc;̣c s&ocirc;́ng của cư d&acirc;n, đ&uacute;ng như t&ecirc;n gọi &ldquo;Master Premium&rdquo;.</em></p>

<p>T&ograve;a Park 10 - Master Premium, có 34 tầng. Với mật độ ho&agrave;n hảo: 18 căn/sàn v&agrave; 12 thang máy, việc lưu th&ocirc;ng trong Park 10 rất thu&acirc;̣n lợi v&agrave; th&ocirc;ng tho&aacute;ng. C&aacute;c căn hộ c&oacute; diện t&iacute;ch đa dạng từ 68,1m2 - 178,4m2. Đặc biệt, Park 10 - Master Premium l&agrave; to&agrave; căn hộ duy nhất tại Park Hill Premium c&oacute; loại căn hộ 5 ph&ograve;ng ngủ với diện t&iacute;ch lớn, l&ecirc;n đến gần 180m2. Tại tòa căn h&ocirc;̣ đặc bi&ecirc;̣t này, khách hàng cũng có th&ecirc;̉ lựa chọn gói bàn giao th&ocirc; đ&ocirc;́i với c&aacute;c căn h&ocirc;̣ di&ecirc;̣n tích lớn (4-5 phòng ngủ) đ&ecirc;̉ gia chủ tự do sáng tạo kh&ocirc;ng gian s&ocirc;́ng ri&ecirc;ng.</p>

<p>Về thi&ecirc;́t k&ecirc;́, t&ograve;a nh&agrave; được quy hoạch theo hình chữ H, c&aacute;c căn hộ đều sở hữu khe s&aacute;ng v&agrave; mặt tho&aacute;ng, đảm bảo kh&ocirc;ng gian b&ecirc;n trong được tiếp x&uacute;c t&ocirc;́i đa ánh sáng tự nhi&ecirc;n và gió trời. Thiết kế căn hộ th&ocirc;ng tho&aacute;ng v&agrave; tối ưu h&oacute;a c&aacute;c kh&ocirc;ng gian sử dụng.</p>

<p>Kh&ocirc;ng chỉ &ldquo;xanh hơn&rdquo;, các căn h&ocirc;̣ tại Park 10 - Master Premium c&ograve;n mang đến cuộc sống th&ocirc;ng minh v&agrave; đẳng cấp hơn với c&ocirc;ng ngh&ecirc;̣ smarthome ưu vi&ecirc;̣t. Theo đ&oacute;, m&ocirc;̣t s&ocirc;́ thiết bị &aacute;nh s&aacute;ng, &acirc;m thanh&hellip; có th&ecirc;̉ được đi&ecirc;̀u khi&ecirc;̉n th&ocirc;ng qua kết nối với smartphone và máy tính bảng của gia chủ. Ngo&agrave;i ra, h&ecirc;̣ th&ocirc;́ng chu&ocirc;ng cửa hi&ecirc;̉n thị hình ảnh hi&ecirc;̣n đại và h&ecirc;̣ th&ocirc;́ng báo cháy, báo khói tự đ&ocirc;̣ng&hellip; được trang bị cho từng căn hộ cũng đảm bảo mang đến cho gia chủ một kh&ocirc;ng gian sống an to&agrave;n v&agrave; tiện lợi.</p>

<p><img alt="p10-1.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/MuaBan/Vinhomes-Times-City/ParkHill_premium/p10-1.jpg" width="550" /></p>

<p><em>Với kh&ocirc;ng gian xanh tho&aacute;ng l&yacute; tưởng, t&ograve;a Park 10 sở hữu những căn hộ đắt gi&aacute; với nhiều ưu điểm vượt trội, đặc biệt với vườn Nhật kết hợp vườn nướng BBQ tr&ecirc;n tầng m&aacute;i của t&ograve;a nh&agrave;.</em></p>

<p>Park 10 - Master Premium cũng l&agrave; t&ograve;a căn hộ sở hữu nhiều tiện &iacute;ch nhất tại Park Hill Premium với quảng trường v&agrave; m&aacute;i v&ograve;m k&iacute;nh, s&acirc;n chơi trẻ em, s&acirc;n chơi s&aacute;ng tạo, hệ thống vườn xanh m&aacute;t, cảnh quan đường phố v&agrave; bể bơi ngo&agrave;i trời d&agrave;i tới gần 80m&hellip; Đặc biệt, Park 10 c&oacute; thiết kế vườn sinh thái theo phong cách Nh&acirc;̣t và khu vực nướng BBQ tr&ecirc;n tầng mái của t&ograve;a nh&agrave;. Trong đ&oacute;, vườn sinh thái theo phong cách Nhật là địa đi&ecirc;̉m lý tưởng d&agrave;nh ri&ecirc;ng cho cư d&acirc;n Park 10 thư giãn, ngắm cảnh c&ograve;n vườn nướng BBQ phục vụ cho những bữa tiệc sum vầy ngo&agrave;i trời - một kh&ocirc;ng gian vườn độc đ&aacute;o chỉ c&oacute; tại t&ograve;a Park 10 - Master Premium.</p>

<p>L&agrave; t&ograve;a căn hộ cuối c&ugrave;ng mở b&aacute;n của khu đ&ocirc; thị Times City, Park 10 - Master Premium mang đ&ecirc;́n cơ h&ocirc;̣i cu&ocirc;́i cùng để kh&aacute;ch h&agrave;ng gia nhập một trong ba khu đ&ocirc; thị đ&aacute;ng sống nhất Việt Nam năm 2015.</p>

<p>---</p>

<p><strong><em>Lễ mở b&aacute;n t&ograve;a Park 10, Vinhomes Times City - Park Hill Premium sẽ được tổ chức v&agrave;o 14h00 ng&agrave;y 26/03/2016 tại Trung t&acirc;m hội nghị v&agrave; ẩm thực quốc tế Almaz - Vinhomes Riverside, Long Bi&ecirc;n, H&agrave; Nội.</em></strong></p>

<p><strong><em>Kh&aacute;ch h&agrave;ng tham dự sự kiện c&oacute; cơ hội bốc thăm tr&uacute;ng voucher VinMart với tổng trị gi&aacute; 30 triệu đồng. Kh&aacute;ch h&agrave;ng đặt cọc mua căn hộ c&ograve;n th&ecirc;m cơ hội bốc thăm tr&uacute;ng voucher mua sắm tại VinPro với giải Nhất trị gi&aacute; 30 triệu đồng c&ugrave;ng nhiều giải thưởng c&oacute; gi&aacute; trị kh&aacute;c.</em></strong></p>

<p><strong><em>Xem th&ecirc;m th&ocirc;ng tin dự &aacute;n:&nbsp;http://parkhill-premium.vinhomes.vn</em></strong></p>
')

    Post.create!(title: 'VINHOMES RIVERSIDE SÔI ĐỘNG VÀ RỰC RỠ VỚI COLOR ME RUN 2016',
      content: '<p>Thứ 7 ng&agrave;y 28/5 vừa qua, giới trẻ H&agrave; Nội h&agrave;o hứng tham gia s&acirc;n chơi Color Me Run được tổ chức quy m&ocirc; tại khu đ&ocirc; thị sinh th&aacute;i Vinhomes Riverside. Đ&acirc;y l&agrave; lần thứ 2 sự kiện thể thao sắc m&agrave;u ngo&agrave;i trời lớn nhất Việt Nam diễn ra tại đ&acirc;y.</p>

<p><img alt="1.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/1.jpg" width="600" /></p>

<p><em>Color Me Run &ndash; Đường chạy sắc m&agrave;u 2016 đ&atilde; thu h&uacute;t h&agrave;ng ngh&igrave;n người tham gia</em></p>

<p>Mặc d&ugrave; 15h00 sự kiện mới ch&iacute;nh thức bắt đầu nhưng h&agrave;ng chục ngh&igrave;n người tham gia ở mọi lứa tuổi đ&atilde; c&oacute; mặt tại khu vực đường 81, trước cửa Trung t&acirc;m thương mại Vincom Long Bi&ecirc;n để chuẩn bị xuất ph&aacute;t tr&ecirc;n những con đường đầy m&agrave;u sắc của Vinhomes Riverside.</p>

<p><img alt="2.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/2.jpg" width="600" /></p>

<p><em>C&aacute;c bạn trẻ hứng th&uacute; tạo d&aacute;ng trước Trung t&acirc;m thương mại Vincom Long Bi&ecirc;n</em></p>

<p><img alt="3.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/3.jpg" width="600" /></p>

<p><em>Kh&ocirc;ng</em><em>&nbsp;chỉ l&agrave; sự kiện chạy bộ suốt tuyến đường gần 5km, Color Me Run c&ograve;n l&agrave; sự kiện lễ hội &acirc;m nhạc rực rỡ sắc m&agrave;u với s&acirc;n khấu ca nhạc ho&agrave;nh tr&aacute;ng</em></p>

<p>&nbsp;<img alt="4.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/4.jpg" width="600" /></p>

<p><em>D&ugrave; đ&atilde; thấm mệt nhưng c&aacute;c bạn trẻ vẫn h&agrave;o hứng lưu giữ lại khoảnh khắc c&ugrave;ng thi&ecirc;n nhi&ecirc;n v&agrave; cảnh quan Vinhomes Riverside.</em></p>

<p>Kh&ocirc;ng gian rộng lớn, c&ugrave;ng hệ thống c&acirc;y xanh v&agrave; k&ecirc;nh đ&agrave;o chỉ duy nhất c&oacute; tại Vinhomes Riverside đ&atilde; tạo n&ecirc;n n&eacute;t độc đ&aacute;o cho sự kiện, bởi vậy cho d&ugrave; đến chặng cuối c&ugrave;ng c&aacute;c bạn trẻ c&oacute; thấm mệt nhưng vẫn về đ&iacute;ch h&agrave;o hứng.</p>

<p><img alt="5.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/5.jpg" width="600" /></p>

<p><em>Những gương mặt rạng rỡ khi c&aacute;n đ&iacute;ch sau 5km đường chạy sắc m&agrave;u quanh Khu đ&ocirc; thị Vinhomes Riverside</em>.</p>

<p><img alt="7.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/2016/color-me-run2016/7.jpg" width="600" /></p>

<p><em>S&acirc;n khấu ngo&agrave;i trời s&ocirc;i động tại Quảng trường Trung t&acirc;m thương mại Vincom Long Bi&ecirc;n</em></p>

<p>S&acirc;n khấu ca nhạc ngo&agrave;i trời l&agrave; điểm nhấn giữ ch&acirc;n c&aacute;c bạn trẻ ở lại tới buổi tối của chương tr&igrave;nh. Vinhomes Riverside rực rỡ về đ&ecirc;m với c&aacute;c m&agrave;n tr&igrave;nh diễn đặc sắc của nghệ sỹ nước ngo&agrave;i DJ Mathew, ca sỹ Vũ C&aacute;t Tường, Ti&ecirc;n Ti&ecirc;n.</p>

<p>Vinhomes Riverside lu&ocirc;n l&agrave; địa điểm được lựa chọn h&agrave;ng đầu cho c&aacute;c sự kiện văn h&oacute;a v&agrave; thể thao c&oacute; quy m&ocirc; lớn như Đường chạy sắc m&agrave;u, Lễ hội sinh vật cảnh thủ đ&ocirc;.</p>
')

    Post.create!(title: 'VINHOME CÔNG BỐ 3 GÓI CHÍNH SÁCH BÁN HÀNG ĐẶC BIỆT',
      content: '<p><img alt="vhr1.jpg" src="http://vinhomes.vn/Cms_Data/Contents/Vinhomes_DB/Media/Tintuc/VHR-moi/vhr1.jpg" width="600" /></p>

<p><strong><em>Nhằm tối ưu h&oacute;a lợi &iacute;ch cho kh&aacute;ch h&agrave;ng, từ 15/3/2016, Vinhomes Riverside &aacute;p dụng ba g&oacute;i ch&iacute;nh s&aacute;ch b&aacute;n h&agrave;ng đặc biệt ưu đ&atilde;i, d&agrave;nh cho kh&aacute;ch mua biệt thự tạ</em></strong><strong><em>i khu đ&ocirc; thị n&agrave;y. C&aacute;c g&oacute;i ch&iacute;nh s&aacute;ch được thiết kế ưu việt, đ&aacute;p ứng nhu cầu chuy&ecirc;n biệt: để ở,&nbsp; đầu tư ngắn hạn v&agrave; đầu tư trung &ndash; d&agrave;i hạn.</em></strong></p>

<p>Theo đ&oacute;, kh&aacute;ch h&agrave;ng mua biệt thự Vinhomes Riverside để ở sẽ&nbsp;được hỗ trợ vay vốn l&ecirc;n tới 70% gi&aacute; trị biệt thự với l&atilde;i suất 0% trong v&ograve;ng 3 năm. Như vậy, chỉ với 30% gi&aacute; trị, kh&aacute;ch h&agrave;ng c&oacute; thể sở hữu ngay biệt thự Vinhomes Riverside. Trong trường hợp kh&aacute;ch muốn vay vốn trong v&ograve;ng 4 năm, sẽ được hưởng l&atilde;i suất 0% trong 2 năm đầu ti&ecirc;n. C&aacute;c năm tiếp theo, Chủ đầu tư sẽ hỗ trợ l&atilde;i suất 8,5%/năm, kh&aacute;ch h&agrave;ng chỉ cần trả phần ch&ecirc;nh lệch l&atilde;i suất c&ograve;n lại cho ng&acirc;n h&agrave;ng.</p>

<p>Với kh&aacute;ch h&agrave;ng c&oacute; nhu cầu đầu tư ngắn hạn,&nbsp;ngoài vi&ecirc;̣c được ưu đãi vay 70% với lãi su&acirc;́t 0% trong vòng 2 năm, còn được Chủ đ&acirc;̀u tư h&ocirc;̃ trợ 4,5 triệu đồng/m2 x&acirc;y dựng, với tổng chi ph&iacute; c&oacute; thể l&ecirc;n tới 3 tỷ đồng m&ocirc;̃i căn để sửa chữa, ho&agrave;n thiện nội thất.&nbsp;Như vậy, kh&aacute;ch h&agrave;ng c&oacute; thể mua biệt thự, ho&agrave;n thiện v&agrave; b&aacute;n lại sinh lời ngay sau đ&oacute;.</p>

<p>Đặc biệt, g&oacute;i ch&iacute;nh s&aacute;ch d&agrave;nh cho c&aacute;c nh&agrave; đầu tư trung &ndash; d&agrave;i hạn chỉ &aacute;p dụng duy nhất cho khu&nbsp;Hoa Sữa Aroma &ndash; tiểu khu d&agrave;nh ri&ecirc;ng cho thu&ecirc; thuộc ph&acirc;n khu Hoa Sữa. Hoa Sữa Aroma hiện c&oacute; gần 100 căn biệt thự, được b&agrave;n giao ho&agrave;n thiện với nội thất liền tường v&agrave; nội thất đồ rời sang trọng. Cụ thể, kh&aacute;ch h&agrave;ng mua biệt thự Hoa Sữa Aroma sẽ được vay 70% gi&aacute; trị biệt thự trong v&ograve;ng 18 th&aacute;ng v&agrave; được hỗ trợ l&atilde;i suất 0%; đồng thời, chủ đầu tư cam kết nhận thu&ecirc; lại biệt thự với lợi nhuận chia sẻ l&ecirc;n đến 7%/năm trong v&ograve;ng 3 năm. Trong trường hợp nh&agrave; đầu tư muốn k&eacute;o d&agrave;i thời hạn vay 70% gi&aacute; trị biệt thự l&ecirc;n 24 th&aacute;ng với mức hỗ trợ l&atilde;i suất 0% th&igrave; sẽ nhận cam kết lợi nhuận l&agrave; 6%/năm trong v&ograve;ng 2 năm. Đ&acirc;y l&agrave; ch&iacute;nh s&aacute;ch đột ph&aacute; được thiết kế ưu việt cho mục ti&ecirc;u đầu tư nhằm cho thu&ecirc; sinh lời, lần đầu ti&ecirc;n được &aacute;p dụng tại Vinhomes Riverside.</p>

<p>Được mệnh danh l&agrave; &ldquo;Venice giữa l&ograve;ng H&agrave; Nội&rdquo;, c&aacute;c biệt thự sang trọng Vinhomes Riverside lu&ocirc;n c&oacute; lượng kh&aacute;ch thu&ecirc; ổn định, đặc biệt ph&ugrave; hợp với c&aacute;c kh&aacute;ch h&agrave;ng nước ngo&agrave;i c&oacute; y&ecirc;u cầu cao về chất lượng v&agrave; kh&ocirc;ng gian sống. Trong đ&oacute;, Hoa Sữa Aroma hứa hẹn sẽ trở th&agrave;nh một điểm đến ưu ti&ecirc;n của cộng đồng kh&aacute;ch thu&ecirc; quốc tế văn minh v&agrave; hiện đại.</p>

<p>Cũng theo ch&iacute;nh s&aacute;ch mới nhất, tất cả&nbsp;kh&aacute;ch h&agrave;ng đăng k&yacute; mua biệt thự&nbsp;Vinhomes Riverside&nbsp;sẽ nhận được một trong hai qu&agrave; tặng:Thẻ bảo hiểm sức khỏe Platinum cho cả gia đ&igrave;nh trong 2 năm tại Bệnh viện Đa khoa Quốc tế Vinmec trị gi&aacute; 180 triệu đồng; hoặc 160 triệu đồng tiền mặt. Kh&aacute;ch h&agrave;ng đồng thời được tặng 1 thẻ trả trước để sử dụng Dịch vụ Xe cao cấp trị gi&aacute; 200 triệu đồng hoặc 1 voucher mua h&agrave;ng trị gi&aacute; 150 triệu đồng tại VinPro.</p>

<p><em>Chương tr&igrave;nh được &aacute;p dụng c&oacute; điều kiện. Đ</em><em>ể&nbsp;</em><em>bi</em><em>ế</em><em>t th&ecirc;m th&ocirc;ng tin chi ti</em><em>ế</em><em>t, vui l&ograve;ng li&ecirc;n h</em><em>ệ&nbsp;</em><em>hotline: 091.429.6666.</em></p>
')
    Post.create!(title: 'THÔNG BÁO SỬ DỤNG HÓA ĐƠN ĐIỆN TỬ',
      content: '<p><strong><em>K&iacute;nh gửi</em></strong><strong>: Qu&yacute; Kh&aacute;ch h&agrave;ng/Đối t&aacute;c</strong></p>

<p>Trước hết, C&ocirc;ng ty TNHH quản l&yacute; Bất động sản Vinhomes (&ldquo;<strong>C&ocirc;ng Ty Vinhomes</strong>&rdquo;) tr&acirc;n trọng cảm ơn Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c đ&atilde; hợp t&aacute;c v&agrave; sử dụng dịch vụ của ch&uacute;ng t&ocirc;i trong suốt thời gian qua.</p>

<p>Thực hiện Th&ocirc;ng tư số 32/2011/TT-BTC ng&agrave;y 14/3/2011 về việc hướng dẫn khởi tạo, ph&aacute;t h&agrave;nh v&agrave; sử dụng ho&aacute; đơn điện tử b&aacute;n h&agrave;ng ho&aacute;, cung ứng dịch vụ v&agrave; Nghị định số 51/2010/NĐ-CP ng&agrave;y 14/5/2010 qui định về h&oacute;a đơn b&aacute;n h&agrave;ng h&oacute;a, cung ứng dịch vụ; c&ugrave;ng với mong muốn mang đến sự thuận tiện cho Qu&yacute; kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c trong việc quản l&yacute;, lưu trữ, t&igrave;m kiếm, sử dụng h&oacute;a đơn, thực hiện c&aacute;c giao dịch li&ecirc;n quan đến thủ tục k&ecirc; khai v&agrave; b&aacute;o c&aacute;o thuế,&nbsp;C&ocirc;ng Ty Vinhomes quyết định việc chuyển đổi từ h&igrave;nh thức h&oacute;a đơn bằng giấy như trước đ&acirc;y sang h&igrave;nh thức h&oacute;a đơn điện tử kể từ th&aacute;ng<strong>4/2016</strong>.</p>

<p>Vậy, bằng th&ocirc;ng b&aacute;o n&agrave;y, ch&uacute;ng t&ocirc;i tr&acirc;n trọng th&ocirc;ng b&aacute;o đến Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c để nắm th&ocirc;ng tin v&agrave; tiếp tục hợp t&aacute;c với C&ocirc;ng Ty Vinhomes trong việc chuyển đối h&igrave;nh thức h&oacute;a đơn điện tử n&ecirc;u tr&ecirc;n.</p>

<p>Để Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c thuận tiện trong việc sử dụng h&oacute;a đơn điện tử, C&ocirc;ng Ty Vinhomes vẫn sử dụng Phiếu thu/B&aacute;o c&oacute; như trước đ&acirc;y để x&aacute;c nhận l&agrave; Qu&yacute; Kh&aacute;ch h&agrave;ng/Đối t&aacute;c đ&atilde; thanh to&aacute;n dịch vụ.&nbsp;Khi c&oacute; nhu cầu tra cứu h&oacute;a đơn, quyết to&aacute;n thuế, Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c c&oacute; thể xem, tải h&oacute;a đơn tại địa chỉ Website:<strong>&nbsp;</strong><a href="https://einvoice.vingroup.net/">https://einvoice.vingroup.net</a>theo t&ecirc;n đăng nhập v&agrave; mật khẩu được gửi đến địa chỉ Email đ&atilde; được Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c đăng k&yacute;.</p>

<p>Trong trường hợp cần cung cấp th&ecirc;m th&ocirc;ng tin, Qu&yacute; Kh&aacute;ch h&agrave;ng/Qu&yacute; Đối t&aacute;c vui l&ograve;ng li&ecirc;n hệ với Bộ phận Lễ t&acirc;n Khu Căn hộ/Lễ t&acirc;n dịch vụ của C&ocirc;ng Ty Vinhomes hoặc qua số điện thoại (043) 975 6699để được hỗ trợ kịp thời.</p>

<p>Tr&acirc;n trọng cảm ơn!</p>
')

    Post.create!(title: 'THÔNG BÁO NỘP TIỀN PHÍ DỊCH VỤ THÁNG 08/2016',
      content: '<p align="center"><strong>ROYAL: TH&Ocirc;NG B&Aacute;O NỘP TIỀN DỊCH VỤ TH&Aacute;NG 08/2016</strong></p>

<p align="center"><b>CƯ D&Acirc;N L&Agrave; TH&Agrave;NH VI&Ecirc;N CỦA CHUNG CƯ ROYAL</b></p>

<p>&nbsp;</p>

<p>Căn cứ hợp đồng về việc sử dụng dịch vụ của chung cư royal, cư d&acirc;n c&oacute; thể đến trực tiếp hoặc hỏi th&ocirc;ng tin th&ocirc;ng qua email royal@example.com để biết th&ocirc;ng tin số tiền cần phải thanh to&aacute;n trong th&aacute;ng 08/2016</p>

<p><strong><u>Thời hạn n&ocirc;̣p:</u></strong></p>

<p>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thời hạn nộp ph&iacute; c&aacute;c dịch vụ th&aacute;ng 08&nbsp;l&agrave; trước&nbsp;<strong>17h00 ng&agrave;y</strong>&nbsp;<strong><u>03/09/2016.</u></strong></p>

<p>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<em>Thời hạn nộp học ph&iacute; t&iacute;nh theo ng&agrave;y cư d&acirc;n&nbsp;chuyển tiền (được ghi tr&ecirc;n giấy nộp tiền, ủy nhiệm chi) hoặc l&agrave; ng&agrave;y nộp trực tiếp tại ban quản l&iacute; chung cư</em></p>

<p><strong><u>H&igrave;nh thức nộp</u></strong></p>

<p>&middot; &nbsp; &nbsp; &nbsp; &nbsp; Cư d&acirc;n nộp ph&iacute; dịch vụ&nbsp;<strong>bằng h&igrave;nh thức nộp trực tiếp tại ban quản l&iacute; chung cư hoặc chuyển khoản&nbsp;</strong>theo th&ocirc;ng tin sau tr&ecirc;n giấy nộp tiền:</p>

<table border="1" cellpadding="0" cellspacing="0" width="642">
  <tbody>
    <tr>
      <td>
      <p align="center">T&ecirc;n&nbsp; t&agrave;i khoản</p>
      </td>
      <td>
      <p align="center">BAN QUẢN L&Iacute; T&Ograve;A NH&Agrave; ROYAL</p>
      </td>
    </tr>
    <tr>
      <td>
      <p align="center">Số t&agrave;i khoản</p>
      </td>
      <td>
      <p align="center"><strong>4271 0005 585858</strong></p>
      </td>
    </tr>
    <tr>
      <td>
      <p align="center">Ng&acirc;n H&agrave;ng</p>
      </td>
      <td>
      <p align="center">NG&Acirc;N H&Agrave;NG TMCP ĐT&amp;PT VIỆT NAM &ndash; CHI NH&Aacute;NH QUANG MINH</p>
      </td>
    </tr>
    <tr>
      <td>
      <p align="center">Số tiền nộp</p>
      </td>
      <td>
      <p>Số tiền đ&oacute;ng</p>
      </td>
    </tr>
    <tr>
      <td>
      <p align="center">Nội dung</p>
      </td>
      <td>
      <p>- Nộp ph&iacute;&nbsp;<strong>&ndash; số tiền - </strong>cho mặt bằng<strong>&nbsp;&ndash; t&ecirc;n mặt bằng - người nộp - số điện thoại người nộp</strong></p>

      <p>(V&iacute; dụ: Nộp&nbsp;ph&iacute; 5.200.000đ cho mặt bằng R1-100 -&nbsp;<strong>Nguyễn Văn A &ndash; 090x&hellip;..</strong>)</p>
      </td>
    </tr>
  </tbody>
</table>

<p>&nbsp;</p>

<p>&middot; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</p>

<p><em>H&agrave; Nội, ng&agrave;y 28&nbsp;th&aacute;ng 08 năm 2016</em></p>

<p><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; PH&Ograve;NG T&Agrave;I VỤ</strong></p>
')

    Apartment::Tenant.switch
  end # end royal
end
