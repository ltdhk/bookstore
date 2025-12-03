// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Toko Buku';

  @override
  String get home => 'Beranda';

  @override
  String get bookshelf => 'Rak Buku';

  @override
  String get profile => 'Saya';

  @override
  String get hot => 'Populer';

  @override
  String get newTab => 'Baru';

  @override
  String get male => 'Pria';

  @override
  String get female => 'Wanita';

  @override
  String get searchHint => 'Cari novel';

  @override
  String get settings => 'Pengaturan';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get alwaysLightMode => 'Selalu Mode Terang';

  @override
  String get autoUnlockChapter => 'Buka kunci bab otomatis';

  @override
  String get language => 'Bahasa';

  @override
  String get versionUpdate => 'Pembaruan Versi';

  @override
  String get about => 'Tentang Novel Next';

  @override
  String get rate => 'Beri Nilai Novel Next';

  @override
  String get followSystem => 'Ikuti Sistem';

  @override
  String get alwaysDark => 'Selalu Mode Gelap';

  @override
  String get alwaysLight => 'Selalu Mode Terang';

  @override
  String get svipMember => 'SVIP';

  @override
  String get regularMember => 'Anggota';

  @override
  String get login => 'Masuk';

  @override
  String get logout => 'Keluar';

  @override
  String get signUp => 'Daftar';

  @override
  String get register => 'Registrasi';

  @override
  String get welcomeBack => 'Selamat Datang Kembali';

  @override
  String get loginToYourAccount => 'Masuk ke akun Anda';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get signUpToGetStarted => 'Daftar untuk memulai';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get nickname => 'Nama Panggilan (Opsional)';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get pleaseEnterEmail => 'Silakan masukkan email Anda';

  @override
  String get pleaseEnterValidEmail => 'Silakan masukkan email yang valid';

  @override
  String get pleaseEnterPassword => 'Silakan masukkan kata sandi Anda';

  @override
  String get passwordMinLength => 'Kata sandi harus minimal 6 karakter';

  @override
  String get pleaseConfirmPassword => 'Silakan konfirmasi kata sandi Anda';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String loginFailed(String error) {
    return 'Login gagal: $error';
  }

  @override
  String registrationFailed(String error) {
    return 'Registrasi gagal: $error';
  }

  @override
  String get registrationSuccessful => 'Registrasi berhasil! Silakan login.';

  @override
  String get agreeToTerms => 'Silakan setujui Ketentuan dan Kebijakan Privasi';

  @override
  String get iAgreeToThe => 'Saya setuju dengan ';

  @override
  String get userAgreement => 'Perjanjian Pengguna';

  @override
  String get and => ' dan ';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get privacyAgreement => 'Perjanjian Privasi';

  @override
  String get whenYouLogin =>
      'Saat Anda login, kami akan menganggap Anda telah membaca dan menyetujui\n';

  @override
  String get loginViaApple => 'Masuk dengan Apple';

  @override
  String get loginViaGoogle => 'Masuk dengan Google';

  @override
  String get loginViaEmail => 'Masuk dengan Email';

  @override
  String get dontHaveAccount => 'Belum punya akun? ';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? ';

  @override
  String get svipMembership => 'KEANGGOTAAN SVIP';

  @override
  String get readAllNovels => 'Baca semua novel di situs tanpa batasan';

  @override
  String get subscribeNow => 'Berlangganan sekarang';

  @override
  String get readingHistory => 'Riwayat bacaan';

  @override
  String get transactionRecord => 'Catatan Transaksi';

  @override
  String get setting => 'Pengaturan';

  @override
  String get myBookshelf => 'Rak buku saya';

  @override
  String get edit => 'Edit';

  @override
  String get cancel => 'batal';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteBooks => 'Hapus Buku';

  @override
  String deleteBooksConfirm(int count) {
    return 'Hapus $count buku dari rak buku Anda?';
  }

  @override
  String get booksRemoved => 'Buku dihapus dari rak buku';

  @override
  String errorRemovingBooks(String error) {
    return 'Kesalahan menghapus buku: $error';
  }

  @override
  String get noBooksInBookshelf => 'Tidak ada buku di rak buku Anda';

  @override
  String get browseBooks => 'Jelajahi buku';

  @override
  String get description => 'Deskripsi';

  @override
  String get reads => 'Pembaca';

  @override
  String get addToBookshelf => 'Tambah ke Rak Buku';

  @override
  String get readNow => 'Baca Sekarang';

  @override
  String get continueReading => 'Lanjutkan Membaca';

  @override
  String get clearAll => 'Hapus Semua';

  @override
  String get clearHistoryConfirm =>
      'Apakah Anda yakin ingin menghapus semua riwayat bacaan?';

  @override
  String get historyClearedSuccess => 'Riwayat bacaan berhasil dihapus';

  @override
  String errorClearingHistory(String error) {
    return 'Kesalahan menghapus riwayat: $error';
  }

  @override
  String get noReadingHistory => 'Belum ada riwayat bacaan';

  @override
  String get startReadingBooks =>
      'Mulai baca beberapa buku untuk melihat riwayat Anda di sini';

  @override
  String errorLoadingHistory(String error) {
    return 'Kesalahan memuat riwayat: $error';
  }

  @override
  String get justNow => 'Baru saja';

  @override
  String minutesAgo(int minutes) {
    return '$minutes menit yang lalu';
  }

  @override
  String get today => 'Hari ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String todayAt(String time) {
    return 'Hari ini $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Kemarin $time';
  }

  @override
  String get pleaseLoginToView =>
      'Silakan login untuk melihat catatan transaksi';

  @override
  String get noTransactionRecords => 'Belum ada catatan transaksi';

  @override
  String get noTransactionHint =>
      'Pembelian langganan Anda akan muncul di sini';

  @override
  String errorLoadingOrders(String error) {
    return 'Kesalahan memuat pesanan: $error';
  }

  @override
  String get loadMore => 'Muat Lebih Banyak';

  @override
  String get noMoreOrders => 'Tidak ada pesanan lagi';

  @override
  String get pending => 'Tertunda';

  @override
  String get paid => 'Dibayar';

  @override
  String get refunded => 'Dikembalikan';

  @override
  String get failedToLoadSubscriptions => 'Gagal memuat langganan';

  @override
  String get subscribeToSVIP => 'Berlangganan SVIP';

  @override
  String get unlockAllContent => 'Buka kunci semua konten';

  @override
  String get monthlyPlan => 'Paket Bulanan';

  @override
  String get quarterlyPlan => 'Paket Triwulan';

  @override
  String get yearlyPlan => 'Paket Tahunan';

  @override
  String get perMonth => '/bulan';

  @override
  String save(String percent) {
    return 'Hemat $percent%';
  }

  @override
  String totalPrice(String price) {
    return 'Total: \$$price';
  }

  @override
  String get subscribe => 'Berlangganan';

  @override
  String get usePasscode => 'Gunakan Kode';

  @override
  String get enterPasscode => 'Masukkan Kode';

  @override
  String get passcodeHint => 'Masukkan kode 16 digit Anda';

  @override
  String get apply => 'Terapkan';

  @override
  String get invalidPasscode =>
      'Format kode tidak valid. Silakan masukkan kode 16 digit.';

  @override
  String successfullySubscribed(String productName) {
    return 'Berhasil berlangganan $productName!';
  }

  @override
  String subscriptionFailed(String error) {
    return 'Langganan gagal: $error';
  }

  @override
  String get processing => 'Memproses...';

  @override
  String chapter(String number) {
    return 'Bab $number';
  }

  @override
  String get chapterLocked => 'Bab ini terkunci';

  @override
  String get unlockWithSVIP => 'Berlangganan SVIP untuk membuka kunci';

  @override
  String get chapterLoadError => 'Gagal memuat bab';

  @override
  String get loading => 'Memuat...';

  @override
  String get novelMaster => 'Novel Next';
}
