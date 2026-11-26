import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_scoring.dart';

void main() => runApp(const ImposterApp());

class GamePalette {
  const GamePalette({required this.name, required this.background, required this.card, required this.card2, required this.accent, required this.primary, required this.muted});
  final String name;
  final Color background, card, card2, accent, primary, muted;

  static GamePalette lerp(GamePalette a, GamePalette b, double t) => GamePalette(
    name: b.name,
    background: Color.lerp(a.background, b.background, t)!,
    card: Color.lerp(a.card, b.card, t)!,
    card2: Color.lerp(a.card2, b.card2, t)!,
    accent: Color.lerp(a.accent, b.accent, t)!,
    primary: Color.lerp(a.primary, b.primary, t)!,
    muted: Color.lerp(a.muted, b.muted, t)!,
  );
}

class GamePaletteTween extends Tween<GamePalette> {
  GamePaletteTween({super.begin, required super.end});

  @override
  GamePalette lerp(double t) => GamePalette.lerp(begin ?? end!, end!, t);
}

const List<GamePalette> gamePalettes = [
  GamePalette(name: 'Violet Pop', background: Color(0xFF090413), card: Color(0xFF211039), card2: Color(0xFF331452), accent: Color(0xFFAD40FF), primary: Color(0xFFFF1F61), muted: Color(0xFFB89ED9)),
  GamePalette(name: 'Ocean', background: Color(0xFF041116), card: Color(0xFF102C36), card2: Color(0xFF174453), accent: Color(0xFF35D4E8), primary: Color(0xFF00A6C7), muted: Color(0xFFA7DCE5)),
  GamePalette(name: 'Emerald', background: Color(0xFF06130D), card: Color(0xFF132C20), card2: Color(0xFF1D4430), accent: Color(0xFF57E39A), primary: Color(0xFF19B96C), muted: Color(0xFFB0E5C7)),
  GamePalette(name: 'Sunset', background: Color(0xFF1B0B08), card: Color(0xFF38201A), card2: Color(0xFF542D22), accent: Color(0xFFFFB15C), primary: Color(0xFFFF5C49), muted: Color(0xFFFFD2B7)),
  GamePalette(name: 'Rose', background: Color(0xFF190710), card: Color(0xFF351324), card2: Color(0xFF501A34), accent: Color(0xFFFF75B5), primary: Color(0xFFE92F78), muted: Color(0xFFF1B8D4)),
  GamePalette(name: 'Pop Party', background: Color(0xFFEAF6FF), card: Color(0xFFFFFFFF), card2: Color(0xFFDDEFFC), accent: Color(0xFF42477F), primary: Color(0xFF00BBDD), muted: Color(0xFF46506A)),
];

const Color good = Color(0xFF59D968);
const Color danger = Color(0xFFFF5968);

class WordEntry {
  const WordEntry(this.word, this.wordHi, this.category, this.categoryHi);
  final String word;
  final String wordHi;
  final String category;
  final String categoryHi;

  Map<String, dynamic> toJson() => {
        'word': word,
        'word_hi': wordHi,
        'category': category,
        'category_hi': categoryHi,
      };

  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        json['word'] as String? ?? '',
        json['word_hi'] as String? ?? '',
        json['category'] as String? ?? '',
        json['category_hi'] as String? ?? '',
      );
}

// Offline seed database. Additional entries can be added without changing game logic.
const List<WordEntry> wordDatabase = [
  WordEntry('Dog', 'कुत्ता', 'ANIMALS', 'जानवर'),
  WordEntry('Cat', 'बिल्ली', 'ANIMALS', 'जानवर'),
  WordEntry('Elephant', 'हाथी', 'ANIMALS', 'जानवर'),
  WordEntry('Lion', 'शेर', 'ANIMALS', 'जानवर'),
  WordEntry('Tiger', 'बाघ', 'ANIMALS', 'जानवर'),
  WordEntry('Giraffe', 'जिराफ़', 'ANIMALS', 'जानवर'),
  WordEntry('Zebra', 'ज़एबरअ', 'ANIMALS', 'जानवर'),
  WordEntry('Monkey', 'बंदर', 'ANIMALS', 'जानवर'),
  WordEntry('Gorilla', 'गओरइललअ', 'ANIMALS', 'जानवर'),
  WordEntry('Panda', 'पांडा', 'ANIMALS', 'जानवर'),
  WordEntry('Koala', 'कओअलअ', 'ANIMALS', 'जानवर'),
  WordEntry('Kangaroo', 'कअनगअरओओ', 'ANIMALS', 'जानवर'),
  WordEntry('Rabbit', 'खरगोश', 'ANIMALS', 'जानवर'),
  WordEntry('Hamster', 'हअमसटएर', 'ANIMALS', 'जानवर'),
  WordEntry('Hedgehog', 'हएडगएहओग', 'ANIMALS', 'जानवर'),
  WordEntry('Rat', 'रअट', 'ANIMALS', 'जानवर'),
  WordEntry('Squirrel', 'सकउइररएल', 'ANIMALS', 'जानवर'),
  WordEntry('Fox', 'लोमड़ी', 'ANIMALS', 'जानवर'),
  WordEntry('Wolf', 'भेड़िया', 'ANIMALS', 'जानवर'),
  WordEntry('Bear', 'भालू', 'ANIMALS', 'जानवर'),
  WordEntry('Deer', 'डएएर', 'ANIMALS', 'जानवर'),
  WordEntry('Moose', 'मओओसए', 'ANIMALS', 'जानवर'),
  WordEntry('Horse', 'घोड़ा', 'ANIMALS', 'जानवर'),
  WordEntry('Donkey', 'गधा', 'ANIMALS', 'जानवर'),
  WordEntry('Cow', 'गाय', 'ANIMALS', 'जानवर'),
  WordEntry('Buffalo', 'भैंस', 'ANIMALS', 'जानवर'),
  WordEntry('Goat', 'बकरी', 'ANIMALS', 'जानवर'),
  WordEntry('Sheep', 'भेड़', 'ANIMALS', 'जानवर'),
  WordEntry('Pig', 'सूअर', 'ANIMALS', 'जानवर'),
  WordEntry('Chicken', 'मुर्गी', 'ANIMALS', 'जानवर'),
  WordEntry('Duck', 'बत्तख', 'ANIMALS', 'जानवर'),
  WordEntry('Goose', 'गओओसए', 'ANIMALS', 'जानवर'),
  WordEntry('Turkey', 'टउरकएय', 'ANIMALS', 'जानवर'),
  WordEntry('Peacock', 'मोर', 'ANIMALS', 'जानवर'),
  WordEntry('Eagle', 'एअगलए', 'ANIMALS', 'जानवर'),
  WordEntry('Owl', 'उल्लू', 'ANIMALS', 'जानवर'),
  WordEntry('Parrot', 'तोता', 'ANIMALS', 'जानवर'),
  WordEntry('Pigeon', 'कबूतर', 'ANIMALS', 'जानवर'),
  WordEntry('Swan', 'सवअन', 'ANIMALS', 'जानवर'),
  WordEntry('Flamingo', 'फ़लअमइनगओ', 'ANIMALS', 'जानवर'),
  WordEntry('Penguin', 'पेंगुइन', 'ANIMALS', 'जानवर'),
  WordEntry('Crocodile', 'मगरमच्छ', 'ANIMALS', 'जानवर'),
  WordEntry('Alligator', 'अललइगअटओर', 'ANIMALS', 'जानवर'),
  WordEntry('Turtle', 'कछुआ', 'ANIMALS', 'जानवर'),
  WordEntry('Tortoise', 'टओरटओइसए', 'ANIMALS', 'जानवर'),
  WordEntry('Snake', 'साँप', 'ANIMALS', 'जानवर'),
  WordEntry('Lizard', 'छिपकली', 'ANIMALS', 'जानवर'),
  WordEntry('Frog', 'मेंढक', 'ANIMALS', 'जानवर'),
  WordEntry('Toad', 'टओअड', 'ANIMALS', 'जानवर'),
  WordEntry('Salamander', 'सअलअमअनडएर', 'ANIMALS', 'जानवर'),
  WordEntry('Pizza', 'पिज़्ज़ा', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Burger', 'बर्गर', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Sandwich', 'सअनडवइकह', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Pasta', 'पअसटअ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Lasagna', 'लअसअगनअ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Noodles', 'नओओडलएस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Dumplings', 'डउमपलइनगस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Tacos', 'टअकओस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Burrito', 'बउररइटओ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Sushi', 'सउसहइ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Ramen', 'रअमएन', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Curry', 'कउररय', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Biryani', 'बिरयानी', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Pancake', 'पअनकअकए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Waffle', 'वअफ़फ़लए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Omelette', 'ओमएलएटटए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Toast', 'टओअसट', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Cheese', 'कहएएसए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Butter', 'मक्खन', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Yogurt', 'दही', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Milk', 'दूध', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Coffee', 'कॉफ़ी', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Tea', 'चाय', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Juice', 'जउइकए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Lemonade', 'नींबू पानी', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Smoothie', 'समओओटहइए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Milkshake', 'मिल्कशेक', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Water', 'पानी', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Cola', 'कओलअ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Chocolate', 'चॉकलेट', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Cookie', 'कओओकइए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Brownie', 'बरओवनइए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Cake', 'कअकए', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Donut', 'डओनउट', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Ice cream', 'इकए करएअम', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Pudding', 'पउडडइनग', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Popcorn', 'पओपकओरन', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Chips', 'कहइपस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Fries', 'फ़रइएस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Nachos', 'नअकहओस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Salad', 'सअलअड', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Soup', 'सओउप', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Bread', 'रोटी', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Rice', 'चावल', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Quinoa', 'कउइनओअ', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Oats', 'ओअटस', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Apple', 'सेब', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Banana', 'केला', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Strawberry', 'सटरअवबएररय', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Mango', 'आम', 'FOOD & DRINK', 'खाना और पेय'),
  WordEntry('Sofa', 'सोफ़ा', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Armchair', 'अरमकहअइर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Stool', 'सटओओल', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Table', 'मेज़', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Ottoman', 'ओटटओमअन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Bookshelf', 'बओओकसहएलफ़', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Cabinet', 'कअबइनएट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Drawer', 'डरअवएर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Closet', 'कलओसएट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Dresser', 'डरएससएर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Bed', 'बिस्तर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Pillow', 'तकिया', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Blanket', 'कंबल', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Mattress', 'मअटटरएसस', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Alarm clock', 'अलअरम कलओकक', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Lamp', 'लअमप', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Light bulb', 'लइगहट बउलब', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Candle', 'कअनडलए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Mirror', 'आईना', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Window', 'खिड़की', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Curtain', 'कउरटअइन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Door', 'दरवाज़ा', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Key', 'चाबी', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Lock', 'ताला', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Doormat', 'डओओरमअट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Carpet', 'कअरपएट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Rug', 'रउग', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Wall clock', 'वअलल कलओकक', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Photo frame', 'पहओटओ फ़रअमए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Vase', 'वअसए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Plant pot', 'पलअनट पओट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Trash can', 'टरअसह कअन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Broom', 'झाड़ू', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Mop', 'मओप', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Vacuum', 'वअकउउम', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Iron', 'इरओन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Washer', 'वअसहएर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Dryer', 'डरयएर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Refrigerator', 'रएफ़रइगएरअटओर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Freezer', 'फ़रएएज़एर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Oven', 'ओवएन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Microwave', 'मइकरओवअवए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Toaster', 'टओअसटएर', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Kettle', 'कएटटलए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Pan', 'पअन', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Pot', 'पओट', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Knife', 'चाकू', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Fork', 'फ़ओरक', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Spoon', 'चम्मच', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Plate', 'पलअटए', 'AROUND THE HOUSE', 'घर की चीज़ें'),
  WordEntry('Mountain', 'पहाड़', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Hill', 'हइलल', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Valley', 'घाटी', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Canyon', 'कअनयओन', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Cliff', 'कलइफ़फ़', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Cave', 'कअवए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Island', 'द्वीप', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Beach', 'समुद्र तट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Ocean', 'महासागर', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Sea', 'समुद्र', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Lake', 'झील', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Pond', 'पओनड', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('River', 'नदी', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Waterfall', 'झरना', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Stream', 'सटरएअम', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Glacier', 'गलअकइएर', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Desert', 'रेगिस्तान', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Dune', 'डउनए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Forest', 'जंगल', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Jungle', 'जउनगलए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Woodland', 'वओओडलअनड', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Meadow', 'मएअडओव', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Grassland', 'गरअससलअनड', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Swamp', 'सवअमप', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Marsh', 'मअरसह', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Volcano', 'वओलकअनओ', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Earthquake', 'एअरटहकउअकए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Tornado', 'टओरनअडओ', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Hurricane', 'हउररइकअनए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Typhoon', 'टयपहओओन', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Thunder', 'टहउनडएर', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Lightning', 'लइगहटनइनग', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Rain', 'बारिश', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Drizzle', 'डरइज़ज़लए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Snow', 'बर्फ़', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Hail', 'हअइल', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Frost', 'फ़रओसट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Fog', 'फ़ओग', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Mist', 'मइसट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Cloud', 'बादल', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Rainbow', 'इंद्रधनुष', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Sunshine', 'सउनसहइनए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Sunrise', 'सउनरइसए', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Sunset', 'सउनसएट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Moon', 'चाँद', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Star', 'तारा', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Comet', 'कओमएट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Meteor', 'मएटएओर', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Planet', 'पलअनएट', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Constellation', 'कओनसटएललअटइओन', 'NATURE & WEATHER', 'प्रकृति और मौसम'),
  WordEntry('Heart', 'दिल', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Brain', 'दिमाग', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Lung', 'फेफड़ा', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Liver', 'लइवएर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Kidney', 'कइडनएय', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Stomach', 'पेट', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Intestine', 'इनटएसटइनए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Spine', 'सपइनए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Rib', 'रइब', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Skull', 'सकउलल', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Bone', 'हड्डी', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Muscle', 'मांसपेशी', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Tendon', 'टएनडओन', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Joint', 'जओइनट', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Shoulder', 'सहओउलडएर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Elbow', 'एलबओव', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Knee', 'कनएए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Ankle', 'अनकलए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Wrist', 'वरइसट', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Finger', 'फ़इनगएर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Thumb', 'टहउमब', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Toe', 'टओए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Eye', 'आँख', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Ear', 'कान', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Nose', 'नाक', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Tongue', 'जीभ', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Tooth', 'दाँत', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Gum', 'गउम', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Hair', 'बाल', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Skin', 'त्वचा', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Blood', 'खून', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Vein', 'वएइन', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Artery', 'अरटएरय', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Nerve', 'नएरवए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Cell', 'कएलल', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Vitamin', 'वइटअमइन', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Medicine', 'मएडइकइनए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Thermometer', 'टहएरमओमएटएर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Syringe', 'सयरइनगए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Bandage', 'बअनडअगए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Plaster', 'पलअसटएर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Crutch', 'करउटकह', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Wheelchair', 'वहएएलकहअइर', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Ambulance', 'अमबउलअनकए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Physician', 'पहयसइकइअन', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Paramedic', 'पअरअमएडइक', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Surgeon', 'सउरगएओन', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Dentist', 'डएनटइसट', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Therapy', 'टहएरअपय', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Exercise', 'एक्सएरकइसए', 'THE BODY & HEALTH', 'शरीर और स्वास्थ्य'),
  WordEntry('Mother', 'माँ', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Father', 'पिता', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Parent', 'पअरएनट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Child', 'बच्चा', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Baby', 'शिशु', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Toddler', 'टओडडलएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Teenager', 'टएएनअगएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Adult', 'अडउलट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Grandmother', 'गरअनडमओटहएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Grandfather', 'गरअनडफ़अटहएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Grandparent', 'गरअनडपअरएनट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Grandchild', 'गरअनडकहइलड', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Sister', 'बहन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Brother', 'भाई', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Sibling', 'सइबलइनग', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Cousin', 'कओउसइन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Aunt', 'अउनट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Uncle', 'उनकलए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Niece', 'नइएकए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Nephew', 'नएपहएव', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Twin', 'टवइन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Spouse', 'सपओउसए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Husband', 'हउसबअनड', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Wife', 'वइफ़ए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Partner', 'पअरटनएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Friend', 'दोस्त', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Best friend', 'बएसट फ़रइएनड', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Roommate', 'रओओममअटए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Neighbor', 'नएइगहबओर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Stranger', 'सटरअनगएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Guest', 'गउएसट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Host', 'हओसट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Wedding', 'शादी', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Marriage', 'मअररइअगए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Divorce', 'डइवओरकए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Family', 'परिवार', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Relative', 'रएलअटइवए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Ancestor', 'अनकएसटओर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Descendant', 'डएसकएनडअनट', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Orphan', 'ओरपहअन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Adoption', 'अडओपटइओन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Guardian', 'गउअरडइअन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Pet owner', 'पएट ओवनएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Classmate', 'कलअससमअटए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Colleague', 'कओललएअगउए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Clan', 'कलअन', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Community', 'कओममउनइटय', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Crowd', 'करओवड', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Audience', 'अउडइएनकए', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Leader', 'लएअडएर', 'PEOPLE & FAMILY', 'लोग और परिवार'),
  WordEntry('Happiness', 'खुशी', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Sadness', 'दुःख', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Anger', 'गुस्सा', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Fear', 'डर', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Surprise', 'सउरपरइसए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Disgust', 'डइसगउसट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Excitement', 'एक्सकइटएमएनट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Boredom', 'बओरएडओम', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Anxiety', 'अनक्सइएटय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Stress', 'सटरएसस', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Relief', 'रएलइएफ़', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Optimism', 'ओपटइमइसम', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Jealousy', 'जएअलओउसय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Envy', 'एनवय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Pride', 'परइडए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Guilt', 'गउइलट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Shame', 'सहअमए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Regret', 'रएगरएट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Confusion', 'कओनफ़उसइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Curiosity', 'कउरइओसइटय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Wonder', 'वओनडएर', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Love', 'प्यार', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Affection', 'अफ़फ़एकटइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Hatred', 'हअटरएड', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Suspicion', 'सउसपइकइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Doubt', 'डओउबट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Confidence', 'कओनफ़इडएनकए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Embarrassment', 'एमबअररअससमएनट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Loneliness', 'लओनएलइनएसस', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Empathy', 'एमपअटहय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Sympathy', 'सयमपअटहय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Gratitude', 'गरअटइटउडए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Patience', 'पअटइएनकए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Frustration', 'फ़रउसटरअटइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Disappointment', 'डइसअपपओइनटमएनट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Contentment', 'कओनटएनटमएनट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Calm', 'कअलम', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Panic', 'पअनइक', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Joy', 'जओय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Grief', 'गरइएफ़', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Daydream', 'डअयडरएअम', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Memory', 'मएमओरय', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Dream', 'सपना', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Thought', 'टहओउगहट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Idea', 'विचार', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Opinion', 'ओपइनइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Reflection', 'रएफ़लएकटइओन', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Secret', 'सएकरएट', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Promise', 'परओमइसए', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Wish', 'वइसह', 'FEELINGS & THOUGHTS', 'भावनाएँ और विचार'),
  WordEntry('Tutor', 'टउटओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Professor', 'परओफ़एससओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Intern', 'इनटएरन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Doctor', 'डॉक्टर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Nurse', 'नर्स', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Police officer', 'पओलइकए ओफ़फ़इकएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Firefighter', 'फ़इरएफ़इगहटएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Chef', 'रसोइया', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Baker', 'बअकएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Farmer', 'किसान', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Mechanic', 'मएकहअनइक', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Engineer', 'इंजीनियर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Architect', 'अरकहइटएकट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Artist', 'कलाकार', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Actor', 'अकटओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Freelancer', 'फ़रएएलअनकएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Writer', 'लेखक', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Journalist', 'जओउरनअलइसट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Photographer', 'पहओटओगरअपहएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Lawyer', 'वकील', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Judge', 'जउडगए', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Accountant', 'लेखाकार', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Auditor', 'अउडइटओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Banker', 'बअनकएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Cashier', 'कअसहइएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Manager', 'मअनअगएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('CEO', 'कएओ', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Entrepreneur', 'एनटरएपरएनएउर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Investor', 'इनवएसटओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Politician', 'पओलइटइकइअन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Mayor', 'मअयओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('President', 'परएसइडएनट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Minister', 'मइनइसटएर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Governor', 'गओवएरनओर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Diplomat', 'डइपलओमअट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Campaign', 'कअमपअइगन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Election', 'एलएकटइओन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Vote', 'वओटए', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Debate', 'डएबअटए', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Tax', 'कर', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Salary', 'वेतन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Bonus', 'बओनउस', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Invoice', 'इनवओइकए', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Budget', 'बउडगएट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Loan', 'लओअन', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Debt', 'डएबट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Profit', 'लाभ', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Loss', 'हानि', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Stock', 'सटओकक', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Market', 'मअरकएट', 'JOBS, MONEY & POLITICS', 'नौकरियाँ, पैसा और राजनीति'),
  WordEntry('Airport', 'हवाई अड्डा', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Airplane', 'हवाई जहाज़', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Train', 'ट्रेन', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Station', 'सटअटइओन', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Bus', 'बस', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Bus stop', 'बउस सटओप', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Taxi', 'टअक्सइ', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Car', 'कार', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Bicycle', 'साइकिल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Motorcycle', 'मोटरसाइकिल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Scooter', 'सकओओटएर', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Truck', 'टरउकक', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Van', 'वअन', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Boat', 'नाव', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Ship', 'सहइप', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Ferry', 'फ़एररय', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Submarine', 'पनडुब्बी', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Helicopter', 'हएलइकओपटएर', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Passport', 'पासपोर्ट', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Ticket', 'टइककएट', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Luggage', 'लउगगअगए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Suitcase', 'सउइटकअसए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Carry-on', 'कअररयओन', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Atlas', 'अटलअस', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Compass', 'कओमपअसस', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Hotel', 'होटल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Hostel', 'हओसटएल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Resort', 'रएसओरट', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Motel', 'मओटएल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Restaurant', 'रेस्तराँ', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Cafe', 'कअफ़ए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Park', 'पार्क', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Museum', 'मउसएउम', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Bookstore', 'बओओकसटओरए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('University', 'उनइवएरसइटय', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Hospital', 'अस्पताल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Plaza', 'पलअज़अ', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Theater', 'टहएअटएर', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Cinema', 'सिनेमा', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Bridge', 'बरइडगए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Tunnel', 'टउननएल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Highway', 'हइगहवअय', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Street', 'सटरएएट', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Alley', 'अललएय', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Square', 'सकउअरए', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('City', 'शहर', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Village', 'गाँव', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Capital', 'कअपइटअल', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Border', 'बओरडएर', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Monument', 'मओनउमएनट', 'TRAVEL & PLACES', 'यात्रा और स्थान'),
  WordEntry('Computer', 'कंप्यूटर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Laptop', 'लैपटॉप', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Tablet', 'टअबलएट', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Smartphone', 'स्मार्टफोन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Keyboard', 'कीबोर्ड', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Trackpad', 'टरअककपअड', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Monitor', 'मओनइटओर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Printer', 'परइनटएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Scanner', 'सकअननएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Camera', 'कैमरा', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Webcam', 'वएबकअम', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Speaker', 'सपएअकएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Headphones', 'हेडफ़ोन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Charger', 'कहअरगएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Battery', 'बअटटएरय', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Cable', 'कअबलए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Router', 'रओउटएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Modem', 'मओडएम', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Internet', 'इंटरनेट', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Website', 'वएबसइटए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('App', 'अपप', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Software', 'सओफ़टवअरए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Hardware', 'हअरडवअरए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Password', 'पअससवओरड', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Robot', 'रोबोट', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Drone', 'डरओनए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Satellite', 'सअटएललइटए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Rocket', 'रॉकेट', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Spaceship', 'सपअकएसहइप', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Telescope', 'टएलएसकओपए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Microscope', 'मइकरओसकओपए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Calculator', 'कअलकउलअटओर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Smartwatch', 'समअरटवअटकह', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Radio', 'रअडइओ', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Television', 'टएलएवइसइओन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Remote', 'रएमओटए', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Projector', 'परओजएकटओर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('USB', 'उसब', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Chip', 'कहइप', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Processor', 'परओकएससओर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Screen', 'सकरएएन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Touchscreen', 'टओउकहसकरएएन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Plastic', 'पलअसटइक', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Glass', 'गलअसस', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Metal', 'मएटअल', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Steel', 'सटएएल', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Wood', 'वओओड', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Rubber', 'रउबबएर', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Ceramic', 'कएरअमइक', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Carbon', 'कअरबओन', 'TECHNOLOGY & MATERIALS', 'तकनीक और सामग्री'),
  WordEntry('Song', 'गाना', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Melody', 'मएलओडय', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Rhythm', 'रहयटहम', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Beat', 'बएअट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Tempo', 'टएमपओ', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Concert', 'कॉन्सर्ट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Orchestra', 'ओरकहएसटरअ', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Band', 'बअनड', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Choir', 'कहओइर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Guitar', 'गिटार', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Piano', 'पियानो', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Drum', 'ढोल', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Violin', 'वायलिन', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Flute', 'बाँसुरी', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Saxophone', 'सअक्सओपहओनए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Trumpet', 'टरउमपएट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Cello', 'कएललओ', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Ukulele', 'उकउलएलए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Tambourine', 'टअमबओउरइनए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Album', 'अलबउम', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Playlist', 'पलअयलइसट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Composer', 'कओमपओसएर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Singer', 'सइनगएर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Dancer', 'डअनकएर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Mural', 'मउरअल', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Drawing', 'डरअवइनग', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Sketch', 'सकएटकह', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Portrait', 'पओरटरअइट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Landscape', 'लअनडसकअपए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Sculpture', 'सकउलपटउरए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Gallery', 'गअललएरय', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Canvas', 'कअनवअस', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Brush', 'बरउसह', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Palette', 'पअलएटटए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Photograph', 'पहओटओगरअपह', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Poem', 'कविता', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Novel', 'नओवएल', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Story', 'कहानी', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Fable', 'फ़अबलए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Fairy tale', 'फ़अइरय टअलए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Comic', 'कओमइक', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Cartoon', 'कअरटओओन', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Movie', 'फ़िल्म', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Screenplay', 'सकरएएनपलअय', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Character', 'कहअरअकटएर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Plot', 'पलओट', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Chapter', 'कहअपटएर', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Page', 'पअगए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Bookmark', 'बओओकमअरक', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Stage', 'सटअगए', 'MUSIC, ART & STORIES', 'संगीत, कला और कहानियाँ'),
  WordEntry('Football', 'फ़ुटबॉल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Soccer', 'सओककएर', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Cricket', 'क्रिकेट', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Basketball', 'बास्केटबॉल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Tennis', 'टेनिस', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Badminton', 'बैडमिंटन', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Volleyball', 'वओललएयबअलल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Baseball', 'बअसएबअलल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Rugby', 'रउगबय', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Hockey', 'हओककएय', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Golf', 'गओलफ़', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Boxing', 'बओक्सइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Wrestling', 'वरएसटलइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Swimming', 'तैराकी', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Diving', 'डइवइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Running', 'दौड़', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Jogging', 'जओगगइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Cycling', 'कयकलइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Skating', 'सकअटइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Skiing', 'सकइइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Surfing', 'सउरफ़इनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Climbing', 'कलइमबइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Archery', 'अरकहएरय', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Fencing', 'फ़एनकइनग', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Karate', 'कअरअटए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Judo', 'जउडओ', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Chess', 'शतरंज', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Checkers', 'कहएककएरस', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Cards', 'कअरडस', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Dice', 'डइकए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Dominoes', 'डओमइनओएस', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Puzzle', 'पउज़ज़लए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Board game', 'बओअरड गअमए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Video game', 'वइडएओ गअमए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Esports', 'एसपओरटस', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Squad', 'सकउअड', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Coach', 'कओअकह', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Referee', 'रएफ़एरएए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Medal', 'मएडअल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Trophy', 'टरओपहय', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Rink', 'रइनक', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Score', 'सकओरए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Goal', 'गओअल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Penalty', 'पएनअलटय', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Serve', 'सएरवए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Match', 'मअटकह', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('League', 'लएअगउए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Final', 'फ़इनअल', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Practice', 'परअकटइकए', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Champion', 'कहअमपइओन', 'SPORTS & GAMES', 'खेल और गेम'),
  WordEntry('Shirt', 'कमीज़', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('T-shirt', 'टसहइरट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Blouse', 'बलओउसए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Sweater', 'सवएअटएर', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Hoodie', 'हओओडइए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Jacket', 'जअककएट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Coat', 'कओअट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Raincoat', 'रअइनकओअट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Jeans', 'जीन्स', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Trousers', 'टरओउसएरस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Shorts', 'सहओरटस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Skirt', 'सकइरट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Dress', 'डरएसस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Uniform', 'उनइफ़ओरम', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Suit', 'सउइट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Tie', 'टइए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Belt', 'बएलट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Socks', 'सओककस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Shoes', 'जूते', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Sneakers', 'सनएअकएरस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Boots', 'बओओटस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Sandals', 'सअनडअलस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Slippers', 'सलइपपएरस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Hat', 'टोपी', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Cap', 'कअप', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Helmet', 'हएलमएट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Scarf', 'सकअरफ़', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Gloves', 'गलओवएस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Mittens', 'मइटटएनस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Watch', 'वअटकह', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Glasses', 'गलअससएस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Sunglasses', 'सउनगलअससएस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Ring', 'अंगूठी', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Necklace', 'नएककलअकए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Bracelet', 'बरअकएलएट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Earrings', 'एअररइनगस', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Wallet', 'वअललएट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Purse', 'पउरसए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Handbag', 'हअनडबअग', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Duffel bag', 'डउफ़फ़एल बअग', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Pocket', 'पओककएट', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Button', 'बउटटओन', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Zip', 'ज़इप', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Needle', 'नएएडलए', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Thread', 'टहरएअड', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Fabric', 'फ़अबरइक', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Cotton', 'कओटटओन', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Wool', 'वओओल', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Silk', 'सइलक', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Denim', 'डएनइम', 'CLOTHES & FABRIC', 'कपड़े और वस्त्र'),
  WordEntry('Dragon', 'ड्रैगन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Unicorn', 'उनइकओरन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Wizard', 'जादूगर', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Witch', 'चुड़ैल', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Spell', 'सपएलल', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Magic', 'मअगइक', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Potion', 'पओटइओन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Crystal', 'करयसटअल', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Amulet', 'अमउलएट', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Cursed', 'कउरसएड', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Monster', 'मओनसटएर', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Ghost', 'भूत', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Vampire', 'पिशाच', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Werewolf', 'वएरएवओलफ़', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Zombie', 'ज़ओमबइए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Elf', 'एलफ़', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Dwarf', 'डवअरफ़', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Goblin', 'गओबलइन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Fairy', 'फ़अइरय', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Mermaid', 'मएरमअइड', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Centaur', 'कएनटअउर', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('King', 'राजा', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Queen', 'रानी', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Princess', 'परइनकएसस', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Prince', 'परइनकए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Knight', 'कनइगहट', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Castle', 'किला', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Throne', 'टहरओनए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Crown', 'करओवन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Sword', 'तलवार', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Shield', 'सहइएलड', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Arrow', 'अररओव', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Bow', 'बओव', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Treasure', 'टरएअसउरए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Relic', 'रएलइक', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Gem', 'गएम', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Secret passage', 'सएकरएट पअससअगए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Quest', 'कउएसट', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Portal', 'पओरटअल', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Legend', 'लएगएनड', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Myth', 'मयटह', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Hero', 'हएरओ', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Villain', 'वइललअइन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Detective', 'डएटएकटइवए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Thief', 'टहइएफ़', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Robber', 'रओबबएर', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Spy', 'सपय', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Clue', 'कलउए', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Alibi', 'अलइबइ', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Prison', 'परइसओन', 'FANTASY & CRIME', 'काल्पनिक दुनिया और अपराध'),
  WordEntry('Red', 'लाल', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Blue', 'नीला', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Green', 'हरा', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Yellow', 'पीला', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Orange', 'संतरा', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Purple', 'पउरपलए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Pink', 'पइनक', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Brown', 'बरओवन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Black', 'काला', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('White', 'सफ़ेद', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Gray', 'गरअय', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Bronze', 'बरओनज़ए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Silver', 'सइलवएर', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Turquoise', 'टउरकउओइसए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Indigo', 'इनडइगओ', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Violet', 'वइओलएट', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Beige', 'बएइगए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Maroon', 'मअरओओन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Scarlet', 'सकअरलएट', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Teal', 'टएअल', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Zero', 'ज़एरओ', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('One', 'एक', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Two', 'दो', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Three', 'तीन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Four', 'चार', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Five', 'पाँच', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Six', 'सइक्स', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Seven', 'सएवएन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Eight', 'एइगहट', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Nine', 'नइनए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Ten', 'टएन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Dozen', 'डओज़एन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Century', 'कएनटउरय', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Decade', 'डएकअडए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Minute', 'मइनउटए', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Hour', 'हओउर', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Second', 'सएकओनड', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Day', 'दिन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Week', 'सप्ताह', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Month', 'महीना', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Year', 'साल', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Calendar', 'कअलएनडअर', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Stopwatch', 'सटओपवअटकह', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Midnight', 'मइडनइगहट', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Noon', 'नओओन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Morning', 'मओरनइनग', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Afternoon', 'अफ़टएरनओओन', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Evening', 'एवएनइनग', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Night', 'नइगहट', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('Tomorrow', 'टओमओररओव', 'COLOURS, NUMBERS & TIME', 'रंग, संख्याएँ और समय'),
  WordEntry('School', 'स्कूल', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Classroom', 'कलअससरओओम', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Instructor', 'इनसटरउकटओर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Pupil', 'पउपइल', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Lesson', 'लएससओन', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Homework', 'हओमएवओरक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Exam', 'एक्सअम', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Quiz', 'कउइज़', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Test', 'टएसट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Grade', 'गरअडए', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Report card', 'रएपओरट कअरड', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Textbook', 'टएक्सटबओओक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Notebook', 'नओटएबओओक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Workbook', 'वओरकबओओक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Paper', 'पअपएर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Pencil', 'पेंसिल', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Pen', 'कलम', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Eraser', 'एरअसएर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Ruler', 'रउलएर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Scissors', 'सकइससओरस', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Glue', 'गलउए', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Marker', 'मअरकएर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Crayon', 'करअयओन', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Chalk', 'कहअलक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Whiteboard', 'वहइटएबओअरड', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Blackboard', 'बलअककबओअरड', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Filing cabinet', 'फ़इलइनग कअबइनएट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Lunchbox', 'लउनकहबओक्स', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Study hall', 'सटउडय हअलल', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Dictionary', 'डइकटइओनअरय', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Alphabet', 'अलपहअबएट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Grammar', 'गरअममअर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Spelling', 'सपएललइनग', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Reading', 'रएअडइनग', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Writing', 'वरइटइनग', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Math', 'गणित', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Science', 'विज्ञान', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('History', 'इतिहास', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Geography', 'गएओगरअपहय', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Biology', 'बइओलओगय', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Chemistry', 'कहएमइसटरय', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Physics', 'पहयसइकस', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Art', 'अरट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Music', 'मउसइक', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Project', 'परओजएकट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Research', 'रएसएअरकह', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Experiment', 'एक्सपएरइमएनट', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Question', 'कउएसटइओन', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Answer', 'अनसवएर', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Knowledge', 'कनओवलएडगए', 'SCHOOL & LEARNING', 'स्कूल और शिक्षा'),
  WordEntry('Freedom', 'स्वतंत्रता', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Justice', 'न्याय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Equality', 'एकउअलइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Truth', 'सत्य', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Loyalty', 'लओयअलटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Honesty', 'हओनएसटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Credibility', 'करएडइबइलइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Respect', 'सम्मान', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Responsibility', 'रएसपओनसइबइलइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Identity', 'इडएनटइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Privacy', 'परइवअकय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Security', 'सएकउरइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Safety', 'सअफ़एटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Danger', 'डअनगएर', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Risk', 'रइसक', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Chance', 'कहअनकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Luck', 'लउकक', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Fate', 'फ़अटए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Destiny', 'डएसटइनय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Choice', 'कहओइकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Judgment', 'जउडगमएनट', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Change', 'कहअनगए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Time', 'समय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Space', 'सपअकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Energy', 'ऊर्जा', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Power', 'शक्ति', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Control', 'कओनटरओल', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Balance', 'बअलअनकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Stability', 'सटअबइलइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Chaos', 'कहअओस', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Order', 'ओरडएर', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Coherence', 'कओहएरएनकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Conflict', 'कओनफ़लइकट', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('War', 'वअर', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Ambition', 'अमबइटइओन', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Faith', 'फ़अइटह', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Beauty', 'बएअउटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Success', 'सफलता', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Failure', 'असफलता', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Progress', 'परओगरएसस', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Tradition', 'टरअडइटइओन', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Culture', 'संस्कृति', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Language', 'भाषा', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Communication', 'कओममउनइकअटइओन', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Silence', 'सइलएनकए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Meaning', 'मएअनइनग', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Value', 'वअलउए', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Reason', 'रएअसओन', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Logic', 'तर्क', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
  WordEntry('Creativity', 'करएअटइवइटय', 'IDEAS & CONCEPTS', 'विचार और अवधारणाएँ'),
];

class RoundRecord {
  RoundRecord({
    required this.date,
    required this.word,
    required this.imposter,
    required this.players,
    required this.voteTotals,
    required this.points,
    required this.scores,
    required this.caught,
    this.votes = const {},
  });

  final String date;
  final WordEntry word;
  final String imposter;
  final List<String> players;
  final List<int> voteTotals;
  final List<int> points;
  final List<int> scores;
  final bool caught;
  final Map<int, int> votes;
  String get category => word.category;

  Map<String, dynamic> toJson() => {
        'date': date,
        'word': word.toJson(),
        'imposter': imposter,
        'players': players,
        'voteTotals': voteTotals,
        'points': points,
        'scores': scores,
        'caught': caught,
        'votes': votes.map((key, value) => MapEntry(key.toString(), value)),
      };

  factory RoundRecord.fromJson(Map<String, dynamic> j) => RoundRecord(
        date: j['date'] as String? ?? '',
        word: WordEntry.fromJson(Map<String, dynamic>.from(j['word'] as Map)),
        imposter: j['imposter'] as String? ?? '',
        players: List<String>.from(j['players'] as List? ?? const []),
        voteTotals: List<int>.from(j['voteTotals'] as List? ?? const []),
        points: List<int>.from(j['points'] as List? ?? const []),
        scores: List<int>.from(j['scores'] as List? ?? const []),
        caught: j['caught'] as bool? ?? false,
        votes: (j['votes'] as Map? ?? const {}).map((key, value) => MapEntry(int.parse(key.toString()), (value as num).toInt())),
      );
}


class MatchRecord {
  MatchRecord({
    required this.startedAt,
    required this.players,
    required this.rounds,
    required this.finalScores,
  });
  final String startedAt;
  final List<String> players;
  final List<RoundRecord> rounds;
  final Map<String, int> finalScores;
  Map<String, dynamic> toJson() => {
    'startedAt': startedAt,
    'players': players,
    'rounds': rounds.map((round) => round.toJson()).toList(),
    'finalScores': finalScores,
  };
  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
    startedAt: json['startedAt'] as String? ?? '',
    players: List<String>.from(json['players'] as List? ?? const []),
    rounds: (json['rounds'] as List? ?? const []).whereType<Map>()
      .map((round) => RoundRecord.fromJson(Map<String, dynamic>.from(round))).toList(),
    finalScores: Map<String, int>.from((json['finalScores'] as Map? ?? const {})
      .map((key, value) => MapEntry(key.toString(), (value as num).toInt()))),
  );
}

class ImposterApp extends StatefulWidget {
  const ImposterApp({super.key});
  @override
  State<ImposterApp> createState() => _ImposterAppState();
}

class _ImposterAppState extends State<ImposterApp> {
  int _paletteIndex = 0;
  void _selectPalette(int index) {
    if (index >= 0 && index < gamePalettes.length && index != _paletteIndex) {
      setState(() => _paletteIndex = index);
    }
  }
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<GamePalette>(
    tween: GamePaletteTween(end: gamePalettes[_paletteIndex]),
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
    builder: (context, palette, _) {
      final theme = ThemeData(
        brightness: _paletteIndex == 5 ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: palette.background,
        colorScheme: _paletteIndex == 5
            ? ColorScheme.light(primary: palette.primary, secondary: palette.accent, surface: palette.card, onSurface: const Color(0xFF303544))
            : ColorScheme.dark(primary: palette.primary, secondary: palette.accent, surface: palette.card),
        fontFamily: 'Roboto',
        useMaterial3: true,
      );
      return PaletteScope(
        palette: palette,
        selectedIndex: _paletteIndex,
        onSelect: _selectPalette,
        child: MaterialApp(
          title: 'IMPOSTER',
          debugShowCheckedModeBanner: false,
          theme: theme,
          themeAnimationDuration: Duration.zero,
          home: const LaunchSplash(),
        ),
      );
    },
  );
}

class PaletteScope extends InheritedWidget {
  const PaletteScope({super.key, required this.palette, required this.selectedIndex, required this.onSelect, required super.child});
  final GamePalette palette;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  static PaletteScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PaletteScope>();
    assert(scope != null, 'PaletteScope not found');
    return scope!;
  }
  @override
  bool updateShouldNotify(PaletteScope oldWidget) => palette != oldWidget.palette || selectedIndex != oldWidget.selectedIndex;
}

class LaunchSplash extends StatefulWidget {
  const LaunchSplash({super.key});

  @override
  State<LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<LaunchSplash> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const GameHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: PaletteScope.of(context).palette.background,
        body: SizedBox.expand(
          child: Image.asset(
            'assets/icons/presplash.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('IMPOSTER',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      );
}

enum Phase { menu, reveal, passToNext, discuss, voting, votePass, summary, results, history, historyDetail }

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  final Random _random = Random();
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _playerFocusNodes = [];
  final List<String> _players = ['', '', ''];
  final List<int> _playerIds = [0, 1, 2];
  int _nextPlayerId = 3;
  final Map<int, int> _votes = {};
  final Map<String, int> _scores = {};
  final List<MatchRecord> _history = [];
  final List<RoundRecord> _currentRounds = [];
  MatchRecord? _selectedMatch;
  String? _matchStartedAt;
  int _roundNumber = 0;
  Phase _phase = Phase.menu;
  int _revealIndex = 0;
  int _voterIndex = 0;
  int? _selectedVote;
  int _imposterIndex = 0;
  WordEntry? _word;
  String? _lastWord;
  RoundRecord? _selectedHistory;
  bool _revealed = false;
  bool _busy = false;
  bool _roundAwarded = false;
  DateTime? _lastBackAttempt;
  int _revealAutoHideToken = 0;
  late final AnimationController _curtainController;
  late final Animation<Offset> _curtainSlide;

  @override
  void initState() {
    super.initState();
    _syncControllers();
    _curtainController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 460),
    );
    _curtainSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -1.05),
    ).animate(CurvedAnimation(parent: _curtainController, curve: Curves.easeInOutCubic));
    _loadHistory();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final focusNode in _playerFocusNodes) {
      focusNode.dispose();
    }
    _curtainController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    while (_controllers.length < _players.length) {
      _controllers.add(TextEditingController(text: _players[_controllers.length]));
    }
    while (_playerFocusNodes.length < _players.length) {
      _playerFocusNodes.add(FocusNode());
    }
    while (_controllers.length > _players.length) {
      _controllers.removeLast().dispose();
    }
    while (_playerFocusNodes.length > _players.length) {
      _playerFocusNodes.removeLast().dispose();
    }
    for (var i = 0; i < _players.length; i++) {
      if (_controllers[i].text != _players[i]) {
        _controllers[i].value = TextEditingValue(
          text: _players[i],
          selection: TextSelection.collapsed(offset: _players[i].length),
        );
      }
    }
  }

  void _updatePlayerName(int index, String value) {
    if (index >= 0 && index < _players.length) {
      _players[index] = value;
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final matchRaw = prefs.getString('imposter_matches_v2');
    final legacyRaw = prefs.getString('imposter_history_v1');
    final unfinishedRaw = prefs.getString('imposter_unfinished_v2');
    if (!mounted) return;
    setState(() {
      _history.clear();
      if (matchRaw != null) {
        try {
          final decoded = jsonDecode(matchRaw);
          if (decoded is List) {
            for (final item in decoded.whereType<Map>()) {
              try {
                final match = MatchRecord.fromJson(Map<String, dynamic>.from(item));
                if (match.rounds.isNotEmpty) _history.add(match);
              } catch (_) {}
            }
          }
        } catch (_) {}
      } else if (legacyRaw != null) {
        // One legacy round becomes one completed match; no old round data is lost.
        try {
          final decoded = jsonDecode(legacyRaw);
          if (decoded is List) {
            for (final item in decoded.whereType<Map>()) {
              try {
                final round = RoundRecord.fromJson(Map<String, dynamic>.from(item));
                if (_isValidRecord(round)) {
                  _history.add(MatchRecord(
                    startedAt: round.date,
                    players: round.players,
                    rounds: [round],
                    finalScores: {for (var i = 0; i < round.players.length; i++) round.players[i]: round.scores[i]},
                  ));
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
      if (unfinishedRaw != null) {
        try {
          final data = Map<String, dynamic>.from(jsonDecode(unfinishedRaw) as Map);
          _players
            ..clear()
            ..addAll(List<String>.from(data['players'] as List? ?? const []));
          if (_players.length < 3 || _players.length > 20) {
            _players
              ..clear()
              ..addAll(['', '', '']);
          }
          _playerIds
            ..clear()
            ..addAll(List<int>.generate(_players.length, (index) => index));
          _nextPlayerId = _players.length;
          _scores
            ..clear()
            ..addAll(Map<String, int>.from((data['scores'] as Map? ?? const {})
              .map((key, value) => MapEntry(key.toString(), (value as num).toInt()))));
          _currentRounds
            ..clear()
            ..addAll((data['rounds'] as List? ?? const []).whereType<Map>()
              .map((item) => RoundRecord.fromJson(Map<String, dynamic>.from(item))));
          _matchStartedAt = data['startedAt'] as String?;
          _roundNumber = _currentRounds.length;
          _syncControllers();
        } catch (_) {
          _matchStartedAt = null;
          _currentRounds.clear();
        }
      }
    });
    // If the history write succeeded but the app was killed before the
    // recovery key was removed, treat that recovery record as already complete.
    if (_matchStartedAt != null &&
        _history.any((match) => match.startedAt == _matchStartedAt)) {
      await prefs.remove('imposter_unfinished_v2');
      _matchStartedAt = null;
      _currentRounds.clear();
    } else if (unfinishedRaw != null && _matchStartedAt != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResumeDialog();
      });
    }
    if (matchRaw == null && legacyRaw != null) await _persistHistory();
  }

  void _showResumeDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletteScope.of(context).palette.card,
        title: const Text('UNFINISHED MATCH'),
        content: const Text('An unfinished match was found. Would you like to continue it?'),
        actions: [
          TextButton(
            key: const ValueKey('resume-match'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('RESUME'),
          ),
          TextButton(
            key: const ValueKey('discard-match'),
            onPressed: () async {
              await _discardUnfinished();
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text('BACK (MAIN MENU)'),
          ),
        ],
      ),
    );
  }

  Future<void> _discardUnfinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('imposter_unfinished_v2');
    if (!mounted) return;
    setState(() {
      _matchStartedAt = null;
      _roundNumber = 0;
      _currentRounds.clear();
      _scores.clear();
      _players
        ..clear()
        ..addAll(['', '', '']);
      _playerIds
        ..clear()
        ..addAll([0, 1, 2]);
      _nextPlayerId = 3;
      _syncControllers();
      _phase = Phase.menu;
    });
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imposter_matches_v2', jsonEncode(_history.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistUnfinished() async {
    if (_matchStartedAt == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imposter_unfinished_v2', jsonEncode({
      'startedAt': _matchStartedAt,
      'players': _players,
      'scores': _scores,
      'roundNumber': _roundNumber,
      'rounds': _currentRounds.map((round) => round.toJson()).toList(),
    }));
  }

  Future<void> _completeMatch() async {
    if (_matchStartedAt == null || _currentRounds.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('imposter_unfinished_v2');
      if (mounted) setState(() => _matchStartedAt = null);
      return;
    }
    final match = MatchRecord(
      startedAt: _matchStartedAt!,
      players: List<String>.from(_players),
      rounds: List<RoundRecord>.from(_currentRounds),
      finalScores: Map<String, int>.from(_scores),
    );
    setState(() {
      _history.insert(0, match);
      _matchStartedAt = null;
      _currentRounds.clear();
      _roundNumber = 0;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imposter_matches_v2', jsonEncode(_history.map((e) => e.toJson()).toList()));
    await prefs.remove('imposter_unfinished_v2');
  }

  bool _isValidRecord(RoundRecord record) {
    final count = record.players.length;
    return record.date.isNotEmpty &&
        record.word.word.isNotEmpty &&
        count > 0 &&
        record.voteTotals.length == count &&
        record.points.length == count &&
        record.scores.length == count;
  }


  void _go(Phase p) {
    _revealAutoHideToken++;
    _curtainController.stop();
    setState(() {
      _phase = p;
      if (p != Phase.reveal) _revealed = false;
    });
  }

  void _handleBack() {
    final now = DateTime.now();
    final secondPress = _lastBackAttempt != null &&
        now.difference(_lastBackAttempt!) <= Duration(seconds: 2);
    if (secondPress) {
      _lastBackAttempt = null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (_phase == Phase.menu) {
        SystemNavigator.pop();
      } else {
        _go(Phase.menu);
      }
      return;
    }

    _lastBackAttempt = now;
    final onMenu = _phase == Phase.menu;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            onMenu
                ? 'Press back again to quit IMPOSTER'
                : 'Press back again to return to the main menu',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(18, 0, 18, 54),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
        ),
      );
    Future<void>.delayed(Duration(seconds: 2), () {
      if (mounted &&
          _lastBackAttempt == now &&
          DateTime.now().difference(now) >= Duration(seconds: 2)) {
        _lastBackAttempt = null;
      }
    });
  }

  void _scheduleRevealAutoHide() {
    final token = ++_revealAutoHideToken;
    Future<void>.delayed(Duration(seconds: 5), () {
      if (!mounted ||
          token != _revealAutoHideToken ||
          _phase != Phase.reveal ||
          !_revealed) {
        return;
      }
      setState(() => _revealed = false);
      _curtainController.reverse();
    });
  }

  void _addPlayer() {
    if (_players.length >= 20) return;
    setState(() {
      _players.add('');
      _playerIds.add(_nextPlayerId++);
      _syncControllers();
    });
  }

  void _removePlayer(int i) {
    if (_players.length <= 3 || i < 0 || i >= _players.length) return;
    setState(() {
      _players.removeAt(i);
      _playerIds.removeAt(i);
      _controllers.removeAt(i).dispose();
      final removedFocusNode = _playerFocusNodes.removeAt(i);
      removedFocusNode.unfocus();
      removedFocusNode.dispose();
    });
  }

  Future<void> _startRound() async {
    if (_busy ||
        (_phase != Phase.menu && _phase != Phase.results) ||
        _players.length < 3 ||
        _players.length > 20) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    setState(() {
      _busy = true;
      if (_matchStartedAt == null) {
        _scores.clear();
        _currentRounds.clear();
        _roundNumber = 0;
      }
      for (var i = 0; i < _players.length; i++) {
        final editedName = _controllers[i].text.trim();
        _players[i] = editedName.isEmpty ? 'Player ${i + 1}' : editedName;
      }
      final choices = wordDatabase.where((w) => w.word != _lastWord).toList();
      _word = choices[_random.nextInt(choices.length)];
      _lastWord = _word!.word;
      _imposterIndex = _random.nextInt(_players.length);
      _votes.clear();
      _revealIndex = 0;
      _voterIndex = 0;
      _selectedVote = null;
      _revealed = false;
      _roundAwarded = false;
      for (final p in _players) {
        _scores.putIfAbsent(p, () => 0);
      }
      _matchStartedAt ??= DateTime.now().toIso8601String();
      _roundNumber++;
      _phase = Phase.reveal;
    });
    _curtainController.reset();
    setState(() => _busy = false);
    _syncControllers();
    await _persistUnfinished();
  }

  void _revealRole() {
    if (_revealed) {
      // Any tap on the revealed PaletteScope.of(context).palette.card restarts the five-second privacy timer.
      _scheduleRevealAutoHide();
      return;
    }
    setState(() => _revealed = true);
    _curtainController.forward();
    _scheduleRevealAutoHide();
  }

  void _nextReveal() {
    if (!_revealed) return;
    _revealAutoHideToken++;
    _curtainController.stop();
    setState(() {
      _revealed = false;
      _phase = _revealIndex == _players.length - 1
          ? Phase.discuss
          : Phase.passToNext;
    });
    _curtainController.reset();
  }

  void _passToNextPlayer() {
    if (_phase != Phase.passToNext || _revealIndex >= _players.length - 1) return;
    setState(() {
      _revealIndex++;
      _revealed = false;
      _phase = Phase.reveal;
    });
    _curtainController.reset();
  }

  void _beginVoting() {
    if (_phase != Phase.discuss) return;
    setState(() {
      _voterIndex = 0;
      _selectedVote = null;
      _votes.clear();
      _phase = Phase.voting;
    });
  }

  void _confirmVote() {
    if (_phase != Phase.voting ||
        _selectedVote == null ||
        _voterIndex < 0 ||
        _voterIndex >= _players.length ||
        _votes.containsKey(_voterIndex) ||
        _selectedVote! < 0 ||
        _selectedVote! >= _players.length) {
      return;
    }
    setState(() {
      _votes[_voterIndex] = _selectedVote!;
      _selectedVote = null;
      _phase = _voterIndex == _players.length - 1
          ? Phase.summary
          : Phase.votePass;
    });
  }

  void _passAfterVote() {
    if (_phase != Phase.votePass || _voterIndex >= _players.length - 1) return;
    setState(() {
      _voterIndex++;
      _selectedVote = null;
      _phase = Phase.voting;
    });
  }

  List<int> _voteTotals() {
    final totals = List<int>.filled(_players.length, 0);
    for (final target in _votes.values) {
      if (target >= 0 && target < totals.length) totals[target]++;
    }
    return totals;
  }

  List<int> _leaders(List<int> totals) {
    final maxVotes = totals.reduce(max);
    return [for (var i = 0; i < totals.length; i++) if (totals[i] == maxVotes) i];
  }

  Future<void> _finishRound() async {
    if (_phase != Phase.summary ||
        _roundAwarded ||
        _word == null ||
        _votes.length != _players.length) {
      return;
    }
    _roundAwarded = true;
    final totals = _voteTotals();
    final scoring = calculateRoundScoring(
      votes: _votes,
      playerCount: _players.length,
      imposterIndex: _imposterIndex,
    );
    final caught = scoring.caught;
    final points = scoring.points;
    for (var i = 0; i < _players.length; i++) {
      _scores[_players[i]] = (_scores[_players[i]] ?? 0) + points[i];
    }
    final record = RoundRecord(
      date: DateTime.now().toIso8601String(),
      word: _word!,
      imposter: _players[_imposterIndex],
      players: List<String>.from(_players),
      voteTotals: totals,
      votes: Map<int, int>.from(_votes),
      points: points,
      scores: _players.map((p) => _scores[p] ?? 0).toList(),
      caught: caught,
    );
    setState(() {
      _currentRounds.add(record);
      _selectedHistory = record;
      _phase = Phase.results;
    });
    await _persistUnfinished();
  }

  Future<void> _clearHistory() async {
    setState(() => _history.clear());
    await _persistHistory();
  }

  Future<void> _playAgain() async => _startRound();

  Widget _page(Widget child) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: Offset(0, .035), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_phase), child: child),
              ),
            ),
          ),
        ),
      );

  Widget _panel(Widget child, {EdgeInsets padding = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: PaletteScope.of(context).palette.card.withValues(alpha: .94),
          border: Border.all(color: PaletteScope.of(context).palette.accent.withValues(alpha: .9)),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .32), blurRadius: 25, offset: Offset(0, 10))],
        ),
        child: child,
      );

  Widget _button(String label, VoidCallback? onPressed, {bool main = false, bool compact = false}) {
    final scope = PaletteScope.of(context);
    final partyPalette = scope.selectedIndex == 5;
    final foreground = partyPalette ? const Color(0xFF303544) : Colors.white;
    return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(top: compact ? 8 : 12),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: main ? scope.palette.primary : scope.palette.card2,
              foregroundColor: foreground,
              disabledForegroundColor: foreground.withValues(alpha: .45),
              disabledBackgroundColor: scope.palette.card2.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: main ? Color(0xFFFF6390) : PaletteScope.of(context).palette.accent),
              ),
              minimumSize: Size.fromHeight(compact ? 44 : 52),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .7),
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );
  }

  Widget _heading(String title, {String? subtitle}) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: PaletteScope.of(context).palette.accent.withValues(alpha: .10),
              border: Border.all(color: PaletteScope.of(context).palette.accent),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: PaletteScope.of(context).palette.accent.withValues(alpha: .12), blurRadius: 22)],
            ),
            child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          if (subtitle != null) Padding(
            padding: EdgeInsets.only(top: 8, bottom: 14),
            child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      );

  Widget _historyButton() => Align(
        alignment: Alignment.centerRight,
        child: IconButton.filledTonal(
          key: const ValueKey('history-button'),
          tooltip: 'History',
          onPressed: () => _go(Phase.history),
          icon: const Icon(Icons.history_rounded),
          style: IconButton.styleFrom(
            backgroundColor: PaletteScope.of(context).palette.card2,
            foregroundColor: PaletteScope.of(context).palette.accent,
            side: BorderSide(color: PaletteScope.of(context).palette.accent),
          ),
        ),
      );

  Widget _themeButton() {
    final scope = PaletteScope.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 4),
      child: OutlinedButton.icon(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: scope.palette.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHOOSE YOUR COLOUR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: scope.palette.muted)),
                  SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(gamePalettes.length, (i) {
                      final item = gamePalettes[i];
                      final selected = i == scope.selectedIndex;
                      return Semantics(
                        button: true,
                        selected: selected,
                        label: item.name,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            scope.onSelect(i);
                            Navigator.of(sheetContext).pop();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            width: 142,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.card2,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: selected ? item.accent : item.card2, width: selected ? 2.5 : 1),
                            ),
                            child: Row(
                              children: [
                                Container(width: 34, height: 34, decoration: BoxDecoration(color: item.primary, shape: BoxShape.circle, border: Border.all(color: item.accent, width: 3))),
                                SizedBox(width: 10),
                                Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                                if (selected) Icon(Icons.check_circle, color: item.accent, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        icon: Icon(Icons.palette_outlined, color: scope.palette.accent),
        label: Text('COLOURS · ${scope.palette.name}', style: TextStyle(color: scope.palette.muted, fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(side: BorderSide(color: scope.palette.accent), shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      ),
    );
  }

  Widget _menu() => LayoutBuilder(
        builder: (context, constraints) {
          final paletteScope = PaletteScope.of(context);
          final partyPalette = paletteScope.selectedIndex == 5;
          final compact = constraints.maxHeight < 560;
          const partyPlayerColors = [
            Color(0xFFFF625E),
            Color(0xFF19B5D0),
            Color(0xFF79D34A),
            Color(0xFFFFC857),
            Color(0xFFB88AEF),
            Color(0xFFFF8EBA),
            Color(0xFF68CBB4),
            Color(0xFFFFA65E),
            Color(0xFF78A8EE),
            Color(0xFFB4D95A),
          ];
          final header = partyPalette
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF32375F), Color(0xFF202646)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33242A50), blurRadius: 18, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          const Text('IMPOSTER', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          const Spacer(),
                          IconButton(
                            tooltip: 'History',
                            onPressed: () => _go(Phase.history),
                            icon: const Icon(Icons.history_rounded, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Play with up to 20 friends! Give smart clues about your secret word without being too obvious. Discuss who the imposter could be and vote them out to win the game.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.35, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _historyButton(),
                    _heading('IMPOSTER', subtitle: 'ONE WORD. ONE FAKE. FIND THEM.'),
                  ],
                );
          return Column(
            children: [
              header,
              _themeButton(),
              const SizedBox(height: 4),
              Expanded(
                child: _panel(
                  ListView.builder(
                    key: const ValueKey('player-list'),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                    padding: EdgeInsets.zero,
                    itemCount: _players.length,
                    findChildIndexCallback: (key) {
                      if (key is ValueKey<String> && key.value.startsWith('player-row-')) {
                        final id = int.tryParse(key.value.substring('player-row-'.length));
                        if (id != null) {
                          final index = _playerIds.indexOf(id);
                          return index < 0 ? null : index;
                        }
                      }
                      return null;
                    },
                    itemBuilder: (context, i) {
                      final rowColor = partyPlayerColors[i % partyPlayerColors.length];
                      return Padding(
                        key: ValueKey('player-row-${_playerIds[i]}'),
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Container(
                          padding: partyPalette ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5) : EdgeInsets.zero,
                          decoration: partyPalette ? BoxDecoration(
                            color: rowColor,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 7, offset: Offset(0, 3))],
                          ) : null,
                          child: Row(children: [
                            Icon(partyPalette ? Icons.edit_rounded : Icons.person,
                              color: partyPalette ? const Color(0xFF303544) : paletteScope.palette.muted, size: 27),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(
                              key: ValueKey('player-${_playerIds[i]}'),
                              controller: _controllers[i],
                              focusNode: _playerFocusNodes[i],
                              onChanged: (v) => _updatePlayerName(i, v),
                              readOnly: _matchStartedAt != null,
                              textCapitalization: TextCapitalization.words,
                              keyboardAppearance: partyPalette ? Brightness.light : Brightness.dark,
                              scrollPadding: const EdgeInsets.only(bottom: 120),
                              style: TextStyle(
                                color: partyPalette ? const Color(0xFF303544) : Colors.white,
                                fontSize: partyPalette ? 20 : 16,
                                fontWeight: partyPalette ? FontWeight.w800 : FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter player ${i + 1} name',
                                hintStyle: TextStyle(color: partyPalette ? const Color(0x99303544) : null),
                                filled: !partyPalette,
                                fillColor: paletteScope.palette.card2,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: partyPalette ? 15 : 11),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                              ),
                            )),
                            if (_players.length > 3)
                              IconButton(
                                key: ValueKey('remove-player-${_playerIds[i]}'),
                                onPressed: _matchStartedAt == null ? () => _removePlayer(i) : null,
                                icon: Icon(Icons.remove_circle, color: partyPalette ? const Color(0xFF303544) : danger),
                              ),
                          ]),
                        ),
                      );
                    },
                  ),
                  padding: EdgeInsets.all(partyPalette ? 12 : 14),
                ),
              ),
              _button('+ ADD PLAYER', _matchStartedAt == null && _players.length < 20 ? _addPlayer : null, compact: compact),
              _button('PLAY', _startRound, main: true, compact: compact),
              if (!compact) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Pass the phone. Find the fake.', style: TextStyle(color: paletteScope.palette.muted))),
            ],
          );
        },
      );

  Widget _reveal() {
    final player = _players[_revealIndex];
    final isImposter = _revealIndex == _imposterIndex;
    return Column(
      key: ValueKey('reveal'),
      children: [
        SizedBox(height: 6),
        Text(
          player.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
        ),
        Text(
          "It's your turn.",
          style: TextStyle(
            color: PaletteScope.of(context).palette.muted,
            fontSize: 17,
          ),
        ),
        SizedBox(height: 18),
        Expanded(
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PaletteScope.of(context).palette.card,
                  border: Border.all(
                    color: PaletteScope.of(context).palette.accent,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: EdgeInsets.all(24),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 280),
                    child: !_revealed
                        ? Text(
                            'PRIVATE ROLE REVEAL',
                            key: ValueKey('hidden'),
                            style: TextStyle(
                              color: PaletteScope.of(context).palette.muted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          )
                        : Column(
                            key: ValueKey('shown'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: isImposter
                                ? [
                                    Text(
                                      'YOUR ROLE',
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'YOU ARE THE IMPOSTER',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 29,
                                        fontWeight: FontWeight.w900,
                                        color: PaletteScope.of(context).palette.primary,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'YOUR CATEGORY',
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                      ),
                                    ),
                                    Text(
                                      _word!.category,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      _word!.categoryHi,
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ]
                                : [
                                    Text(
                                      'WORD',
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                      ),
                                    ),
                                    Text(
                                      _word!.word,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      _word!.wordHi,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      'CATEGORY',
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                      ),
                                    ),
                                    Text(
                                      _word!.category,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      _word!.categoryHi,
                                      style: TextStyle(
                                        color: PaletteScope.of(context).palette.muted,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                          ),
                  ),
                ),
              ),
              SlideTransition(
                position: _curtainSlide,
                child: GestureDetector(
                  onTap: _revealRole,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PaletteScope.of(context).palette.card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: PaletteScope.of(context).palette.accent.withValues(alpha: .2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'TAP HERE TO\nREVEAL YOUR ROLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        _button(
          _revealIndex == _players.length - 1 ? 'FINISH REVEAL' : 'CONTINUE',
          _revealed ? _nextReveal : null,
          main: true,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Keep the screen private, then pass the phone.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PaletteScope.of(context).palette.muted),
          ),
        ),
      ],
    );
  }

  Widget _passToNext() {
    final nextPlayer = _players[_revealIndex + 1];
    return Column(
      mainAxisSize: MainAxisSize.min,
      key: ValueKey('passToNext'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swap_horiz_rounded, color: PaletteScope.of(context).palette.accent, size: 64),
        SizedBox(height: 20),
        Text(
          'PASS THE PHONE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        SizedBox(height: 12),
        Text(
          'Pass to ${nextPlayer.toUpperCase()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: PaletteScope.of(context).palette.primary),
        ),
        SizedBox(height: 10),
        Text(
          'Make sure the next player is ready before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 16, height: 1.4),
        ),
        SizedBox(height: 24),
        _panel(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, color: PaletteScope.of(context).palette.accent),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Your role is hidden. Keep it secret.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        )),
        SizedBox(height: 14),
        _button('PASS TO ${nextPlayer.toUpperCase()}', _passToNextPlayer, main: true),
      ],
    );
  }

  Widget _discuss() => Column(
        mainAxisSize: MainAxisSize.min,
        key: ValueKey('discuss'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, color: PaletteScope.of(context).palette.accent, size: 58),
          SizedBox(height: 12),
          Text('DISCUSS IRL', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text('The secret words have been revealed. Put the phone down and discuss your clues. Talk it out, make accusations, defend yourself, and decide who the Imposter is.', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 17, height: 1.45)),
          _button('READY TO VOTE?', _beginVoting, main: true),
        ],
      );

  Widget _voting() {
    final voter = _players[_voterIndex];
    return Column(
      key: ValueKey('voting'),
      children: [
        Text(
          '${voter.toUpperCase()} — VOTE',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 5),
        Text(
          'Who do you think is the Imposter?',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletteScope.of(context).palette.muted),
        ),
        SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 400;
              final compact = constraints.maxHeight < 360;
              return GridView.builder(
                // Keep the lower choices partially below the fold like the previous
                // voting layout; players can scroll to them without losing controls.
                padding: EdgeInsets.only(top: 24, bottom: 6),
                itemCount: _players.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: narrow ? 1 : 2,
                  mainAxisExtent: compact ? 52 : 64,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (context, i) => OutlinedButton(
                  onPressed: () => setState(() => _selectedVote = i),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: _selectedVote == i
                        ? PaletteScope.of(context).palette.primary
                        : PaletteScope.of(context).palette.card,
                    foregroundColor: PaletteScope.of(context).selectedIndex == 5 ? const Color(0xFF303544) : Colors.white,
                    side: BorderSide(
                      color: _selectedVote == i
                          ? Color(0xFFFF6390)
                          : PaletteScope.of(context).palette.accent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    _players[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              );
            },
          ),
        ),
        _button(
          _voterIndex == _players.length - 1
              ? 'LOCK VOTE & SHOW SUMMARY'
              : 'CONFIRM & PASS PHONE',
          _confirmVote,
          main: true,
          compact: true,
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Your vote stays private between turns.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PaletteScope.of(context).palette.muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _votePass() {
    final recordedVotes = _votes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final nextVoterIndex = _voterIndex + 1;
    final palette = PaletteScope.of(context).palette;

    return Column(
      key: const ValueKey('votePass'),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VOTING', style: TextStyle(color: palette.muted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  SizedBox(height: 4),
                  Text('Vote submitted!', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: palette.card2, borderRadius: BorderRadius.circular(30)),
              child: Text('${_votes.length} ${_votes.length == 1 ? 'vote' : 'votes'}', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text("${_players[_voterIndex]}'s vote has been recorded.", textAlign: TextAlign.center, style: TextStyle(color: palette.muted, fontSize: 16)),
        SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: _panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('VOTES SO FAR', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      Icon(Icons.how_to_vote_rounded, color: palette.accent),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...recordedVotes.map((entry) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: palette.card2, borderRadius: BorderRadius.circular(14)),
                          child: Text('${entry.key + 1}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_players[entry.key], style: TextStyle(fontWeight: FontWeight.w800)),
                              Text('Voted for ${_players[entry.value]}', style: TextStyle(color: palette.muted, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle_outline_rounded, color: good, size: 21),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        _panel(
          Column(
            children: [
              Icon(Icons.phone_android_rounded, size: 32, color: palette.accent),
              SizedBox(height: 8),
              Text('PASS TO THE NEXT PLAYER', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Hand the phone to ${_players[nextVoterIndex]}. Make sure they are ready before continuing.', textAlign: TextAlign.center, style: TextStyle(color: palette.muted, fontSize: 15, height: 1.4)),
              _button('PASS TO ${_players[nextVoterIndex].toUpperCase()}', _passAfterVote, main: true, compact: true),
            ],
          ),
          padding: EdgeInsets.all(16),
        ),
      ],
    );
  }

  Widget _summary() {
    final totals = _voteTotals();
    final leaders = _leaders(totals);
    final maxVotes = totals.reduce(max);
    return Column(
      key: ValueKey('summary'),
      children: [
        Text('VOTE SUMMARY', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        SizedBox(height: 14),
        Expanded(child: SingleChildScrollView(child: _panel(Column(children: List.generate(_players.length, (i) => Padding(
          padding: EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            SizedBox(width: 100, child: Text(_players[i], overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: maxVotes == 0 ? 0 : totals[i] / maxVotes, minHeight: 12, backgroundColor: PaletteScope.of(context).palette.card2, color: leaders.contains(i) ? PaletteScope.of(context).palette.primary : PaletteScope.of(context).palette.accent),
            )),
            SizedBox(width: 10),
            SizedBox(width: 20, child: Text('${totals[i]}')),
          ]),
        )))))),
        Text(leaders.length > 1 ? 'Tie detected — nobody has a sole top vote.' : 'Top vote: ${_players[leaders.first]}', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
        _button('REVEAL RESULTS', _finishRound, main: true),
      ],
    );
  }

  Widget _results() {
    final record = _selectedHistory!;
    return Column(
      key: ValueKey('results'),
      children: [
        Text('ROUND $_roundNumber', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w800)),
        Text(record.caught ? 'IMPOSTER CAUGHT' : 'IMPOSTER NOT CAUGHT', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: record.caught ? const Color(0xFF36C66B) : const Color(0xFFE34B55))),
        SizedBox(height: 10),
        _panel(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('WORD', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
              Text(record.word.word, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              Text(record.word.wordHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
              SizedBox(height: 8),
              Text('CATEGORY', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
              Text(record.word.category, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              Text(record.word.categoryHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
            ],
          ),
          padding: EdgeInsets.all(12),
        ),
        SizedBox(height: 8),
        Expanded(
          child: _panel(
            ListView(
              key: ValueKey('results-player-list'),
              padding: EdgeInsets.zero,
              children: [
                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('IMPOSTER', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
                  Text(record.imposter, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ])),
                SizedBox(height: 8),
                Divider(color: PaletteScope.of(context).palette.accent),
                Text('SCOREBOARD', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w800)),
                ...List.generate(record.players.length, (i) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text(record.players[i])),
                    Text('${record.points[i] > 0 ? '+' : ''}${record.points[i]}', style: TextStyle(fontWeight: FontWeight.w900, color: record.points[i] > 0 ? good : record.points[i] < 0 ? danger : (PaletteScope.of(context).selectedIndex == 5 ? const Color(0xFF303544) : Colors.white))),
                    SizedBox(width: 22),
                    SizedBox(width: 35, child: Text('${record.scores[i]}', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w900))),
                  ]),
                )),
              ],
            ),
            padding: EdgeInsets.all(12),
          ),
        ),
        _button('PLAY AGAIN', _playAgain, main: true),
        _button('MAIN MENU', () async { await _completeMatch(); _go(Phase.menu); }),
      ],
    );
  }

  Widget _historyPage() => Column(
        key: ValueKey('history'),
        children: [
          Row(children: [
            Expanded(child: Text('HISTORY', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
            TextButton(onPressed: _history.isEmpty ? null : _clearHistory, child: Text('CLEAR', style: TextStyle(color: danger))),
          ]),
          Expanded(child: _history.isEmpty
              ? Center(child: _panel(Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('NO MATCHES YET', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('Completed games will appear here.', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                ])))
              : ListView.separated(
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => SizedBox(height: 9),
                  itemBuilder: (context, i) {
                    final match = _history[i];
                    return _panel(InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        _selectedMatch = match;
                        _phase = Phase.historyDetail;
                      }),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: PaletteScope.of(context).palette.card2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.emoji_events_outlined, color: PaletteScope.of(context).palette.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('MATCH ${_history.length - i}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                            Text('${match.rounds.length} rounds · ${match.players.length} players', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 12)),
                          ],
                        )),
                        Text(_formatDate(match.startedAt), style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 11)),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: PaletteScope.of(context).palette.muted),
                      ]),
                    ));
                  },
                )),
          _button('BACK TO GAME', () => _go(Phase.menu), main: true),
        ],
      );

  Widget _historyDetail() {
    final match = _selectedMatch!;
    return Column(
      key: const ValueKey('historyDetail'),
      children: [
        Text('MATCH DETAILS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        Text('${match.rounds.length} rounds played', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
        Expanded(child: ListView(
          children: [
            _panel(Column(children: [
              Text('FINAL SCOREBOARD', style: TextStyle(fontWeight: FontWeight.w900)),
              ...match.players.map((player) => Row(children: [
                Expanded(child: Text(player)),
                Text('${match.finalScores[player] ?? 0} pts', style: TextStyle(fontWeight: FontWeight.w900)),
              ])),
            ])),
            const SizedBox(height: 12),
            ...List.generate(match.rounds.length, (index) {
              final round = match.rounds[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ROUND ${index + 1}', style: TextStyle(color: PaletteScope.of(context).palette.accent, fontWeight: FontWeight.w900)),
                  Text('${round.word.word} · ${round.word.category}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  Text('Imposter: ${round.imposter} · ${round.caught ? 'Caught' : 'Escaped'}'),
                  const Divider(),
                  ...List.generate(round.players.length, (i) => Row(children: [
                    Expanded(child: Text(round.players[i])),
                    Text('${round.voteTotals[i]} votes · ${round.points[i] > 0 ? '+' : ''}${round.points[i]} pts · total ${round.scores[i]}'),
                  ])),
                  const SizedBox(height: 8),
                  Text('VOTING', style: TextStyle(fontWeight: FontWeight.w900, color: PaletteScope.of(context).palette.muted)),
                  ...(round.votes.entries.toList()..sort((a,b)=>a.key.compareTo(b.key))).map((entry) => Text('${round.players[entry.key]} voted for ${round.players[entry.value]}')),
                ])),
              );
            }),
          ],
        )),
        _button('BACK TO HISTORY', () => _go(Phase.history)),
        _button('BACK TO GAME', () => _go(Phase.menu), main: true),
      ],
    );
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_phase) {
      case Phase.menu:
        body = _menu();
      case Phase.reveal:
        body = _reveal();
      case Phase.passToNext:
        body = SingleChildScrollView(child: _passToNext());
      case Phase.discuss:
        body = SingleChildScrollView(child: _discuss());
      case Phase.voting:
        body = _voting();
      case Phase.votePass:
        body = _votePass();
      case Phase.summary:
        body = _summary();
      case Phase.results:
        body = _results();
      case Phase.history:
        body = _historyPage();
      case Phase.historyDetail:
        body = _historyDetail();
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.85, -0.95),
            radius: 1.3,
            colors: [PaletteScope.of(context).palette.card2, PaletteScope.of(context).palette.background],
          ),
        ),
        child: _page(body),
      ),
      ),
    );
  }
}
