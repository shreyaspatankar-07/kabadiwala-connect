import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kabadiwala_mobile/main.dart';
import 'package:kabadiwala_mobile/ui/screens/best_buyers_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/handover_initiate_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/language_selection_screen.dart';
import 'package:kabadiwala_mobile/ui/screens/safety_card_detail_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete Low-Literacy Demo Walkthrough Flow', (WidgetTester tester) async {
    // Launch app wrapped in ProviderScope as in main.dart
    await tester.pumpWidget(
      const ProviderScope(
        child: KabadiwalaCollectorApp(),
      ),
    );
    await tester.pumpAndSettle();

    // =========================================================================
    // PART 1 - Language and PIN setup:
    // =========================================================================
    // 1. Wait for language selection screen
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 2. Tap मराठी tile (key: 'lang_tile_mr')
    final langTile = find.byKey(const Key('lang_tile_mr'));
    expect(langTile, findsOneWidget);
    await tester.tap(langTile);
    await tester.pumpAndSettle();

    // 3. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 4. Tap digits 1,2,3,4 on PIN keypad
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(Key('keypad_$d')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 5. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 6. Tap digits 1,2,3,4 again to confirm PIN
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(Key('keypad_$d')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 7. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // =========================================================================
    // PART 2 - Add Lot flow:
    // =========================================================================
    // 8. Tap Add Lot tab (key: 'nav_add_lot')
    final navAddLot = find.byKey(const Key('nav_add_lot'));
    if (navAddLot.evaluate().isNotEmpty) {
      await tester.tap(navAddLot.first);
      await tester.pumpAndSettle();
    }

    // 9. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 10. Tap PCB category tile (key: 'category_tile_PCB')
    final pcbCategory = find.byKey(const Key('category_tile_PCB'));
    if (pcbCategory.evaluate().isNotEmpty) {
      await tester.tap(pcbCategory.first);
      await tester.pumpAndSettle();
    }

    // 11. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 12. Tap condition chip broken (key: 'condition_broken')
    final conditionBroken = find.byKey(const Key('condition_broken'));
    if (conditionBroken.evaluate().isNotEmpty) {
      await tester.tap(conditionBroken.first);
      await tester.pumpAndSettle();
    }

    // 13. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 14. Tap 5 on number pad (key: 'keypad_5')
    await tester.tap(find.byKey(const Key('keypad_5')));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 400));

    // 15. Tap 0 on number pad (key: 'keypad_0')
    await tester.tap(find.byKey(const Key('keypad_0')));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 400));

    // 16. Tap 0 on number pad (key: 'keypad_0')
    await tester.tap(find.byKey(const Key('keypad_0')));
    await tester.pumpAndSettle();

    // 17. Wait 3 seconds showing value estimate card
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 18. Tap speaker button (key: 'speaker_btn')
    final speakerBtn = find.byKey(const Key('speaker_btn'));
    if (speakerBtn.evaluate().isNotEmpty) {
      await tester.tap(speakerBtn.first);
      await tester.pumpAndSettle();
    }

    // 19. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 20. Tap Save Lot button (key: 'btn_save_lot')
    final saveLotBtn = find.byKey(const Key('btn_save_lot'));
    if (saveLotBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveLotBtn.first);
      await tester.tap(saveLotBtn.first);
      await tester.pumpAndSettle();
    }

    // 21. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // =========================================================================
    // PART 3 - Best Buyers:
    // =========================================================================
    // 22. Wait for Best Buyers screen to appear
    expect(find.byType(BestBuyersScreen), findsOneWidget);

    // 23. Wait 4 seconds showing the 3 recycler cards
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 24. Tap speaker button on top recycler card
    final topCardSpeaker = find.byKey(const Key('btn_speaker_buyer_0'));
    if (topCardSpeaker.evaluate().isNotEmpty) {
      await tester.tap(topCardSpeaker);
    } else {
      final fallbackSpeaker = find.byKey(const Key('speak_top_buyer_button'));
      if (fallbackSpeaker.evaluate().isNotEmpty) {
        await tester.tap(fallbackSpeaker);
      }
    }
    await tester.pumpAndSettle();

    // 25. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 26. Tap Select This Buyer on top card (key: 'btn_select_buyer_0')
    final selectBuyer0 = find.byKey(const Key('btn_select_buyer_0'));
    expect(selectBuyer0, findsOneWidget);
    await tester.tap(selectBuyer0);
    await tester.pumpAndSettle();

    // 27. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // =========================================================================
    // PART 4 - Handover:
    // =========================================================================
    // 28. Wait for handover screen
    expect(find.byType(HandoverInitiateScreen), findsOneWidget);

    // 29. Wait 3 seconds showing QR code
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 30. Tap speaker button
    final handoverSpeaker = find.byKey(const Key('speaker_btn'));
    if (handoverSpeaker.evaluate().isNotEmpty) {
      await tester.tap(handoverSpeaker.first);
      await tester.pumpAndSettle();
    }

    // 31. Wait 4 seconds showing the 6-character code prominently
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 32. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Pop back to main shell so tabs are visible
    final navState = tester.state<NavigatorState>(find.byType(Navigator).last);
    navState.popUntil((route) => route.isFirst);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // =========================================================================
    // PART 5 - Price Board:
    // =========================================================================
    // 33. Tap Price Board tab (key: 'nav_price_board')
    final navPriceBoard = find.byKey(const Key('nav_price_board'));
    expect(navPriceBoard, findsWidgets);
    await tester.tap(navPriceBoard.first);
    await tester.pumpAndSettle();

    // 34. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 35. Tap PCB price tile
    final pcbPriceTile = find.byKey(const Key('category_tile_PCB'));
    expect(pcbPriceTile, findsWidgets);
    await tester.tap(pcbPriceTile.first);
    await tester.pumpAndSettle();

    // 36. Wait 3 seconds showing rate, trend arrow, sparkline
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 37. Tap speaker button
    final priceDetailSpeaker = find.byKey(const Key('detail_speaker_button'));
    if (priceDetailSpeaker.evaluate().isNotEmpty) {
      await tester.tap(priceDetailSpeaker);
    } else {
      final anySpeaker = find.byKey(const Key('speaker_btn'));
      if (anySpeaker.evaluate().isNotEmpty) {
        await tester.tap(anySpeaker.first);
      }
    }
    await tester.pumpAndSettle();

    // 38. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Pop price detail back to grid if needed
    final backToGrid = find.byKey(const Key('back_to_grid_button'));
    if (backToGrid.evaluate().isNotEmpty) {
      await tester.tap(backToGrid);
      await tester.pumpAndSettle();
    }

    // =========================================================================
    // PART 6 - Safety:
    // =========================================================================
    // 39. Tap Safety tab (key: 'nav_safety')
    final navSafety = find.byKey(const Key('nav_safety'));
    expect(navSafety, findsWidgets);
    await tester.tap(navSafety.first);
    await tester.pumpAndSettle();

    // 40. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 41. Tap first safety card in list
    final firstSafetyCard = find.byKey(const Key('safety_card_cables_burn'));
    if (firstSafetyCard.evaluate().isNotEmpty) {
      await tester.tap(firstSafetyCard);
    } else {
      final anySafetyCard = find.byType(InkWell);
      await tester.tap(anySafetyCard.first);
    }
    await tester.pumpAndSettle();

    // 42. Wait 3 seconds showing steps and dos/donts
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 43. Tap speaker button
    final safetyDetailSpeaker = find.byKey(const Key('speaker_btn'));
    if (safetyDetailSpeaker.evaluate().isNotEmpty) {
      await tester.tap(safetyDetailSpeaker.first);
      await tester.pumpAndSettle();
    }

    // 44. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 45. Tap I Understood button (key: 'btn_understood')
    final btnUnderstood = find.byKey(const Key('btn_understood'));
    expect(btnUnderstood, findsWidgets);
    await tester.ensureVisible(btnUnderstood.first);
    await tester.tap(btnUnderstood.first);
    await tester.pumpAndSettle();

    // 46. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Ensure we are back on main navigation shell
    if (find.byType(SafetyCardDetailScreen).evaluate().isNotEmpty) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // =========================================================================
    // PART 7 - Earnings:
    // =========================================================================
    // 47. Tap Earnings tab (key: 'nav_earnings')
    final navEarnings = find.byKey(const Key('nav_earnings'));
    expect(navEarnings, findsWidgets);
    await tester.tap(navEarnings.first);
    await tester.pumpAndSettle();

    // 48. Wait 4 seconds showing today/week/month tiles
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 49. Tap speaker on first transaction row
    final txSpeakerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.key != null &&
          widget.key.toString().contains('speaker_tx_'),
    );
    if (txSpeakerFinder.evaluate().isNotEmpty) {
      await tester.tap(txSpeakerFinder.first);
    } else {
      final anyVolume = find.byIcon(Icons.volume_up_rounded);
      if (anyVolume.evaluate().isNotEmpty) {
        await tester.tap(anyVolume.first);
      }
    }
    await tester.pumpAndSettle();

    // 50. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 51. Scroll down to show pending dues
    final pendingDues = find.byKey(const Key('pending_dues_section'));
    if (pendingDues.evaluate().isNotEmpty) {
      await tester.ensureVisible(pendingDues);
    } else {
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
    }
    await tester.pumpAndSettle();

    // 52. Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
