import 'package:test/test.dart';

import 'package:ac_bcp47/ac_bcp47.dart';

void main() {
  group('Simple language subtag', () {
    const dataset = [
      [
        'de (German)',
        'de',
        'de',
      ],
      [
        'fr (French)',
        'fr',
        'fr',
      ],
      [
        'ja (Japanese)',
        'ja',
        'ja',
      ],
    ];

    for (final data in dataset) {
      test(data.first, () {
        final languageTag = Bcp47LanguageTag.parse(data[1]) as Bcp47LangTag;
        expect(languageTag.language, equals(data[2]));
        expect(languageTag.toString(), data[1]);
      });
    }

    test('i-enochian (example of a grandfathered tag)', () {
      final languageTag =
          Bcp47LanguageTag.parse('i-enochian') as Bcp47GrandfatheredTag;
      expect(languageTag.toString(), equals('i-enochian'));
    });
  });

  group('Language subtag plus Script subtag', () {
    test('zh-Hant (Chinese written using the Traditional Chinese script)', () {
      final languageTag = Bcp47LanguageTag.parse('zh-Hant') as Bcp47LangTag;
      expect(languageTag.language, equals('zh'));
      expect(languageTag.script, equals('Hant'));
      expect(languageTag.toString(), 'zh-Hant');
    });

    test('zh-Hans (Chinese written using the Simplified Chinese script)', () {
      final languageTag = Bcp47LanguageTag.parse('zh-Hans') as Bcp47LangTag;
      expect(languageTag.language, equals('zh'));
      expect(languageTag.script, equals('Hans'));
      expect(languageTag.toString(), 'zh-Hans');
    });

    test('sr-Cyrl (Serbian written using the Cyrillic script)', () {
      final languageTag = Bcp47LanguageTag.parse('sr-Cyrl') as Bcp47LangTag;
      expect(languageTag.language, equals('sr'));
      expect(languageTag.script, equals('Cyrl'));
      expect(languageTag.toString(), 'sr-Cyrl');
    });

    test('sr-Latn (Serbian written using the Latin script)', () {
      final languageTag = Bcp47LanguageTag.parse('sr-Latn') as Bcp47LangTag;
      expect(languageTag.language, equals('sr'));
      expect(languageTag.script, equals('Latn'));
      expect(languageTag.toString(), 'sr-Latn');
    });
  });

  group(
    'Extended language subtags and their primary language subtag counterparts',
    () {
      test(
        'zh-cmn-Hans-CN (Chinese, Mandarin, Simplified script, as used in China)',
        () {
          final languageTag =
              Bcp47LanguageTag.parse('zh-cmn-Hans-CN') as Bcp47LangTag;
          expect(languageTag.language, equals('zh'));
          expect(languageTag.extlangs, equals(['cmn']));
          expect(languageTag.script, equals('Hans'));
          expect(languageTag.region, equals('CN'));
          expect(languageTag.toString(), 'zh-cmn-Hans-CN');
        },
      );

      test(
        'cmn-Hans-CN (Mandarin Chinese, Simplified script, as used in China)',
        () {
          final languageTag =
              Bcp47LanguageTag.parse('cmn-Hans-CN') as Bcp47LangTag;
          expect(languageTag.language, equals('cmn'));
          expect(languageTag.script, equals('Hans'));
          expect(languageTag.region, equals('CN'));
          expect(languageTag.toString(), 'cmn-Hans-CN');
        },
      );

      test('zh-yue-HK (Chinese, Cantonese, as used in Hong Kong SAR)', () {
        final languageTag = Bcp47LanguageTag.parse('zh-yue-HK') as Bcp47LangTag;
        expect(languageTag.language, equals('zh'));
        expect(languageTag.extlangs, equals(['yue']));
        expect(languageTag.region, equals('HK'));
        expect(languageTag.toString(), 'zh-yue-HK');
      });

      test('yue-HK (Cantonese Chinese, as used in Hong Kong SAR)', () {
        final languageTag = Bcp47LanguageTag.parse('yue-HK') as Bcp47LangTag;
        expect(languageTag.language, equals('yue'));
        expect(languageTag.region, equals('HK'));
        expect(languageTag.toString(), 'yue-HK');
      });
    },
  );

  group('Language-Script-Region', () {
    test(
      'zh-Hans-CN (Chinese written using the Simplified script as used in mainland China)',
      () {
        final languageTag =
            Bcp47LanguageTag.parse('zh-Hans-CN') as Bcp47LangTag;
        expect(languageTag.language, equals('zh'));
        expect(languageTag.script, equals('Hans'));
        expect(languageTag.region, equals('CN'));
        expect(languageTag.toString(), 'zh-Hans-CN');
      },
    );

    test(
      'sr-Latn-RS (Serbian written using the Latin script as used in Serbia)',
      () {
        final languageTag =
            Bcp47LanguageTag.parse('sr-Latn-RS') as Bcp47LangTag;
        expect(languageTag.language, equals('sr'));
        expect(languageTag.script, equals('Latn'));
        expect(languageTag.region, equals('RS'));
        expect(languageTag.toString(), 'sr-Latn-RS');
      },
    );
  });

  group('Language-Variant', () {
    test('sl-rozaj (Resian dialect of Slovenian)', () {
      final languageTag = Bcp47LanguageTag.parse('sl-rozaj') as Bcp47LangTag;
      expect(languageTag.language, equals('sl'));
      expect(languageTag.variants, equals(['rozaj']));
      expect(languageTag.toString(), 'sl-rozaj');
    });

    test(
      'sl-rozaj-biske (San Giorgio dialect of Resian dialect of Slovenian)',
      () {
        final languageTag =
            Bcp47LanguageTag.parse('sl-rozaj-biske') as Bcp47LangTag;
        expect(languageTag.language, equals('sl'));
        expect(languageTag.variants, equals(['rozaj', 'biske']));
        expect(languageTag.toString(), 'sl-rozaj-biske');
      },
    );

    test('sl-nedis (Nadiza dialect of Slovenian)', () {
      final languageTag = Bcp47LanguageTag.parse('sl-nedis') as Bcp47LangTag;
      expect(languageTag.language, equals('sl'));
      expect(languageTag.variants, equals(['nedis']));
      expect(languageTag.toString(), 'sl-nedis');
    });
  });

  group('Language-Region-Variant', () {
    test(
      'de-CH-1901 (German as used in Switzerland using the 1901 variant [orthography])',
      () {
        final languageTag =
            Bcp47LanguageTag.parse('de-CH-1901') as Bcp47LangTag;
        expect(languageTag.language, equals('de'));
        expect(languageTag.region, equals('CH'));
        expect(languageTag.variants, equals(['1901']));
        expect(languageTag.toString(), 'de-CH-1901');
      },
    );

    test('sl-IT-nedis (Slovenian as used in Italy, Nadiza dialect)', () {
      final languageTag = Bcp47LanguageTag.parse('sl-IT-nedis') as Bcp47LangTag;
      expect(languageTag.language, equals('sl'));
      expect(languageTag.region, equals('IT'));
      expect(languageTag.variants, equals(['nedis']));
      expect(languageTag.toString(), 'sl-IT-nedis');
    });
  });
  group('Language-Script-Region-Variant', () {
    test(
      'hy-Latn-IT-arevela (Eastern Armenian written in Latin script, as used in Italy)',
      () {
        final languageTag =
            Bcp47LanguageTag.parse('hy-Latn-IT-arevela') as Bcp47LangTag;
        expect(languageTag.language, equals('hy'));
        expect(languageTag.script, equals('Latn'));
        expect(languageTag.region, equals('IT'));
        expect(languageTag.variants, equals(['arevela']));
        expect(languageTag.toString(), 'hy-Latn-IT-arevela');
      },
    );
  });
  group('Language-Region', () {
    test('de-DE (German for Germany)', () {
      final languageTag = Bcp47LanguageTag.parse('de-DE') as Bcp47LangTag;
      expect(languageTag.language, equals('de'));
      expect(languageTag.region, equals('DE'));
      expect(languageTag.toString(), 'de-DE');
    });

    test('en-US (English as used in the United States)', () {
      final languageTag = Bcp47LanguageTag.parse('en-US') as Bcp47LangTag;
      expect(languageTag.language, equals('en'));
      expect(languageTag.region, equals('US'));
      expect(languageTag.toString(), 'en-US');
    });

    test(
      'es-419 (Spanish appropriate for the Latin America and Caribbean region using the UN region code)',
      () {
        final languageTag = Bcp47LanguageTag.parse('es-419') as Bcp47LangTag;
        expect(languageTag.language, equals('es'));
        expect(languageTag.region, equals('419'));
        expect(languageTag.toString(), 'es-419');
      },
    );
  });
  group('Private use subtags', () {
    test('de-CH-x-phonebk', () {
      final languageTag =
          Bcp47LanguageTag.parse('de-CH-x-phonebk') as Bcp47LangTag;
      expect(languageTag.language, equals('de'));
      expect(languageTag.region, equals('CH'));
      expect(languageTag.privateUse.toString(), equals('x-phonebk'));
      expect(languageTag.toString(), 'de-CH-x-phonebk');
    });

    test('az-Arab-x-AZE-derbend', () {
      final languageTag =
          Bcp47LanguageTag.parse('az-Arab-x-AZE-derbend') as Bcp47LangTag;
      expect(languageTag.language, equals('az'));
      expect(languageTag.script, equals('Arab'));
      expect(languageTag.privateUse.toString(), equals('x-AZE-derbend'));
      expect(languageTag.toString(), 'az-Arab-x-AZE-derbend');
    });
  });
  group('Private use registry values', () {
    test('x-whatever (private use using the singleton "x")', () {
      final languageTag =
          Bcp47LanguageTag.parse('x-whatever') as Bcp47PrivateUseTag;
      expect(languageTag.toString(), 'x-whatever');
    });

    test('qaa-Qaaa-QM-x-southern (all private tags)', () {
      final languageTag =
          Bcp47LanguageTag.parse('qaa-Qaaa-QM-x-southern') as Bcp47LangTag;
      expect(languageTag.language, equals('qaa'));
      expect(languageTag.script, equals('Qaaa'));
      expect(languageTag.region, equals('QM'));
      expect(languageTag.privateUse.toString(), equals('x-southern'));
      expect(languageTag.toString(), 'qaa-Qaaa-QM-x-southern');
    });

    test('de-Qaaa (German, with a private script)', () {
      final languageTag = Bcp47LanguageTag.parse('de-Qaaa') as Bcp47LangTag;
      expect(languageTag.language, equals('de'));
      expect(languageTag.script, equals('Qaaa'));
      expect(languageTag.toString(), 'de-Qaaa');
    });

    test('sr-Latn-QM (Serbian, Latin script, private region)', () {
      final languageTag = Bcp47LanguageTag.parse('sr-Latn-QM') as Bcp47LangTag;
      expect(languageTag.language, equals('sr'));
      expect(languageTag.script, equals('Latn'));
      expect(languageTag.region, equals('QM'));
      expect(languageTag.toString(), 'sr-Latn-QM');
    });

    test('sr-Qaaa-RS (Serbian, private script, for Serbia)', () {
      final languageTag = Bcp47LanguageTag.parse('sr-Qaaa-RS') as Bcp47LangTag;
      expect(languageTag.language, equals('sr'));
      expect(languageTag.script, equals('Qaaa'));
      expect(languageTag.region, equals('RS'));
      expect(languageTag.toString(), 'sr-Qaaa-RS');
    });
  });
  group(
    'Tags that use extensions (examples ONLY -- extensions MUST be defined by revision or update to this document, or by RFC)',
    () {
      test('en-US-u-islamcal', () {
        final languageTag =
            Bcp47LanguageTag.parse('en-US-u-islamcal') as Bcp47LangTag;
        expect(languageTag.language, equals('en'));
        expect(languageTag.region, equals('US'));
        expect(
          languageTag.extensions.map((e) => e.toString()),
          equals(['u-islamcal']),
        );
        expect(languageTag.toString(), 'en-US-u-islamcal');
      });

      test('zh-CN-a-myext-x-private', () {
        final languageTag =
            Bcp47LanguageTag.parse('zh-CN-a-myext-x-private') as Bcp47LangTag;
        expect(languageTag.language, equals('zh'));
        expect(languageTag.region, equals('CN'));
        expect(
          languageTag.extensions.map((e) => e.toString()),
          equals(['a-myext']),
        );
        expect(languageTag.privateUse.toString(), equals('x-private'));
        expect(languageTag.toString(), 'zh-CN-a-myext-x-private');
      });

      test('en-a-myext-b-another', () {
        final languageTag =
            Bcp47LanguageTag.parse('en-a-myext-b-another') as Bcp47LangTag;
        expect(languageTag.language, equals('en'));
        expect(
          languageTag.extensions.map((e) => e.toString()),
          equals(['a-myext', 'b-another']),
        );
        expect(languageTag.toString(), 'en-a-myext-b-another');
      });
    },
  );
  group('Some Invalid Tags', () {
    test('de-419-DE (two region tags)', () {
      void call() => Bcp47LanguageTag.parse('de-419-DE');
      expect(call, throwsA(anything));
    });

    test(
      'a-DE (use of a single-character subtag in primary position; note that there are a few grandfathered tags that start with "i-" that are valid)',
      () {
        void call() => Bcp47LanguageTag.parse('a-DE');
        expect(call, throwsA(anything));
      },
    );

    test(
      'ar-a-aaa-b-bbb-a-ccc (two extensions with same single-letter prefix)',
      () {
        void call() => Bcp47LanguageTag.parse('ar-a-aaa-b-bbb-a-ccc');
        expect(call, throwsA(anything));
      },
    );
  });

  group('Well-formed tags (from langtag.net)', () {
    // https://web.archive.org/web/20210512054243/http://langtag.net/test-suites/well-formed-tags.txt
    const kWellFormedTags = [
      'fr',
      'fr-Latn',
      'fr-fra', //Extended tag
      'fr-Latn-FR',
      'fr-Latn-419',
      'fr-FR',
      'ax-TZ', //Not in the registry, but well-formed
      'fr-shadok', //Variant
      'fr-y-myext-myext2',
      'fra-Latn', //ISO 639 can be 3-letters
      'fra',
      'fra-FX',
      'i-klingon', //grandfathered with singleton
      'I-kLINgon', //tags are case-insensitive...
      'no-bok', //grandfathered without singleton
      'fr-Lat', //Extended
      'mn-Cyrl-MN',
      'mN-cYrL-Mn',
      'fr-Latn-CA',
      'en-US',
      'fr-Latn-CA',
      'i-enochian', //Grand fathered
      'x-fr-CH',
      'sr-Latn-CS',
      'es-419',
      'sl-nedis',
      'de-CH-1996',
      'de-Latg-1996',
      'sl-IT-nedis',
      'en-a-bbb-x-a-ccc',
      'de-a-value',
      'en-Latn-GB-boont-r-extended-sequence-x-private',
      'en-x-US',
      'az-Arab-x-AZE-derbend',
      'es-Latn-CO-x-private',
      'en-US-boont',
      'ab-x-abc-x-abc', //anything goes after x
      'ab-x-abc-a-a', //ditto
      'i-default', //grandfathered
      'i-klingon', //grandfathered
      'abcd-Latn', //Language of 4 chars reserved for future use
      'AaBbCcDd-x-y-any-x', //Language of 5-8 chars, registered
      'en',
      'de-AT',
      'es-419',
      'de-CH-1901',
      'sr-Cyrl',
      'sr-Cyrl-CS',
      'sl-Latn-IT-rozaj',
      'en-US-x-twain',
      'zh-cmn',
      'zh-cmn-Hant',
      'zh-cmn-Hant-HK',
      'zh-gan',
      'zh-yue-Hant-HK',
      'xr-lxs-qut', // extlangs
      'xr-lqt-qu', // extlang + region
      'xr-p-lze', // Extension
    ];

    for (final wellFormedTag in kWellFormedTags) {
      test(wellFormedTag, () {
        Bcp47LanguageTag.parse(wellFormedTag);
      });
    }
  });

  group('Broken tags (from langtag.net)', () {
    // https://web.archive.org/web/20210512035927/http://langtag.net/test-suites/broken-tags.txt
    const kBrokenTags = [
      'f',
      'f-Latn',
      'fr-Latn-F',
      'a-value',
      'en-a-bbb-a-ccc', // 'a' appears twice
      'tlh-a-b-foo',
      'i-notexist', // grandfathered but not registered: invalid, even if we only test well-formedness
      'abcdefghi-012345678',
      'ab-abc-abc-abc-abc',
      'ab-abcd-abc',
      'ab-ab-abc',
      'ab-123-abc',
      'a-Hant-ZH',
      'a1-Hant-ZH',
      'ab-abcde-abc',
      'ab-1abc-abc',
      'ab-ab-abcd',
      'ab-123-abcd',
      'ab-abcde-abcd',
      'ab-1abc-abcd',
      'ab-a-b',
      'ab-a-x',
      'ab--ab',
      'ab-abc-',
      '-ab-abc',
      'ab-c-abc-r-toto-c-abc', // 'c' appears twice
      'abcd-efg',
      'aabbccddE',
    ];

    for (final brokenTag in kBrokenTags) {
      test(brokenTag, () {
        void call() => Bcp47LanguageTag.parse(brokenTag);
        expect(call, throwsA(anything));
      });
    }
  });

  group('Random well-formed tags (from language-tags Rust crate tests)', () {
    const kRandomWellFormedTags = [
      'zszLDm-sCVS-es-x-gn762vG-83-S-mlL',
      'IIJdFI-cfZv',
      'kbAxSgJ-685',
      'tbutP',
      'hDL-595',
      'dUf-iUjq-0hJ4P-5YkF-WD8fk',
      'FZAABA-FH',
      'xZ-lh-4QfM5z9J-1eG4-x-K-R6VPr2z',
      'Fyi',
      'SeI-DbaG',
      'ch-xwFn',
      'OeC-GPVI',
      'JLzvUSi',
      'Fxh-hLAs',
      'pKHzCP-sgaO-554',
      'eytqeW-hfgH-uQ',
      'ydn-zeOP-PR',
      'uoWmBM-yHCf-JE',
      'xwYem',
      'zie',
      'Re-wjSv-Ey-i-XE-E-JjWTEB8-f-DLSH-NVzLH-AtnFGWoH-SIDE',
      // NOT WELL-FORMED (multiple instance of a particular singleton)
      // 'Ri-063-c-u6v-ZfhkToTB-C-IFfmv-XT-j-rdyYFMhK-h-pY-D5-Oh6FqBhL-hcXt-v-WdpNx71-K-c74m4-eBTT7-JdH7Q1Z',
      'ji',
      'IM-487',
      'EPZ-zwcB',
      'GauwEcwo',
      'kDEP',
      'FwDYt-TNvo',
      'ottqP-KLES-x-9-i9',
      'fcflR-grQQ',
      'TvFwdu-kYhs',
      'WE-336',
      'MgxQa-ywEp-8lcW-7bvT-h-dP1Md-0h7-0Z3ir-K-Srkm-kA-7LXM-Z-whb2MiO-2mNsvbLm-W3O-4r-U-KceIxHdI-gvMVgUBV-2uRUni-J0-7C8yTK2',
      'Hyr-B-evMtVoB1-mtsVZf-vQMV-gM-I-rr-kvLzg-f-lAUK-Qb36Ne-Z-7eFzOD-mv6kKf-l-miZ7U3-k-XDGtNQG',
      'ybrlCpzy',
      // NOT WELL-FORMED (multiple instance of a particular singleton)
      // 'PTow-w-cAQ51-8Xd6E-cumicgt-WpkZv3NY-q-ORYPRy-v-A4jL4A-iNEqQZZ-sjKn-W-N1F-pzyc-xP5eWz-LmsCiCcZ',
      'ih-DlPR-PE',
      'Krf-362',
      'WzaD',
      'EPaOnB-gHHn',
      'XYta',
      'NZ-RgOO-tR',
      'at-FE',
      'Tpc-693',
      'YFp',
      'gRQrQULo',
      'pVomZ-585',
      'laSu-ZcAq-338',
      'gCW',
      'PydSwHRI-TYfF',
      'zKmWDD',
      'X-bCrL5RL',
      'HK',
      'YMKGcLY',
      'GDJ-nHYa-bw-X-ke-rohH5GfS-LdJKsGVe',
      // NOT WELL-FORMED (multiple instance of a particular singleton)
      // 'tfOxdau-yjge-489-a-oB-I8Csb-1ESaK1v-VFNz-N-FT-ZQyn-On2-I-hu-vaW3-jIQb-vg0U-hUl-h-dO6KuJqB-U-tde2L-P3gHUY-vnl5c-RyO-H-gK1-zDPu-VF1oeh8W-kGzzvBbW-yuAJZ',
      'LwDux',
      'Zl-072',
      'Ri-Ar',
      'vocMSwo-cJnr-288',
      'kUWq-gWfQ-794',
      'YyzqKL-273',
      'Xrw-ZHwH-841-9foT-ESSZF-6OqO-0knk-991U-9p3m-b-JhiV-0Kq7Y-h-cxphLb-cDlXUBOQ-X-4Ti-jty94yPp',
      'en-GB-oed',
      'LEuZl-so',
      'HyvBvFi-cCAl-X-irMQA-Pzt-H',
      'uDbsrAA-304',
      'wTS',
      'IWXS',
      'XvDqNkSn-jRDR',
      'gX-Ycbb-iLphEks-AQ1aJ5',
      'FbSBz-VLcR-VL',
      'JYoVQOP-Iytp',
      'gDSoDGD-lq-v-7aFec-ag-k-Z4-0kgNxXC-7h',
      'Bjvoayy-029',
      'qSDJd',
      'qpbQov',
      'fYIll-516',
      'GfgLyfWE-EHtB',
      'Wc-ZMtk',
      'cgh-VEYK',
      'WRZs-AaFd-yQ',
      'eSb-CpsZ-788',
      'YVwFU',
      'JSsHiQhr-MpjT-381',
      'LuhtJIQi-JKYt',
      'vVTvS-RHcP',
      'SY',
      'fSf-EgvQfI-ktWoG-8X5z-63PW',
      'NOKcy',
      'OjJb-550',
      'KB',
      'qzKBv-zDKk-589',
      'Jr',
      'Acw-GPXf-088',
      'WAFSbos',
      'HkgnmerM-x-e5-zf-VdDjcpz-1V6',
      'UAfYflJU-uXDc-YV',
      'x-CHsHx-VDcOUAur-FqagDTx-H-V0e74R',
      'uZIAZ-Xmbh-pd',
    ];

    for (final wellFormedTag in kRandomWellFormedTags) {
      test(wellFormedTag, () {
        Bcp47LanguageTag.parse(wellFormedTag);
      });
    }
  });

  group('Random broken tags (from language-tags Rust crate tests)', () {
    const kRandomBrokenTags = [
      'EdY-z_H791Xx6_m_kj',
      'qWt85_8S0-L_rbBDq0gl_m_O_zsAx_nRS',
      'VzyL2',
      'T_VFJq-L-0JWuH_u2_VW-hK-kbE',
      'u-t',
      'Q-f_ZVJXyc-doj_k-i',
      'JWB7gNa_K-5GB-25t_W-s-ZbGVwDu1-H3E',
      'b-2T-Qob_L-C9v_2CZxK86',
      'fQTpX_0_4Vg_L3L_g7VtALh2',
      'S-Z-E_J',
      'f6wsq-02_i-F',
      '9_GcUPq_G',
      'QjsIy_9-0-7_Dv2yPV09_D-JXWXM',
      'D_se-f-k',
      'ON47Wv1_2_W',
      'f-z-R_s-ha',
      'N3APeiw_195_Bx2-mM-pf-Z-Ip5lXWa-5r',
      'IRjxU-E_6kS_D_b1b_H',
      'NB-3-5-AyW_FQ-9hB-TrRJg3JV_3C',
      'yF-3a_V_FoJQAHeL_Z-Mc-u',
      'n_w_bbunOG_1-s-tJMT5je',
      'Q-AEWE_X',
      '57b1O_k_R6MU_sb',
      'hK_65J_i-o_SI-Y',
      'wB4B7u_5I2_I_NZPI',
      'J24Nb_q_d-zE',
      'v6-dHjJmvPS_IEb-x_A-O-i',
      '8_8_dl-ZgBr84u-P-E',
      'nIn-xD7EVhe_C',
      '5_N-6P_x7Of_Lo_6_YX_R',
      '0_46Oo0sZ-YNwiU8Wr_d-M-pg1OriV',
      'laiY-5',
      'K-8Mdd-j_ila0sSpo_aO8_J',
      'wNATtSL-Cp4_gPa_fD41_9z',
      'H_FGz5V8_n6rrcoz0_1O6d-kH-7-N',
      'wDOrnHU-odqJ_vWl',
      'gP_qO-I-jH',
      'h',
      'dJ0hX-o_csBykEhU-F',
      'L-Vf7_BV_eRJ5goSF_Kp',
      'y-oF-chnavU-H',
      '9FkG-8Q-8_v',
      'W_l_NDQqI-O_SFSAOVq',
      'kDG3fzXw',
      't-nsSp-7-t-mUK2',
      'Yw-F',
      '1-S_3_l',
      'u-v_brn-Y',
      '4_ft_3ZPZC5lA_D',
      'n_dR-QodsqJnh_e',
      'Hwvt-bSwZwj_KL-hxg0m-3_hUG',
      'mQHzvcV-UL-o2O_1KhUJQo_G2_uryk3-a',
      'b-UTn33HF',
      'r-Ep-jY-aFM_N_H',
      'K-k-krEZ0gwD_k_ua-9dm3Oy-s_v',
      'XS_oS-p',
      'EIx_h-zf5',
      'p_z-0_i-omQCo3B',
      '1_q0N_jo_9',
      '0Ai-6-S',
      'L-LZEp_HtW',
      'Zj-A4JD_2A5Aj7_b-m3',
      'x',
      'p-qPuXQpp_d-jeKifB-c-7_G-X',
      'X94cvJ_A',
      'F2D25R_qk_W-w_Okf_kx',
      'rc-f',
      'D',
      'gD_WrDfxmF-wu-E-U4t',
      'Z_BN9O4_D9-D_0E_KnCwZF-84b-19',
      'T-8_g-u-0_E',
      'lXTtys9j_X_A_m-vtNiNMw_X_b-C6Nr',
      'V_Ps-4Y-S',
      'X5wGEA',
      'mIbHFf_ALu4_Jo1Z1',
      'ET-TacYx_c',
      'Z-Lm5cAP_ri88-d_q_fi8-x',
      'rTi2ah-4j_j_4AlxTs6m_8-g9zqncIf-N5',
      'FBaLB85_u-0NxhAy-ZU_9c',
      'x_j_l-5_aV95_s_tY_jp4',
      'PL768_D-m7jNWjfD-Nl_7qvb_bs_8_Vg',
      '9-yOc-gbh',
      '6DYxZ_SL-S_Ye',
      'ZCa-U-muib-6-d-f_oEh_O',
      'Qt-S-o8340F_f_aGax-c-jbV0gfK_p',
      'WE_SzOI_OGuoBDk-gDp',
      'cs-Y_9',
      'm1_uj',
      'Y-ob_PT',
      'li-B',
      'f-2-7-9m_f8den_J_T_d',
      'p-Os0dua-H_o-u',
      'L',
      'rby-w',
    ];

    for (final brokenTag in kRandomBrokenTags) {
      test(brokenTag, () {
        void call() => Bcp47LanguageTag.parse(brokenTag);
        expect(call, throwsA(anything));
      });
    }
  });
}
