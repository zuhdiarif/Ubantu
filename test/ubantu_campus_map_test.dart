import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/ui/widgets/ubantu_campus_map.dart';

void main() {
  group('UbantuCampusMap Widget Tests', () {
    testWidgets('renders map with default center when coordinates are null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UbantuCampusMap(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(UbantuCampusMap), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsNothing);
      expect(find.byType(PolylineLayer), findsNothing);
      expect(find.byType(RichAttributionWidget), findsOneWidget);
    });

    testWidgets('renders pickup marker with primary green pin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UbantuCampusMap(
              pickup: LatLng(-7.9526, 112.6145),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.location_on_rounded));
      expect(icon.color, equals(AppColors.primaryGreen));
      expect(find.byIcon(Icons.flag_rounded), findsNothing);
      expect(find.byType(PolylineLayer), findsNothing);
    });

    testWidgets('renders dropoff marker with accent orange flag', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UbantuCampusMap(
              dropoff: LatLng(-7.9775, 112.6375),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.flag_rounded));
      expect(icon.color, equals(AppColors.accentOrange));
      expect(find.byIcon(Icons.location_on_rounded), findsNothing);
      expect(find.byType(PolylineLayer), findsNothing);
    });

    testWidgets('renders both markers and polyline when both points are provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UbantuCampusMap(
              pickup: LatLng(-7.9526, 112.6145),
              dropoff: LatLng(-7.9775, 112.6375),
              height: 250,
              interactive: false,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);

      final polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
      expect(polylineLayer.polylines.length, equals(1));
      expect(polylineLayer.polylines.first.points.length, equals(2));
      expect(polylineLayer.polylines.first.color, equals(AppColors.primaryDark));

      final container = tester.widget<Container>(find.byType(Container).first);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.borderRadius, equals(BorderRadius.circular(24)));
    });

    testWidgets('displays OpenStreetMap rich attribution widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UbantuCampusMap(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(RichAttributionWidget), findsOneWidget);
    });
  });
}
