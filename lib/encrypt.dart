import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_application_1/encrypt.dart';
import 'package:flutter_application_1/Picture.dart';
import 'package:flutter_application_1/flags.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_application_1/bloc/repository.dart';

Future<Res> fetchKey(String randomString, List<int> hkdfNonce) async {
  final x25519 = X25519();

  Variables.clientKeyPair = await x25519.newKeyPair();
  final clientPublicKey = await Variables.clientKeyPair.extractPublicKey();
  Variables.clientPublicKeyBase64 = base64.encode(clientPublicKey.bytes);

  final response = await http.post(
    Uri.parse('http://localhost:5000/key'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'owner_id': randomString,
      'clientPublicKeyBase64': Variables.clientPublicKeyBase64,
      'hkdfNonce': base64Encode(hkdfNonce),
    }),
  );

  if (response.statusCode == 200) {
    return Res.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load Server Response');
  }
}

List<int> m = [12, 13, 14, 15];
final controller = StreamController<List<int>>();

Future encrypt({
  required List<int> stream,
  required String serverPubKeyString,
  required List<int> hkdfNonce,
  required SimpleKeyPair clientKeyPair,
}) async {
  final aes = AesGcm.with256bits();
  final x25519 = X25519();

  // 2️⃣ Decode server public key
  final serverPubKeyBytes = base64Decode(serverPubKeyString);
  final serverPublicKey = SimplePublicKey(
    serverPubKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3️⃣ Compute shared secret
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: clientKeyPair,
    remotePublicKey: serverPublicKey,
  );

  // 4️⃣ Derive key for sign the Client AES
  final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  final key = await hkdf.deriveKey(secretKey: sharedSecret, nonce: hkdfNonce);

  // 5️⃣ Encrypt
  // Mac? mac;
  final aesNonce = aes.newNonce();
  final secretBox = await aes.encrypt(stream, secretKey: key, nonce: aesNonce);

  final body = {
    // "client_pub": base64Encode(clientPublicKey.bytes),
    // 'shared-secret': base64Encode(await sharedSecret.extractBytes()),
    "hkdfNonce": base64Encode(hkdfNonce),
    "aes": base64Encode(key.bytes),
    "aesNonce": base64Encode(aesNonce),
    "ciphertext": base64Encode(secretBox.cipherText),
    "mac": base64Encode(secretBox.mac.bytes),
  };
  print(body);
  return body;
}

/// Sends a stream of bytes to the server using StreamedRequest
Future postdata(Map<String, dynamic> body) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({...body, 'owner_id': Variables.randomString}),
  );

  if (response.statusCode == 200) {
    print("ok");
  } else {
    throw Exception('Failed to load Server Response');
  }
}
