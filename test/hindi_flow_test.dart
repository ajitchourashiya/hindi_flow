import 'package:flutter_test/flutter_test.dart';
import 'package:hindi_flow/hindi_flow.dart';

void main() {
  test('public API is available', () {
    expect(HindiFlow.translate, isA<Function>());
    expect(HindiFlow.translateJson, isA<Function>());
    expect(HindiText.new, isA<Function>());
  });
}
