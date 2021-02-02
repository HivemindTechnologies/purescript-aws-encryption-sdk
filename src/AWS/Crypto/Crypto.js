"use strict"

const crypto = require("@aws-crypto/client-node")

exports.makeClient = () => crypto.buildClient(
  crypto.CommitmentPolicy.REQUIRE_ENCRYPT_REQUIRE_DECRYPT
)

exports.makeKeyringImpl = (generatorKeyId, keyIds) => () => new crypto.KmsKeyringNode({ generatorKeyId, keyIds })

exports.encryptImpl = (client, keyring, context, plaintext) => () => client.encrypt(keyring, plaintext, {
  encryptionContext: context,
})

exports.decryptImpl = (client, keyring, ciphertext) => () => client.decrypt(keyring, ciphertext)