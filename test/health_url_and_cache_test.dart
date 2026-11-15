import 'package:flutter_test/flutter_test.dart';
import 'package:he_clinic/core/utils/api_url.dart';
import 'package:he_clinic/core/widgets/health_record_card.dart';
import 'package:he_clinic/features/health/health_record.dart';

void main() {
  group('resolveBackendUrl', () {
    const base = 'https://hemedicalapps.com/api/v2/plato';

    test('keeps absolute external URLs unchanged', () {
      expect(
        resolveBackendUrl('https://cdn.example.com/a.pdf', baseUrl: base),
        'https://cdn.example.com/a.pdf',
      );
    });

    test('keeps signed URLs unchanged', () {
      const signed = 'https://hemedicalapps.com/documents/1?signature=abc';
      expect(resolveBackendUrl(signed, baseUrl: base), signed);
    });

    test('resolves relative path against base including its path prefix', () {
      expect(
        resolveBackendUrl('/pdfs/mc_001.pdf', baseUrl: base),
        'https://hemedicalapps.com/api/v2/plato/pdfs/mc_001.pdf',
      );
    });

    test('resolves relative path without leading slash', () {
      expect(
        resolveBackendUrl('pdfs/mc.pdf', baseUrl: base),
        'https://hemedicalapps.com/api/v2/plato/pdfs/mc.pdf',
      );
    });

    test('rebases a loopback host onto the API origin', () {
      expect(
        resolveBackendUrl('http://localhost:8080/uploads/a.png', baseUrl: base),
        'https://hemedicalapps.com/uploads/a.png',
      );
    });
  });

  group('HealthRecord JSON', () {
    test('round-trips all fields', () {
      const record = HealthRecord(
        type: HealthRecordType.letter,
        title: 'Referral to Cardiology',
        date: '2025-06-15',
        author: 'Dr. Ahmad',
        detailData: '<p>Hello</p>',
        category: 'Letter',
        diagnosis: ['flu'],
        attachments: ['/x.pdf'],
      );

      final restored = HealthRecord.fromJson(record.toJson());

      expect(restored.type, HealthRecordType.letter);
      expect(restored.title, 'Referral to Cardiology');
      expect(restored.date, '2025-06-15');
      expect(restored.author, 'Dr. Ahmad');
      expect(restored.detailData, '<p>Hello</p>');
      expect(restored.category, 'Letter');
      expect(restored.diagnosis, ['flu']);
      expect(restored.attachments, ['/x.pdf']);
    });

    test('tolerates an unknown type by falling back to letter', () {
      final record = HealthRecord.fromJson({
        'type': 'bogus',
        'title': 'x',
        'date': '',
        'author': '',
      });
      expect(record.type, HealthRecordType.letter);
    });

    test('isHtml/isFile classify content correctly', () {
      expect(
        const HealthRecord(
          type: HealthRecordType.letter,
          title: 't',
          date: '',
          author: '',
          detailData: '<p>letter</p>',
        ).isHtml,
        isTrue,
      );
      expect(
        const HealthRecord(
          type: HealthRecordType.mc,
          title: 't',
          date: '',
          author: '',
          detailData: 'https://hemedicalapps.com/pdfs/mc.pdf',
        ).isFile,
        isTrue,
      );
      expect(
        const HealthRecord(
          type: HealthRecordType.mc,
          title: 't',
          date: '',
          author: '',
          detailData: '/pdfs/mc.pdf',
        ).isFile,
        isFalse,
      );
    });
  });
}
