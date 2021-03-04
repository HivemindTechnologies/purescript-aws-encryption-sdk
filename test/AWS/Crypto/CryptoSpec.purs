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
                (Arn "arn:aws:kms:<<REGION>>:<<ACCOUNT>>:key/<<KEY_ID>>")
                []
        let
          testData = "some-data"
        encrypted :: EncryptionResult <- encrypt client keyring {} testData
        decrypted <- decrypt client keyring (encrypted.ciphertext)
        decrypted.plaintext `shouldEqual` testData
