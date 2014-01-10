## Intro ##
[RC4 symmetric (drop frame)](http://en.wikipedia.org/wiki/RC4) implementation base on previous work for BitFlip Games.  Used when you need a simple but de/encryption that doesn't need the rigors of [public key encryption](http://en.wikipedia.org/wiki/Public-key_cryptography).

## Sample ##
    const String key = "This is a test";
    const String message = "Attack at dawn!";

    RC4 rc4 = new RC4(key);
    var encrypted = rc4.encode(message);
    var decrypted = rc4.decode(encrypted);

    print("Encrypted: $encrypted");
    print("Decrypted is same as message: ${decrypted == message}");
