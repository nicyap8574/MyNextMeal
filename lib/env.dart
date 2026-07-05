import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'HF_API_KEY', obfuscate: true)
  static final String hf_apiKey = _Env.hf_apiKey;
}