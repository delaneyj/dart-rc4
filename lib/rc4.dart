library rc4;

import "package:range/range.dart";
import 'package:crypto/crypto.dart';

class RC4 {
  int i = 0, j = 0;

  List<int> ksa;

  RC4(String key, [int dropBytes = 768]) {
    if (dropBytes % 256 != 0) {
      throw new Exception("Drop Bytes must be multiple of 256, was <$dropBytes>.");
    }
    ksa = _makeKey(key, dropBytes);
  }

  List<int> _encryptByte(int i, int j, List<int> S) {
    i = (i + 1) % 256;
    j = (j + S[i]) % 256;
    _swap(S, i, j);
    int K = S[(S[i] + S[j]) % 256];
    if(K >= 256)
    {
      print("oh noes!");
    }
    return [i, j, K];
  }

  _swap(List<int> S, int i, int j) {
    var tmp = S[i];
    S[i] = S[j];
    S[j] = tmp;
  }

  List<int> _makeKey(String key, int dropBytes) {
    //The key-scheduling algorithm (KSA)
    List<int> S = range(256).map((i) => i);
    j = 0;
    for (int i in range(256)) {
      var asciiCode = key.codeUnitAt(i % key.length);
      j = (j + S[i] + asciiCode) % 256;
      _swap(S, i, j);
    }
    i = j = 0;

    //Do the RC4-drop[(nbytes)]
    if (dropBytes > 0) {
      for (int dropped in range(dropBytes)) {
        var results = _encryptByte(i, j, S);
        i = results[0];
        j = results[1];
      }
    }
    return S;
  }

  String _crypt(String message) {
    //The pseudo-random generation algorithm (PRGA)
    List<int> S = []
      ..addAll(ksa); //make a deep copy of you KSA array, gets modified
    List<int> combined = [];
    int counter = 0;
    int i = this.i;
    int j = this.j;
    int messageLength = message.length;
    for (int c = 0; c < messageLength; c++) {
      var results = _encryptByte(i, j, S);
      i = results[0];
      j = results[1];
      int K = results[2];

      int asciiCode, index;
      try{
        asciiCode = message.codeUnitAt(c);
        index = K ^ asciiCode;
      combined.add(index);
      }
      catch(RangeError){
        print(message);
        throw new Exception("Crap");
      }
    }
    String crypted = new String.fromCharCodes(combined);
    return crypted;
  }

  String encode(String message, [bool encodeBase64 = true]) {
    String crypted = _crypt(message);
    if (encodeBase64) {
      List<int> asciiCodes = crypted.codeUnits;
      String base64 = CryptoUtils.bytesToBase64(asciiCodes, urlSafe:true);
      crypted = base64;
    }
    return crypted;
  }

  String decode(String message, [bool encodedBase64 = true]) {
    if (encodedBase64) {
      List<int> bytes = CryptoUtils.base64StringToBytes(message);
      message = new String.fromCharCodes(bytes);
    }

    String decrypted = _crypt(message);
    return decrypted;
  }
}