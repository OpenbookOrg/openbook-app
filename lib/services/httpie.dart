import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http_retry/http_retry.dart';
export 'package:http/http.dart';

class HttpieService {
  late LocalizationService _localizationService;
  late UtilsService _utilsService;
  String? authorizationToken;
  String? magicHeaderName;
  String? magicHeaderValue;
  late Client client;

  HttpieService() {
    client = IOClient();
    client = RetryClient(client,
        when: _retryWhenResponse, whenError: _retryWhenError);
  }

  bool _retryWhenResponse(BaseResponse response) {
    return response.statusCode >= 503 && response.statusCode < 600;
  }

  bool _retryWhenError(error, StackTrace stackTrace) {
    return error is SocketException || error is ClientException;
  }

  void setAuthorizationToken(String token) {
    authorizationToken = token;
  }

  String? getAuthorizationToken() {
    return authorizationToken;
  }

  void removeAuthorizationToken() {
    authorizationToken = null;
  }

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setUtilsService(UtilsService utilsService) {
    _utilsService = utilsService;
  }

  void setMagicHeader(String name, String value) {
    magicHeaderName = name;
    magicHeaderValue = value;
  }

  void setProxy(String proxy) {
    var overrides = HttpOverrides.current as HttpieOverrides?;
    if (overrides != null) {
      overrides.setProxy(proxy);
    }
  }

  Future<HttpieResponse> post(url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var finalHeaders = _getHeadersWithConfig(
        headers: headers,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    Response? response;

    try {
      response = await client.post(Uri.parse(url),
          headers: finalHeaders, body: body, encoding: encoding);
    } catch (error) {
      _handleRequestError(error);
    }

    return HttpieResponse(response);
  }

  Future<HttpieResponse> put(url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var finalHeaders = _getHeadersWithConfig(
        headers: headers,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    Response? response;

    try {
      response = await client.put(Uri.parse(url),
          headers: finalHeaders, body: body, encoding: encoding);
    } catch (error) {
      _handleRequestError(error);
    }
    return HttpieResponse(response);
  }

  Future<HttpieResponse> patch(url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var finalHeaders = _getHeadersWithConfig(
        headers: headers,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    Response? response;

    try {
      response = await client.patch(Uri.parse(url),
          headers: finalHeaders, body: body, encoding: encoding);
    } catch (error) {
      _handleRequestError(error);
    }

    return HttpieResponse(response);
  }

  Future<HttpieResponse> delete(url,
      {Map<String, String>? headers,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var finalHeaders = _getHeadersWithConfig(
        headers: headers,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    Response? response;

    try {
      response = await client.delete(Uri.parse(url), headers: finalHeaders);
    } catch (error) {
      _handleRequestError(error);
    }

    return HttpieResponse(response);
  }

  Future<HttpieResponse> postJSON(url,
      {Map<String, String> headers = const {},
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    String jsonBody = json.encode(body);

    Map<String, String> jsonHeaders = _getJsonHeaders();

    jsonHeaders.addAll(headers);

    return post(url,
        headers: jsonHeaders,
        body: jsonBody,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieResponse> putJSON(url,
      {Map<String, String> headers = const {},
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    String jsonBody = json.encode(body);

    Map<String, String> jsonHeaders = _getJsonHeaders();

    jsonHeaders.addAll(headers);

    return put(url,
        headers: jsonHeaders,
        body: jsonBody,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieResponse> patchJSON(url,
      {Map<String, String> headers = const {},
      body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    String jsonBody = json.encode(body);

    Map<String, String> jsonHeaders = _getJsonHeaders();

    jsonHeaders.addAll(headers);

    return patch(url,
        headers: jsonHeaders,
        body: jsonBody,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieResponse> get(url,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var finalHeaders = _getHeadersWithConfig(
        headers: headers,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    if (queryParameters != null && queryParameters.keys.length > 0) {
      url = url + _makeQueryString(queryParameters);
    }

    Response? response;

    try {
      response = await client.get(Uri.parse(url), headers: finalHeaders);
    } catch (error) {
      _handleRequestError(error);
    }

    return HttpieResponse(response);
  }

  Future<HttpieStreamedResponse> postMultiform(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    return _multipartRequest(url,
        method: 'POST',
        headers: headers,
        body: body,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieStreamedResponse> patchMultiform(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    return _multipartRequest(url,
        method: 'PATCH',
        headers: headers,
        body: body,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieStreamedResponse> putMultiform(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    return _multipartRequest(url,
        method: 'PUT',
        headers: headers,
        body: body,
        encoding: encoding,
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);
  }

  Future<HttpieStreamedResponse> _multipartRequest(String url,
      {Map<String, String>? headers,
      required String method,
      Map<String, dynamic>? body,
      Encoding? encoding,
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) async {
    var request = new http.MultipartRequest(method, Uri.parse(url));

    var finalHeaders = _getHeadersWithConfig(
        headers: headers ?? {},
        appendLanguageHeader: appendLanguageHeader,
        appendAuthorizationToken: appendAuthorizationToken);

    request.headers.addAll(finalHeaders);

    List<Future> fileFields = [];

    List<String>? bodyKeys = body?.keys.toList();

    if (bodyKeys != null) {
      for (final String key in bodyKeys) {
        dynamic value = body![key];
        if (value is String || value is bool) {
          request.fields[key] = value.toString();
        } else if (value is List) {
          request.fields[key] =
              value.map((item) => item.toString()).toList().join(',');
        } else if (value is File) {
          String fileMimeType = await _utilsService.getFileMimeType(value);

          String? fileExtension =
              _utilsService.getFileExtensionForMimeType(fileMimeType);

          var bytes = utf8.encode(value.path);
          var digest = sha256.convert(bytes);

          String newFileName = fileExtension == null
            ? digest.toString()
            : digest.toString() + '.' + fileExtension;

          MediaType fileMediaType = MediaType.parse(fileMimeType);

          var fileFuture = http.MultipartFile.fromPath(key, value.path,
              filename: newFileName, contentType: fileMediaType);

          fileFields.add(fileFuture);
        } else {
          throw HttpieArgumentsError('Unsupported multiform value type');
        }
      }
    }

    var files = await Future.wait(fileFields);
    files.forEach((file) => request.files.add(file));

    var response;

    try {
      response = await client.send(request);
    } catch (error) {
      _handleRequestError(error);
    }

    return HttpieStreamedResponse(response);
  }

  String _getLanguage() {
    return _localizationService.getLocale().languageCode.toLowerCase();
  }

  Map<String, String> _getHeadersWithConfig(
      {Map<String, String>? headers = const {},
      bool? appendLanguageHeader,
      bool? appendAuthorizationToken}) {
    headers = headers ?? {};

    Map<String, String> finalHeaders = Map.from(headers);

    appendLanguageHeader = appendLanguageHeader ?? true;
    appendAuthorizationToken = appendAuthorizationToken ?? false;

    if (appendLanguageHeader) finalHeaders['Accept-Language'] = _getLanguage();

    if (appendAuthorizationToken && authorizationToken != null) {
      finalHeaders['Authorization'] = 'Token $authorizationToken';
    }

    if (magicHeaderName != null && magicHeaderValue != null) {
      finalHeaders[magicHeaderName!] = magicHeaderValue!;
    }

    return finalHeaders;
  }

  void _handleRequestError(error) {
    if (error is SocketException) {
      var errorCode = error.osError?.errorCode;
      if (errorCode == 61 ||
          errorCode == 60 ||
          errorCode == 111 ||
          // Network is unreachable
          errorCode == 101 ||
          errorCode == 104 ||
          errorCode == 51 ||
          errorCode == 8 ||
          errorCode == 113 ||
          errorCode == 7 ||
          errorCode == 64) {
        // Connection refused.
        throw HttpieConnectionRefusedError(error);
      }
    }

    throw error;
  }

  Map<String, String> _getJsonHeaders() {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
  }

  String _makeQueryString(Map<String, dynamic> queryParameters) {
    String queryString = '?';
    queryParameters.forEach((key, value) {
      if (value != null) {
        queryString += '$key=' + _stringifyQueryStringValue(value) + '&';
      }
    });
    return queryString;
  }

  String _stringifyQueryStringValue(dynamic value) {
    if (value is String) return value;
    if (value is bool || value is int || value is double)
      return value.toString();
    if (value is List)
      return value
          .map((valueItem) => _stringifyQueryStringValue(valueItem))
          .join(',');
    throw 'Unsupported query string value';
  }
}

abstract class HttpieBaseResponse<T extends http.BaseResponse> {
  T _httpResponse;

  HttpieBaseResponse(this._httpResponse);

  bool isInternalServerError() {
    return _httpResponse.statusCode == HttpStatus.internalServerError;
  }

  bool isBadRequest() {
    return _httpResponse.statusCode == HttpStatus.badRequest;
  }

  bool isOk() {
    return _httpResponse.statusCode == HttpStatus.ok;
  }

  bool isUnauthorized() {
    return _httpResponse.statusCode == HttpStatus.unauthorized;
  }

  bool isForbidden() {
    return _httpResponse.statusCode == HttpStatus.forbidden;
  }

  bool isAccepted() {
    return _httpResponse.statusCode == HttpStatus.accepted;
  }

  bool isCreated() {
    return _httpResponse.statusCode == HttpStatus.created;
  }

  bool isNotFound() {
    return _httpResponse.statusCode == HttpStatus.notFound;
  }

  int get statusCode => _httpResponse.statusCode;
}

class HttpieResponse extends HttpieBaseResponse<http.Response> {
  HttpieResponse(_httpResponse) : super(_httpResponse);

  String get body {
    return utf8.decode(_httpResponse.bodyBytes);
  }

  Map<String, dynamic> parseJsonBody() {
    return json.decode(body);
  }

  http.Response get httpResponse => _httpResponse;
}

class HttpieStreamedResponse extends HttpieBaseResponse<http.StreamedResponse> {
  HttpieStreamedResponse(_httpResponse) : super(_httpResponse);

  Future<String> readAsString() {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    this._httpResponse.stream.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () {
      completer.complete(contents.toString());
    });
    return completer.future;
  }
}

class HttpieRequestError<T extends HttpieBaseResponse> implements Exception {
  static String convertStatusCodeToHumanReadableMessage(int statusCode) {
    String readableMessage;

    if (statusCode == HttpStatus.notFound) {
      readableMessage = 'Not found';
    } else if (statusCode == HttpStatus.forbidden) {
      readableMessage = 'You are not allowed to do this';
    } else if (statusCode == HttpStatus.badRequest) {
      readableMessage = 'Bad request';
    } else if (statusCode == HttpStatus.internalServerError) {
      readableMessage =
          'We\'re experiencing server errors. Please try again later.';
    } else if (statusCode == HttpStatus.serviceUnavailable ||
        statusCode == HttpStatus.serviceUnavailable) {
      readableMessage =
          'We\'re experiencing server errors. Please try again later.';
    } else {
      readableMessage = 'Server error';
    }

    return readableMessage;
  }

  final T response;

  const HttpieRequestError(this.response);

  String toString() {
    String statusCode = response.statusCode.toString();
    String stringifiedError = 'HttpieRequestError:$statusCode';

    if (response is HttpieResponse) {
      var castedResponse = this.response as HttpieResponse;
      stringifiedError = stringifiedError + ' | ' + castedResponse.body;
    }

    return stringifiedError;
  }

  Future<String> body() async {
    late String body;

    if (response is HttpieResponse) {
      HttpieResponse castedResponse = this.response as HttpieResponse;
      body = castedResponse.body;
    } else if (response is HttpieStreamedResponse) {
      HttpieStreamedResponse castedResponse =
          this.response as HttpieStreamedResponse;
      body = await castedResponse.readAsString();
    }
    return body;
  }

  Future<String?> toHumanReadableMessage() async {
    String errorBody = await body();

    try {
      dynamic parsedError = json.decode(errorBody);
      if (parsedError is Map) {
        if (parsedError.isNotEmpty) {
          if (parsedError.containsKey('detail')) {
            return parsedError['detail'];
          } else if (parsedError.containsKey('message')) {
            return parsedError['message'];
          } else {
            dynamic mapFirstValue = parsedError.values.toList().first;
            dynamic value = mapFirstValue is List ? mapFirstValue[0] : null;
            if (value != null && value is String) {
              return value;
            } else {
              return convertStatusCodeToHumanReadableMessage(
                  response.statusCode);
            }
          }
        } else {
          return convertStatusCodeToHumanReadableMessage(response.statusCode);
        }
      } else if (parsedError is List && parsedError.isNotEmpty) {
        return parsedError.first;
      }

      return null;
    } catch (error) {
      return convertStatusCodeToHumanReadableMessage(response.statusCode);
    }
  }
}

class HttpieConnectionRefusedError implements Exception {
  final SocketException socketException;

  const HttpieConnectionRefusedError(this.socketException);

  String toString() {
    String address = socketException.address.toString();
    String port = socketException.port.toString();
    return 'HttpieConnectionRefusedError: Connection refused on $address and port $port';
  }

  String toHumanReadableMessage() {
    return 'No internet connection.';
  }
}

class HttpieArgumentsError implements Exception {
  final String msg;

  const HttpieArgumentsError(this.msg);

  String toString() => 'HttpieArgumentsError: $msg';
}

// These overrides are used by the standard dart:http/HttpClient to change how
// it behaves. All settings changed here will apply to every single HttpClient
// used by any other package, as long as they're running inside a zone with
// these set.
class HttpieOverrides extends HttpOverrides {
  String? _proxy;
  final HttpOverrides? _previous = HttpOverrides.current;

  HttpieOverrides();

  void setProxy(String proxy) {
    _proxy = proxy;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    if (_previous != null) return _previous!.createHttpClient(context);
    return super.createHttpClient(context);
  }

  @override
  String findProxyFromEnvironment(Uri uri, Map<String, String>? environment) {
    if (_proxy != null) return _proxy!;
    if (_previous != null) return _previous!.findProxyFromEnvironment(uri, environment);
    return super.findProxyFromEnvironment(uri, environment);
  }
}
