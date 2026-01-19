// WeDo 앱 기본 위젯 테스트
//
// 위젯과의 상호작용을 테스트하려면 flutter_test 패키지의 WidgetTester를 사용합니다.
// 예를 들어, 탭과 스크롤 제스처를 보낼 수 있습니다.
// WidgetTester를 사용하여 위젯 트리에서 자식 위젯을 찾고, 텍스트를 읽고,
// 위젯 속성 값이 올바른지 확인할 수 있습니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wedo/app.dart';

void main() {
  testWidgets('WeDoApp renders correctly', (WidgetTester tester) async {
    // ProviderScope로 감싸서 앱 빌드
    await tester.pumpWidget(
      const ProviderScope(
        child: WeDoApp(),
      ),
    );

    // 앱이 정상적으로 렌더링되는지 확인
    // Home 텍스트가 AppBar와 본문에 각각 존재함 (총 2개)
    expect(find.text('Home'), findsNWidgets(2));

    // Scaffold가 존재하는지 확인
    expect(find.byType(Scaffold), findsOneWidget);

    // AppBar가 존재하는지 확인
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('WeDoApp shows placeholder message', (WidgetTester tester) async {
    // ProviderScope로 감싸서 앱 빌드
    await tester.pumpWidget(
      const ProviderScope(
        child: WeDoApp(),
      ),
    );

    // 앱이 정상적으로 시작되는지 확인
    await tester.pumpAndSettle();

    // 플레이스홀더 메시지가 표시되는지 확인
    expect(find.text('이 화면은 구현 예정입니다.'), findsOneWidget);
  });
}
