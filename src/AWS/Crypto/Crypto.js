"use strict"

const crypto = require("@aws-crypto/client-node")

exports.makeKeyringImpl = (generatorKeyId, keyIds) => () => new crypto.KmsKeyringNode({ generatorKeyId, keyIds })

exports.encryptImpl = (keyring, cleartext, context) => () => crypto.encrypt(keyring, cleartext, {
    encryptionContext: context,
  })

exports.decryptImpl = (keyring, ciphertext) => decrypt(keyring, result)