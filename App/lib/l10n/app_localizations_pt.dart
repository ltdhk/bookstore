// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Livraria';

  @override
  String get home => 'Início';

  @override
  String get bookshelf => 'Estante';

  @override
  String get profile => 'Meu';

  @override
  String get hot => 'Popular';

  @override
  String get newTab => 'Novo';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Feminino';

  @override
  String get searchHint => 'Buscar romance';

  @override
  String get settings => 'Configurações';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get alwaysLightMode => 'Sempre Modo Claro';

  @override
  String get autoUnlockChapter => 'Desbloquear capítulo automaticamente';

  @override
  String get language => 'Idioma';

  @override
  String get versionUpdate => 'Atualização de Versão';

  @override
  String get about => 'Sobre Novel Pop';

  @override
  String get rate => 'Avaliar Novel Pop';

  @override
  String get followSystem => 'Seguir Sistema';

  @override
  String get alwaysDark => 'Sempre Modo Escuro';

  @override
  String get alwaysLight => 'Sempre Modo Claro';

  @override
  String get svipMember => 'SVIP';

  @override
  String get regularMember => 'Membro';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get register => 'Registrar';

  @override
  String get welcomeBack => 'Bem-vindo de Volta';

  @override
  String get loginToYourAccount => 'Entre na sua conta';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get signUpToGetStarted => 'Inscreva-se para começar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get nickname => 'Apelido (Opcional)';

  @override
  String get forgotPassword => 'Esqueceu a Senha?';

  @override
  String get pleaseEnterEmail => 'Por favor, insira seu e-mail';

  @override
  String get pleaseEnterValidEmail => 'Por favor, insira um e-mail válido';

  @override
  String get pleaseEnterPassword => 'Por favor, insira sua senha';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get pleaseConfirmPassword => 'Por favor, confirme sua senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String loginFailed(String error) {
    return 'Falha no login: $error';
  }

  @override
  String registrationFailed(String error) {
    return 'Falha no registro: $error';
  }

  @override
  String get registrationSuccessful =>
      'Registro bem-sucedido! Por favor, faça login.';

  @override
  String get agreeToTerms =>
      'Por favor, concorde com os Termos e Política de Privacidade';

  @override
  String get iAgreeToThe => 'Eu concordo com ';

  @override
  String get userAgreement => 'Acordo do Usuário';

  @override
  String get and => ' e ';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get privacyAgreement => 'Acordo de Privacidade';

  @override
  String get whenYouLogin =>
      'Ao fazer login, presumiremos que você leu e concordou com\n';

  @override
  String get loginViaApple => 'Entrar via Apple';

  @override
  String get loginViaGoogle => 'Entrar via Google';

  @override
  String get loginViaEmail => 'Entrar via E-mail';

  @override
  String get dontHaveAccount => 'Não tem uma conta? ';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get svipMembership => 'ASSINATURA SVIP';

  @override
  String get readAllNovels => 'Leia todos os romances do site sem restrições';

  @override
  String get subscribeNow => 'Assine agora';

  @override
  String get readingHistory => 'Histórico de leitura';

  @override
  String get transactionRecord => 'Registro de Transações';

  @override
  String get setting => 'Configurações';

  @override
  String get myBookshelf => 'Minha estante';

  @override
  String get edit => 'Editar';

  @override
  String get cancel => 'cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteBooks => 'Excluir Livros';

  @override
  String deleteBooksConfirm(int count) {
    return 'Excluir $count livro(s) da sua estante?';
  }

  @override
  String get booksRemoved => 'Livros removidos da estante';

  @override
  String errorRemovingBooks(String error) {
    return 'Erro ao remover livros: $error';
  }

  @override
  String get noBooksInBookshelf => 'Nenhum livro na sua estante';

  @override
  String get browseBooks => 'Navegar livros';

  @override
  String get description => 'Descrição';

  @override
  String get reads => 'Leituras';

  @override
  String get addToBookshelf => 'Adicionar à Estante';

  @override
  String get readNow => 'Ler Agora';

  @override
  String get continueReading => 'Continuar Lendo';

  @override
  String get clearAll => 'Limpar Tudo';

  @override
  String get clearHistoryConfirm =>
      'Tem certeza de que deseja limpar todo o histórico de leitura?';

  @override
  String get historyClearedSuccess => 'Histórico de leitura limpo com sucesso';

  @override
  String errorClearingHistory(String error) {
    return 'Erro ao limpar histórico: $error';
  }

  @override
  String get noReadingHistory => 'Ainda não há histórico de leitura';

  @override
  String get startReadingBooks =>
      'Comece a ler alguns livros para ver seu histórico aqui';

  @override
  String errorLoadingHistory(String error) {
    return 'Erro ao carregar histórico: $error';
  }

  @override
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutos atrás';
  }

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String todayAt(String time) {
    return 'Hoje $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ontem $time';
  }

  @override
  String get pleaseLoginToView =>
      'Por favor, faça login para ver os registros de transações';

  @override
  String get noTransactionRecords => 'Ainda não há registros de transações';

  @override
  String get noTransactionHint => 'Suas compras de assinatura aparecerão aqui';

  @override
  String errorLoadingOrders(String error) {
    return 'Erro ao carregar pedidos: $error';
  }

  @override
  String get loadMore => 'Carregar Mais';

  @override
  String get noMoreOrders => 'Não há mais pedidos';

  @override
  String get pending => 'Pendente';

  @override
  String get paid => 'Pago';

  @override
  String get refunded => 'Reembolsado';

  @override
  String get failedToLoadSubscriptions => 'Falha ao carregar assinaturas';

  @override
  String get subscribeToSVIP => 'Assinar SVIP';

  @override
  String get unlockAllContent => 'Desbloquear todo o conteúdo';

  @override
  String get monthlyPlan => 'Plano Mensal';

  @override
  String get quarterlyPlan => 'Plano Trimestral';

  @override
  String get yearlyPlan => 'Plano Anual';

  @override
  String get perMonth => '/mês';

  @override
  String save(String percent) {
    return 'Economize $percent%';
  }

  @override
  String totalPrice(String price) {
    return 'Total: \$$price';
  }

  @override
  String get subscribe => 'Assinar';

  @override
  String get usePasscode => 'Usar Código';

  @override
  String get enterPasscode => 'Inserir Código';

  @override
  String get passcodeHint => 'Insira seu código de 16 dígitos';

  @override
  String get apply => 'Aplicar';

  @override
  String get invalidPasscode =>
      'Formato de código inválido. Por favor, insira um código de 16 dígitos.';

  @override
  String successfullySubscribed(String productName) {
    return 'Assinado com sucesso $productName!';
  }

  @override
  String subscriptionFailed(String error) {
    return 'Falha na assinatura: $error';
  }

  @override
  String get processing => 'Processando...';

  @override
  String chapter(String number) {
    return 'Capítulo $number';
  }

  @override
  String get chapterLocked => 'Este capítulo está bloqueado';

  @override
  String get unlockWithSVIP => 'Assine SVIP para desbloquear';

  @override
  String get chapterLoadError => 'Falha ao carregar capítulo';

  @override
  String get loading => 'Carregando...';

  @override
  String get novelMaster => 'Novel Pop';

  @override
  String get expiresOn => 'Expira em';
}
