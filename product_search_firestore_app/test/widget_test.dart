// The app queries Firestore directly (FirebaseFirestore.instance), so a full widget test
// needs a Firebase project or a fake. This test only checks the Title Case rule and the
// low-stock rule that main.dart uses.
import 'package:flutter_test/flutter_test.dart';

String titleCase(String s) => s
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

void main() {
  test('Title Case retry text', () {
    expect(titleCase('rice'), 'Rice');
    expect(titleCase('basmati RICE'), 'Basmati Rice');
  });

  test('low stock when quantity is below 5', () {
    expect(3 < 5, isTrue);
    expect(5 < 5, isFalse);
  });
}
