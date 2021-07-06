import 'dart:convert';
import 'dart:io';

void main() {
  final i18nPath = File('${Directory.current.path}/assets/i18n');
  final contents =
      File('${i18nPath.path}/intl_messages.arb').readAsStringSync();
  final Map<String, dynamic> json = jsonDecode(contents);

  var translationStrings = <String, Map>{};
  var mainKeys = <String>[];

  json.keys.forEach((key) {
    var mainKey = key.split('__')[0];
    var translationKey = key.split('__').sublist(1).join('__');

    if (!translationStrings.containsKey(mainKey)) {
      translationStrings[mainKey] = {};
    }

    translationStrings[mainKey]![translationKey] = json[key];

    if (!mainKey.startsWith('@') && !mainKeys.contains(mainKey)) {
      mainKeys.add(mainKey);
    }
  });

  const jsonEncoder = JsonEncoder.withIndent('  ');
  mainKeys.forEach((mainKey) {
    var output = {};
    var current = translationStrings[mainKey];

    current?.keys.forEach((key) {
      output[key] = current[key];
      output['@$key'] = translationStrings['@$mainKey']![key];
    });

    var str = jsonEncoder.convert(output);
    File('${i18nPath.path}/en/$mainKey.arb').writeAsStringSync(str);
    print('Generated $mainKey.arb.');
  });

  print('Done!');
}
