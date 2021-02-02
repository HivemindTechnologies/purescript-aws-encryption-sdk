module AWS.Crypto.CryptoSpec where

import AWS.Crypto.Crypto (Arn(..), EncryptionResult, decrypt, encrypt, makeClient, makeKeyring)
import Effect.Class (liftEffect)
import Prelude (Unit, bind, ($))
import Test.Spec (Spec, describe, pending')
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "AWS.Crypto" do
    describe "decrypt/encrypt" do
      pending' "should roundtrip encrypt/decrypt data" do
        client <- liftEffect makeClient
        keyring <-
          liftEffect
            $ makeKeyring
                (Arn "arn:aws:kms:us-west-2:658956600833:key/b3537ef1-d8dc-4780-9f5a-55776cbb2f7f")
                []
        let
          testData = "some-data"
        encrypted :: EncryptionResult <- encrypt client keyring {} testData
        decrypted <- decrypt client keyring (encrypted.ciphertext)
        decrypted.plaintext `shouldEqual` testData
