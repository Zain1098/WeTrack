import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/app_providers.dart';
import 'app_strings.dart';

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getAppLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.saveAppLanguage(language);
    state = language;
  }

  Future<void> toggleLanguage() async {
    final newLang = state == AppLanguage.romanUrdu
        ? AppLanguage.english
        : AppLanguage.romanUrdu;
    await setLanguage(newLang);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(languageProvider);
  switch (lang) {
    case AppLanguage.romanUrdu:
      return const RomanUrduStrings();
    case AppLanguage.english:
      return const EnglishStrings();
  }
});
