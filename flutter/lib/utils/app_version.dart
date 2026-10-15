/// Versão do app (tag). Passada no build via `--dart-define=APP_VERSION=...`.
/// Em builds locais sem o define, mostra "dev".
const String appVersion =
    String.fromEnvironment('APP_VERSION', defaultValue: 'dev');
