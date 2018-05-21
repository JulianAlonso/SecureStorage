# SECURE STORAGE

Secure storage its a protocol and swift implementation to abstract of swift keychain, storing objects that implements SecureStorable (Protocol over Codable).


## Simply usage.
You only need to call `set` with the value to store and a key.
To get an object you need to call `get` with the key. Thanks to swift infering types, your object will be the type object that you has stored before.

If you want to clear the keychain you must call `clear()` function.

## LICENSE
See license file

## AUTHOR
Julian Alonso (Secure storage access extracted from other library. I don't remember wich 😔)
