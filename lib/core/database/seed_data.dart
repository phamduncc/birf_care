import 'package:sqflite/sqflite.dart';

class SeedData {
  static Future<void> populateSeedData(Database db) async {
    // 1. Populate Food Database
    final foods = [
      // Safe
      {
        'id': 'food_01',
        'name': 'Carrot',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Vegetables',
        'portion': '2–3 thin slices / week',
        'preparation': 'Wash, shred, or cut into thin pieces. A small whole piece can be left for the bird to nibble.',
        'warnings': 'High in beta-carotene, which helps keep feathers glossy.',
        'description': 'Rich in vitamin A, good for the eyes, beak, and feathers.',
      },
      {
        'id': 'food_02',
        'name': 'Apple',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Fruit',
        'portion': '1 small piece (1–2 times / week)',
        'preparation': 'REMOVE ALL SEEDS AND THE CORE. Wash thoroughly; peel or scrub the skin well.',
        'warnings': 'Apple seeds contain cyanide and are highly toxic to birds.',
        'description': 'High in fiber and vitamin C, with a natural sweetness birds enjoy.',
      },
      {
        'id': 'food_03',
        'name': 'Broccoli',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Leafy greens',
        'portion': '1 small floret',
        'preparation': 'Rinse well, chop the florets, or offer a small whole floret.',
        'warnings': 'Do not overfeed, or it may cause gas.',
        'description': 'Very rich in calcium, vitamin C, and vitamin K.',
      },
      {
        'id': 'food_04',
        'name': 'Ripe banana',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Fruit',
        'portion': '1 thin slice / week',
        'preparation': 'Peel and cut into thin slices.',
        'warnings': 'High in sugar. Offer only in moderation.',
        'description': 'Rich in potassium and vitamin B6, and provides quick energy.',
      },
      {
        'id': 'food_05',
        'name': 'Spinach',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Leafy greens',
        'portion': '1 small leaf / week',
        'preparation': 'Wash thoroughly to remove soil, then chop.',
        'warnings': 'Contains oxalate. Do not feed daily, because it can block calcium absorption.',
        'description': 'Rich in iron and folic acid.',
      },
      {
        'id': 'food_06',
        'name': 'Millet',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Seeds',
        'portion': 'Daily staple, or a millet spray as a treat',
        'preparation': 'Serve in a clean food cup and keep it dry.',
        'warnings': 'A main energy source for budgies, finches, and cockatiels.',
        'description': 'Easy to digest and suitable for most pet birds.',
      },
      {
        'id': 'food_07',
        'name': 'Cucumber',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Vegetables',
        'portion': '2 thin slices on hot days',
        'preparation': 'Wash and slice thinly.',
        'warnings': 'Mostly water. Large amounts may cause temporarily loose droppings.',
        'description': 'A good way to help birds stay cool in hot weather.',
      },
      {
        'id': 'food_08',
        'name': 'Fresh corn',
        'english_name': null,
        'category': 'Safe',
        'food_group': 'Vegetables',
        'portion': '1/2 small piece / week',
        'preparation': 'Wash fresh corn, or steam it lightly.',
        'warnings': 'Birds enjoy nibbling the kernels.',
        'description': 'A healthy source of starch and energy.',
      },
      // Limit
      {
        'id': 'food_09',
        'name': 'Sunflower seeds',
        'english_name': null,
        'category': 'Limit',
        'food_group': 'Seeds',
        'portion': '3–5 seeds / day (large birds), 1–2 seeds (small birds)',
        'preparation': 'Use unsalted, unroasted seeds in the shell.',
        'warnings': 'Very high in fat. Too many can cause obesity and liver damage.',
        'description': 'Best used as a training treat.',
      },
      {
        'id': 'food_10',
        'name': 'Peanuts',
        'english_name': null,
        'category': 'Limit',
        'food_group': 'Seeds',
        'portion': '1/2 nut / week',
        'preparation': 'Shell them, and offer only raw, unsalted nuts.',
        'warnings': 'Shells can harbor aflatoxin mold, which is toxic to the liver.',
        'description': 'High in protein and fat. Keep the amount small.',
      },
      {
        'id': 'food_11',
        'name': 'Fresh grapes',
        'english_name': null,
        'category': 'Limit',
        'food_group': 'Fruit',
        'portion': '1/2 grape / week',
        'preparation': 'Wash thoroughly, remove seeds, and cut in half.',
        'warnings': 'High in sugar. Too many can upset digestion.',
        'description': 'Adds moisture and a sweet taste.',
      },
      // Dangerous
      {
        'id': 'food_12',
        'name': 'Avocado',
        'english_name': null,
        'category': 'Dangerous',
        'food_group': 'Toxic',
        'portion': 'DO NOT FEED',
        'preparation': 'NEVER OFFER',
        'warnings': 'HIGHLY TOXIC. Contains persin, which can cause heart failure and rapid death in birds.',
        'description': 'Every part of the avocado is life-threatening to birds.',
      },
      {
        'id': 'food_13',
        'name': 'Chocolate',
        'english_name': null,
        'category': 'Dangerous',
        'food_group': 'Toxic',
        'portion': 'DO NOT FEED',
        'preparation': 'NEVER OFFER',
        'warnings': 'HIGHLY TOXIC. Theobromine and caffeine can cause seizures, vomiting, and death.',
        'description': 'Directly affects a bird’s nervous system and heart.',
      },
      {
        'id': 'food_14',
        'name': 'Coffee, alcohol, and caffeinated drinks',
        'english_name': null,
        'category': 'Dangerous',
        'food_group': 'Toxic',
        'portion': 'DO NOT FEED',
        'preparation': 'NEVER OFFER',
        'warnings': 'HIGHLY TOXIC. Can cause heart failure and a sudden rise in heart rate.',
        'description': 'Because birds are small, caffeine affects them very severely.',
      },
      {
        'id': 'food_15',
        'name': 'Onion and garlic',
        'english_name': null,
        'category': 'Dangerous',
        'food_group': 'Toxic',
        'portion': 'DO NOT FEED',
        'preparation': 'NEVER OFFER',
        'warnings': 'TOXIC. Destroys red blood cells and can cause acute anemia in birds.',
        'description': 'Contains sulfur compounds that damage blood cells.',
      },
    ];

    for (var f in foods) {
      await db.insert('foods', f, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 4. Populate Articles (Knowledge Base)
    final articles = [
      {
        'id': 'art_01',
        'title': 'Bringing a new bird home',
        'category': 'Basics',
        'read_time_minutes': 4,
        'content': '''# Bringing a new bird home

A newly arrived bird is often frightened and stressed by the change of environment.

## 1. Prepare the cage first
- Place the cage in a quiet spot with little foot traffic for the first 24–48 hours.
- Avoid harsh direct sun and strong drafts.
- Have clean water and the bird’s familiar food ready.

## 2. Let the bird settle
- Do not try to catch or pet the bird on the first day.
- Drape a light cloth over three sides of the cage so the bird feels safer.
- Talk in a low, warm, gentle voice.

## 3. Watch droppings, food, and water
- Check that the bird comes down to eat and drink.
- Droppings may be slightly loose on the first day because of stress, but they should return to normal within 24–36 hours.
''',
      },
      {
        'id': 'art_02',
        'title': 'A balanced diet for pet birds',
        'category': 'Nutrition',
        'read_time_minutes': 5,
        'content': '''# A balanced diet for pet birds

A seed-only diet is often low in vitamin A and calcium, and too high in fat.

## 1. Suggested balance
- **60% quality seed or pellets**: millet, oats, canary seed, or a formulated mix.
- **30% fresh vegetables**: carrot, broccoli, leafy greens, sweet corn.
- **10% fruit and extras**: apple, banana, cucumber, and a cuttlebone for calcium.

## 2. Calcium and minerals
- Always hang a **cuttlebone** or mineral block in the cage so the bird can wear the beak and get calcium for bones and eggshells.
- Provide fresh water, replaced once or twice a day.
''',
      },
      {
        'id': 'art_03',
        'title': 'Safe cage cleaning and disinfection',
        'category': 'Hygiene',
        'read_time_minutes': 3,
        'content': '''# Safe cage cleaning and disinfection

Clean housing prevents most respiratory problems and fungal issues in pet birds.

## Cleaning schedule
1. **Daily**
   - Change the cage liner.
   - Wash water and food cups.
2. **Weekly**
   - Scrub perches to remove stuck droppings.
   - Wipe cage bars with warm water.
3. **Monthly**
   - Disinfect the whole cage with diluted white vinegar (1:1) or a pet-safe disinfectant.
   - Dry the cage in sunlight before putting the bird back.
''',
      },
      {
        'id': 'art_04',
        'title': 'Early signs that a bird is sick',
        'category': 'Health',
        'read_time_minutes': 4,
        'content': '''# Early signs that a bird is sick

Birds hide illness well. By the time signs are obvious, the problem is often already serious.

## Emergency warning signs
- **Constant fluffing**: the bird stays huddled, feathers puffed, head tucked into a wing all day.
- **Rapid weight loss**: the keel bone feels sharp, or weight drops more than 10%.
- **Labored breathing**: tail bobbing, open-mouth breathing, or wheezing.
- **Abnormal droppings**: blood, or watery droppings lasting more than a day.
- **Slow blinking or a wet nose**: discharge sticking food around the nostrils.

## What to do right away
1. Keep the bird warm with a low-wattage lamp at a safe distance.
2. See an avian veterinarian as soon as possible.
''',
      },
      {
        'id': 'art_05',
        'title': 'Taming a bird to step up',
        'category': 'Behavior',
        'read_time_minutes': 4,
        'content': '''# Taming a bird to step up

Training takes daily patience. Do not rush it.

## Step-up training
1. **Start with food**: find the favorite treat, such as a millet spray or a sunflower seed.
2. **Offer it through the bars**: let the bird choose to come toward your hand.
3. **Rest your hand in the cage**: keep it still, with no sudden movement.
4. **The “step up” cue**: place a finger gently in front of the chest and say “step up” so the bird steps onto it.
5. **Reward immediately**: give a seed and praise in a cheerful voice every time the bird does it.
''',
      },
    ];

    for (var a in articles) {
      await db.insert('articles', a, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 5. Default Care Reminders
    final reminders = [
      {
        'id': 'rem_01',
        'bird_id': null,
        'title': 'Feed the bird and check the seed cup',
        'time': '08:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Feed',
      },
      {
        'id': 'rem_02',
        'bird_id': null,
        'title': 'Change the drinking water',
        'time': '12:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Water',
      },
      {
        'id': 'rem_03',
        'bird_id': null,
        'title': 'Clean the cage tray liner',
        'time': '18:00',
        'repeat_days': '1,2,3,4,5,6,7',
        'is_enabled': 1,
        'category': 'Clean',
      },
    ];

    for (var r in reminders) {
      await db.insert('reminders', r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
