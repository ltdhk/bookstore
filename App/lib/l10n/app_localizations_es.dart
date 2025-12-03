// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Librería';

  @override
  String get home => 'Inicio';

  @override
  String get bookshelf => 'Estantería';

  @override
  String get profile => 'Mi';

  @override
  String get hot => 'Popular';

  @override
  String get newTab => 'Nuevo';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get searchHint => 'Buscar novela';

  @override
  String get settings => 'Configuración';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get alwaysLightMode => 'Siempre Modo Claro';

  @override
  String get autoUnlockChapter => 'Desbloquear capítulo automáticamente';

  @override
  String get language => 'Idioma';

  @override
  String get versionUpdate => 'Actualización de Versión';

  @override
  String get about => 'Acerca de Novel Next';

  @override
  String get rate => 'Calificar Novel Next';

  @override
  String get followSystem => 'Seguir Sistema';

  @override
  String get alwaysDark => 'Siempre Modo Oscuro';

  @override
  String get alwaysLight => 'Siempre Modo Claro';

  @override
  String get svipMember => 'SVIP';

  @override
  String get regularMember => 'Miembro';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get register => 'Registrar';

  @override
  String get welcomeBack => 'Bienvenido de Vuelta';

  @override
  String get loginToYourAccount => 'Inicia sesión en tu cuenta';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get signUpToGetStarted => 'Regístrate para comenzar';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get nickname => 'Apodo (Opcional)';

  @override
  String get forgotPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get pleaseEnterEmail => 'Por favor ingresa tu correo electrónico';

  @override
  String get pleaseEnterValidEmail =>
      'Por favor ingresa un correo electrónico válido';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String loginFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String registrationFailed(String error) {
    return 'Error en el registro: $error';
  }

  @override
  String get registrationSuccessful =>
      '¡Registro exitoso! Por favor inicia sesión.';

  @override
  String get agreeToTerms =>
      'Por favor acepta los Términos y Política de Privacidad';

  @override
  String get iAgreeToThe => 'Acepto ';

  @override
  String get userAgreement => 'Acuerdo de Usuario';

  @override
  String get and => ' y ';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get privacyAgreement => 'Acuerdo de Privacidad';

  @override
  String get whenYouLogin =>
      'Al iniciar sesión, asumiremos que has leído y aceptado\n';

  @override
  String get loginViaApple => 'Iniciar sesión con Apple';

  @override
  String get loginViaGoogle => 'Iniciar sesión con Google';

  @override
  String get loginViaEmail => 'Iniciar sesión con Correo';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta? ';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get svipMembership => 'MEMBRESÍA SVIP';

  @override
  String get readAllNovels =>
      'Lee todas las novelas del sitio sin restricciones';

  @override
  String get subscribeNow => 'Suscribirse ahora';

  @override
  String get readingHistory => 'Historial de lectura';

  @override
  String get transactionRecord => 'Registro de Transacciones';

  @override
  String get setting => 'Configuración';

  @override
  String get myBookshelf => 'Mi estantería';

  @override
  String get edit => 'Editar';

  @override
  String get cancel => 'cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteBooks => 'Eliminar Libros';

  @override
  String deleteBooksConfirm(int count) {
    return '¿Eliminar $count libro(s) de tu estantería?';
  }

  @override
  String get booksRemoved => 'Libros eliminados de la estantería';

  @override
  String errorRemovingBooks(String error) {
    return 'Error al eliminar libros: $error';
  }

  @override
  String get noBooksInBookshelf => 'No hay libros en tu estantería';

  @override
  String get browseBooks => 'Explorar libros';

  @override
  String get description => 'Descripción';

  @override
  String get reads => 'Lecturas';

  @override
  String get addToBookshelf => 'Agregar a Estantería';

  @override
  String get readNow => 'Leer Ahora';

  @override
  String get continueReading => 'Continuar Leyendo';

  @override
  String get clearAll => 'Limpiar Todo';

  @override
  String get clearHistoryConfirm =>
      '¿Estás seguro de que deseas borrar todo el historial de lectura?';

  @override
  String get historyClearedSuccess =>
      'Historial de lectura borrado exitosamente';

  @override
  String errorClearingHistory(String error) {
    return 'Error al borrar historial: $error';
  }

  @override
  String get noReadingHistory => 'Aún no hay historial de lectura';

  @override
  String get startReadingBooks =>
      'Comienza a leer algunos libros para ver tu historial aquí';

  @override
  String errorLoadingHistory(String error) {
    return 'Error al cargar historial: $error';
  }

  @override
  String get justNow => 'Justo ahora';

  @override
  String minutesAgo(int minutes) {
    return 'hace $minutes minutos';
  }

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String todayAt(String time) {
    return 'Hoy $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer $time';
  }

  @override
  String get pleaseLoginToView =>
      'Por favor inicia sesión para ver los registros de transacciones';

  @override
  String get noTransactionRecords => 'Aún no hay registros de transacciones';

  @override
  String get noTransactionHint => 'Tus compras de suscripción aparecerán aquí';

  @override
  String errorLoadingOrders(String error) {
    return 'Error al cargar pedidos: $error';
  }

  @override
  String get loadMore => 'Cargar Más';

  @override
  String get noMoreOrders => 'No hay más pedidos';

  @override
  String get pending => 'Pendiente';

  @override
  String get paid => 'Pagado';

  @override
  String get refunded => 'Reembolsado';

  @override
  String get failedToLoadSubscriptions => 'Error al cargar suscripciones';

  @override
  String get subscribeToSVIP => 'Suscribirse a SVIP';

  @override
  String get unlockAllContent => 'Desbloquear todo el contenido';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get quarterlyPlan => 'Plan Trimestral';

  @override
  String get yearlyPlan => 'Plan Anual';

  @override
  String get perMonth => '/mes';

  @override
  String save(String percent) {
    return 'Ahorra $percent%';
  }

  @override
  String totalPrice(String price) {
    return 'Total: \$$price';
  }

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get usePasscode => 'Usar Código';

  @override
  String get enterPasscode => 'Ingresar Código';

  @override
  String get passcodeHint => 'Ingresa tu código de 16 dígitos';

  @override
  String get apply => 'Aplicar';

  @override
  String get invalidPasscode =>
      'Formato de código inválido. Por favor ingresa un código de 16 dígitos.';

  @override
  String successfullySubscribed(String productName) {
    return '¡Suscrito exitosamente a $productName!';
  }

  @override
  String subscriptionFailed(String error) {
    return 'Error en la suscripción: $error';
  }

  @override
  String get processing => 'Procesando...';

  @override
  String chapter(String number) {
    return 'Capítulo $number';
  }

  @override
  String get chapterLocked => 'Este capítulo está bloqueado';

  @override
  String get unlockWithSVIP => 'Suscríbete a SVIP para desbloquear';

  @override
  String get chapterLoadError => 'Error al cargar capítulo';

  @override
  String get loading => 'Cargando...';

  @override
  String get novelMaster => 'Novel Next';
}
