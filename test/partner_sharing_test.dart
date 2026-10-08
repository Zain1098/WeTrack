import 'package:flutter_test/flutter_test.dart';
import 'package:wetrack/data/models/partner_share_permission.dart';

void main() {
  group('PartnerSharePermission Model Tests', () {
    test('Default constructor provides secure defaults', () {
      const p = PartnerSharePermission();
      expect(p.isConnected, isFalse);
      expect(p.partnerName, isEmpty);
      expect(p.partnerCode, isEmpty);
      expect(p.myUniqueCode, isEmpty);
      expect(p.sharingPreset, 'full');
      expect(p.shareCycleDates, isTrue);
      expect(p.sharePregnancyMilestones, isTrue);
      expect(p.shareAppointments, isTrue);
      expect(p.shareSymptoms, isTrue);
      expect(p.shareIntimacy, isTrue);
      expect(p.sharePersonalNotes, isFalse);
      expect(p.lastCareMessage, isNull);
    });

    test('toJson and fromJson preserves all fields including love reactions and timestamps', () {
      final now = DateTime(2026, 10, 8, 20, 30);
      final original = PartnerSharePermission(
        partnerName: 'Ahmed Jaan',
        partnerCode: 'WT-555-888',
        myUniqueCode: 'WT-123-456',
        isConnected: true,
        connectedAt: now,
        sharingPreset: 'essential',
        lastCareMessage: 'Khayal rakhna apna ❤️',
        lastCareMessageTime: now,
        shareCycleDates: true,
        sharePregnancyMilestones: true,
        shareAppointments: true,
        shareSymptoms: false,
        shareIntimacy: false,
        sharePersonalNotes: false,
      );

      final json = original.toJson();
      final parsed = PartnerSharePermission.fromJson(json);

      expect(parsed.partnerName, 'Ahmed Jaan');
      expect(parsed.partnerCode, 'WT-555-888');
      expect(parsed.myUniqueCode, 'WT-123-456');
      expect(parsed.isConnected, isTrue);
      expect(parsed.connectedAt, now);
      expect(parsed.sharingPreset, 'essential');
      expect(parsed.lastCareMessage, 'Khayal rakhna apna ❤️');
      expect(parsed.lastCareMessageTime, now);
      expect(parsed.shareCycleDates, isTrue);
      expect(parsed.sharePregnancyMilestones, isTrue);
      expect(parsed.shareAppointments, isTrue);
      expect(parsed.shareSymptoms, isFalse);
      expect(parsed.shareIntimacy, isFalse);
      expect(parsed.sharePersonalNotes, isFalse);
    });

    test('copyWith updates individual fields immutably', () {
      const p = PartnerSharePermission();
      final updated = p.copyWith(
        isConnected: true,
        partnerCode: 'WT-ABC-XYZ',
        partnerName: 'Shohar',
        lastCareMessage: 'Dawai le li? 💊',
      );

      expect(updated.isConnected, isTrue);
      expect(updated.partnerCode, 'WT-ABC-XYZ');
      expect(updated.partnerName, 'Shohar');
      expect(updated.lastCareMessage, 'Dawai le li? 💊');
      // original remains unmodified
      expect(p.isConnected, isFalse);
      expect(p.partnerCode, isEmpty);
    });
  });
}
