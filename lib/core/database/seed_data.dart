import 'package:sqflite/sqflite.dart';

class SeedData {
  static Future<void> populateSeedData(Database db) async {
    // 1. Populate Food Database
    final foods = [
      // Safe 🟢
      {
        'id': 'food_01',
        'name': 'Cà rốt',
        'english_name': 'Carrot',
        'category': 'Safe',
        'food_group': 'Rau củ',
        'portion': '2-3 lát mỏng / tuần',
        'preparation': 'Rửa sạch, bào sợi hoặc cắt hạt lựu mỏng. Có thể để nguyên củ nhỏ cho chim gặm.',
        'warnings': 'Chứa nhiều Beta-carotene giúp lông bóng mượt.',
        'description': 'Giàu vitamin A, tốt cho mắt, mỏ và lông chim.',
      },
      {
        'id': 'food_02',
        'name': 'Táo tây',
        'english_name': 'Apple',
        'category': 'Safe',
        'food_group': 'Trái cây',
        'portion': '1 miếng nhỏ / lần (1-2 lần/tuần)',
        'preparation': 'BỎ HOÀN TOÀN HẠT VÀ LÕI. Rửa sạch gọt vỏ hoặc giữ vỏ rửa kỹ.',
        'warnings': '⚠️ Hạt táo chứa Cyanide cực độc với chim!',
        'description': 'Giàu chất xơ và vitamin C, vị ngọt tự nhiên chim rất thích.',
      },
      {
        'id': 'food_03',
        'name': 'Bông cải xanh',
        'english_name': 'Broccoli',
        'category': 'Safe',
        'food_group': 'Rau xanh',
        'portion': '1 nhánh nhỏ / lần',
        'preparation': 'Rửa kỹ dưới vòi nước, thái nhỏ búp hoặc để nguyên nhánh nhỏ.',
        'warnings': 'Không cho ăn quá nhiều để tránh đầy hơi.',
        'description': 'Rất giàu Canxi, Vitamin C và K.',
      },
      {
        'id': 'food_04',
        'name': 'Chuối chín',
        'english_name': 'Banana',
        'category': 'Safe',
        'food_group': 'Trái cây',
        'portion': '1 lát mỏng / tuần',
        'preparation': 'Bóc vỏ, cắt lát mỏng.',
        'warnings': 'Nhiều đường, cho ăn vừa phải.',
        'description': 'Giàu Kali và Vitamin B6, cung cấp năng lượng nhanh.',
      },
      {
        'id': 'food_05',
        'name': 'Rau bina / Cải bó xôi',
        'english_name': 'Spinach',
        'category': 'Safe',
        'food_group': 'Rau xanh',
        'portion': '1 lá nhỏ / tuần',
        'preparation': 'Rửa thật sạch đất cát, thái nhỏ.',
        'warnings': 'Chứa Oxalate, không nên cho ăn hàng ngày vì cản trở hấp thu Canxi.',
        'description': 'Giàu Sắt và Axit Folic.',
      },
      {
        'id': 'food_06',
        'name': 'Hạt kê',
        'english_name': 'Millet',
        'category': 'Safe',
        'food_group': 'Hạt dinh dưỡng',
        'portion': 'Thức ăn chính hàng ngày hoặc chùm kê thưởng',
        'preparation': 'Để trong cống ăn sạch, giữ khô ráo.',
        'warnings': 'Cung cấp năng lượng chính cho Yến phụng, Finch, Cockatiel.',
        'description': 'Dễ tiêu hóa, phù hợp cho hầu hết các loại chim cảnh.',
      },
      {
        'id': 'food_07',
        'name': 'Dưa leo / Dưa chuột',
        'english_name': 'Cucumber',
        'category': 'Safe',
        'food_group': 'Rau củ',
        'portion': '2 lát mỏng trong ngày nóng',
        'preparation': 'Rửa sạch, gọt mỏng.',
        'warnings': 'Chủ yếu là nước, cho ăn nhiều có thể gây phân lỏng nhẹ tạm thời.',
        'description': 'Giải nhiệt tuyệt vời vào mùa hè.',
      },
      {
        'id': 'food_08',
        'name': 'Bắp ngô tươi',
        'english_name': 'Sweetcorn',
        'category': 'Safe',
        'food_group': 'Rau củ',
        'portion': '1/2 khúc nhỏ / tuần',
        'preparation': 'Rửa sạch ngô tươi hoặc hấp chín nhẹ.',
        'warnings': 'Chim rất thích gặm hạt ngô.',
        'description': 'Giàu tinh bột và năng lượng lành mạnh.',
      },
      // Limit 🟡
      {
        'id': 'food_09',
        'name': 'Hạt hướng dương',
        'english_name': 'Sunflower Seeds',
        'category': 'Limit',
        'food_group': 'Hạt dinh dưỡng',
        'portion': '3-5 hạt / ngày (chim lớn), 1-2 hạt (chim nhỏ)',
        'preparation': 'Dùng hạt nguyên vỏ chưa rang muối.',
        'warnings': '⚠️ Rất nhiều chất béo! Cho ăn nhiều gây béo phì và tổn thương gan.',
        'description': 'Dùng làm phần thưởng khi huấn luyện.',
      },
      {
        'id': 'food_10',
        'name': 'Đậu phộng / Lạc',
        'english_name': 'Peanuts',
        'category': 'Limit',
        'food_group': 'Hạt dinh dưỡng',
        'portion': '1/2 hạt / tuần',
        'preparation': 'Tách vỏ, chỉ cho ăn hạt sống không muối.',
        'warnings': '⚠️ Vỏ lạc dễ chứa nấm mốc Aflatoxin gây độc gan.',
        'description': 'Nhiều đạm và chất béo, cần kiểm soát lượng ăn.',
      },
      {
        'id': 'food_11',
        'name': 'Nho tươi',
        'english_name': 'Grapes',
        'category': 'Limit',
        'food_group': 'Trái cây',
        'portion': '1/2 quả / tuần',
        'preparation': 'Rửa thật sạch, bỏ hạt, cắt đôi.',
        'warnings': 'Hàm lượng đường cao, cho ăn quá nhiều ảnh hưởng đường ruột.',
        'description': 'Cung cấp độ ẩm và vị ngọt.',
      },
      // Dangerous 🔴
      {
        'id': 'food_12',
        'name': 'Bơ (Avocado)',
        'english_name': 'Avocado',
        'category': 'Dangerous',
        'food_group': 'Độc hại',
        'portion': 'KHÔNG CHO ĂN',
        'preparation': 'TUYỆT ĐỐI KHÔNG',
        'warnings': '⛔ CỰC ĐỘC! Chứa độc tố Persin gây suy tim và tử vong nhanh ở chim!',
        'description': 'Tất cả các phần của quả bơ đều nguy hiểm tính mạng đối với chim.',
      },
      {
        'id': 'food_13',
        'name': 'Chocolate / Ca cao',
        'english_name': 'Chocolate',
        'category': 'Dangerous',
        'food_group': 'Độc hại',
        'portion': 'KHÔNG CHO ĂN',
        'preparation': 'TUYỆT ĐỐI KHÔNG',
        'warnings': '⛔ CỰC ĐỘC! Chứa Theobromine & Caffeine gây co giật, nôn mửa, tử vong.',
        'description': 'Ảnh hưởng trực tiếp đến hệ thần kinh và tim mạch của chim.',
      },
      {
        'id': 'food_14',
        'name': 'Cà phê & Đồ uống có cồn/caffeine',
        'english_name': 'Coffee & Alcohol',
        'category': 'Dangerous',
        'food_group': 'Độc hại',
        'portion': 'KHÔNG CHO ĂN',
        'preparation': 'TUYỆT ĐỐI KHÔNG',
        'warnings': '⛔ CỰC ĐỘC! Gây suy tim, tăng nhịp tim cấp tính.',
        'description': 'Chim có kích thước nhỏ nên phản ứng với caffeine vô cùng nghiêm trọng.',
      },
      {
        'id': 'food_15',
        'name': 'Hành & Tỏi',
        'english_name': 'Onions & Garlic',
        'category': 'Dangerous',
        'food_group': 'Độc hại',
        'portion': 'KHÔNG CHO ĂN',
        'preparation': 'TUYỆT ĐỐI KHÔNG',
        'warnings': '⛔ ĐỘC HẠI! Phá hủy hồng cầu gây thiếu máu cấp ở chim.',
        'description': 'Chứa hợp chất Sulfur gây hoại tử tế bào máu.',
      },
    ];

    for (var f in foods) {
      await db.insert('foods', f);
    }

    // 4. Populate Articles (Knowledge Base)
    final articles = [
      {
        'id': 'art_01',
        'title': 'Hướng dẫn đón chú chim mới về nhà',
        'category': 'Basics',
        'read_time_minutes': 4,
        'content': '''# Hướng dẫn đón chú chim mới về nhà

Khi mới đưa một chú chim về nhà, chim thường cảm thấy hoảng sợ và căng thẳng (stress) do thay đổi môi trường sống.

## 1. Chuẩn bị lồng nuôi trước
- Đặt lồng ở nơi yên tĩnh, ít người qua lại trong 24-48 giờ đầu.
- Tránh ánh nắng gay gắt chiếu trực tiếp hoặc luồng gió lùa mạnh.
- Chuẩn bị sẵn nước sạch và thức ăn quen thuộc của chim.

## 2. Giúp chim tĩnh dưỡng
- Không cố gắng bắt hoặc vuốt ve chim ngay ngày đầu tiên.
- Phủ một chiếc khăn mỏng quanh 3 mặt lồng để chim cảm thấy an toàn.
- Nói chuyện với chim bằng giọng trầm ấm, nhẹ nhàng.

## 3. Theo dõi phân và ăn uống
- Quan sát xem chim có xuống ăn và uống nước không.
- Phân chim ngày đầu có thể hơi lỏng do stress, nhưng phải trở lại bình thường sau 24-36 giờ.
''',
      },
      {
        'id': 'art_02',
        'title': 'Chế độ dinh dưỡng cân bằng cho chim cảnh',
        'category': 'Nutrition',
        'read_time_minutes': 5,
        'content': '''# Chế độ dinh dưỡng cân bằng cho chim cảnh

Một chế độ ăn chỉ toàn hạt đơn thuần (Seed-only diet) thường thiếu hụt Vitamin A, Canxi và quá nhiều chất béo.

## 1. Tỷ lệ dinh dưỡng khuyến nghị
- **60% Hạt / Pellet chất lượng cao**: Hạt kê, yến mạch, phalaris hoặc hạt tổng hợp.
- **30% Rau củ tươi**: Cà rốt, bông cải xanh, rau cải tươi, ngô ngọt.
- **10% Trái cây & Bổ sung**: Táo, chuối, dưa leo, mai mực (bổ sung Canxi).

## 2. Bổ sung Canxi & Khoáng chất
- Luôn treo **Mai mực (Cuttlebone)** hoặc đá liếm khoáng trong lồng để chim mài mỏ và bổ sung Canxi cho xương & vỏ trứng.
- Cung cấp nước sạch thay mới mỗi ngày 1-2 lần.
''',
      },
      {
        'id': 'art_03',
        'title': 'Quy trình vệ sinh lồng và khử khuẩn an toàn',
        'category': 'Hygiene',
        'read_time_minutes': 3,
        'content': '''# Quy trình vệ sinh lồng và khử khuẩn an toàn

Vệ sinh sạch sẽ giúp ngăn ngừa 90% các bệnh về đường hô hấp và nấm ở chim cảnh.

## Lịch vệ sinh:
1. **Hàng ngày**:
   - Thay giấy lót đáy lồng.
   - Rửa sạch cống nước và cống thức ăn.
2. **Hàng tuần**:
   - Rửa sạch cầu đậu (perch) loại bỏ phân bám dính.
   - Lau chùi nan lồng bằng nước ấm.
3. **Hàng tháng**:
   - Khử khuẩn toàn bộ lồng bằng giấm ăn pha loãng (tỷ lệ 1:1) hoặc dung dịch khử trùng chuyên dụng an toàn cho thú cưng.
   - Phơi khô lồng dưới ánh nắng mặt trời trước khi cho chim vào lại.
''',
      },
      {
        'id': 'art_04',
        'title': 'Nhận biết sớm các dấu hiệu chim bị ốm',
        'category': 'Health',
        'read_time_minutes': 4,
        'content': '''# Nhận biết sớm các dấu hiệu chim bị ốm

Chim là loài động vật giấu bệnh rất giỏi trong tự nhiên. Khi chim lộ rõ dấu hiệu ốm, bệnh thường đã ở giai đoạn nghiêm trọng.

## ⚠️ Các dấu hiệu cảnh báo khẩn cấp:
- **Xù lông liên tục**: Chim đứng co cụm, xù lông gục đầu vào cánh cả ngày.
- **Giảm cân nhanh**: Thần ngực trơ xương (lườn lẹm), cân nặng giảm >10%.
- **Thở gấp, há miệng**: Thở đuôi nhịp nhàng giật giật, có tiếng khè khè.
- **Phân bất thường**: Phân dính máu, phân toàn nước kéo dài >1 ngày.
- **Mắt chớp chậm, chảy nước mũi**: Mũi ướt dính thức ăn.

## Việc cần làm ngay:
1. Sưởi ấm cho chim bằng đèn vàng (30W) ở khoảng cách an toàn.
2. Đưa chim đến bác sĩ thú y chuyên về chim cảnh càng sớm càng tốt.
''',
      },
      {
        'id': 'art_05',
        'title': 'Taming & Huấn luyện chim làm quen chủ',
        'category': 'Behavior',
        'read_time_minutes': 4,
        'content': '''# Taming & Huấn luyện chim làm quen chủ

Huấn luyện chim cần sự kiên nhẫn từng ngày, không được nóng vội.

## Các bước thuần chim (Step Up):
1. **Bắt đầu bằng thức ăn**: Tìm món chim yêu thích nhất (như chùm kê hoặc hạt hướng dương).
2. **Đút ăn qua nan lồng**: Đút hạt qua kẽ lồng để chim chủ động tiến lại gần tay bạn.
3. **Đưa tay vào lồng**: Đặt tay đứng yên không di chuyển đột ngột.
4. **Lệnh "Step Up"**: Đặt nhẹ ngón tay trước ngực chim, hô nhẹ "Step up" để chim bước lên ngón tay.
5. **Thưởng ngay lập tức**: Thưởng hạt và khen ngợi bằng giọng vui vẻ mỗi khi chim làm đúng.
''',
      },
    ];

    for (var a in articles) {
      await db.insert('articles', a);
    }

    // 5. Default Care Reminders
    final reminders = [
      {
        'id': 'rem_01',
        'bird_id': null,
        'title': 'Cho chim ăn & kiểm tra cống hạt',
        'time': '08:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Feed',
      },
      {
        'id': 'rem_02',
        'bird_id': null,
        'title': 'Thay nước uống sạch',
        'time': '12:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Water',
      },
      {
        'id': 'rem_03',
        'bird_id': null,
        'title': 'Dọn lót khay đáy lồng',
        'time': '18:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Clean',
      },
    ];

    for (var r in reminders) {
      await db.insert('reminders', r);
    }
  }
}
