module AWS.Crypto.CryptoSpec where

import AWS.Crypto.Crypto (Arn(..), KeyProvider(..), EncryptionResult, decrypt, encrypt, makeClient, makeKeyring, makeCache, getCachingManager)
import Effect.Class (liftEffect)
import Prelude (Unit, bind, discard, ($), (*))
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
        let
          testData = "some-data"
        encrypted :: EncryptionResult <- encrypt client (Keyring keyring) {} testData
        decrypted <- decrypt client (Keyring keyring) (encrypted.ciphertext)
        decrypted.plaintext `shouldEqual` testData

      pending' "should roundtrip encrypt/decrypt data with cache" do
        client <- liftEffect makeClient
        keyring <-
          liftEffect
            $ makeKeyring
                (Arn "arn:aws:kms:<<REGION>>:<<ACCOUNT>>:key/<<KEY_ID>>")
        cache <- liftEffect $ makeCache 100
        cacheManager <- liftEffect $ getCachingManager keyring cache (60*1000)
        let
          testData = "some-data"
        encrypted :: EncryptionResult <- encrypt client (CacheManager cacheManager) {} testData
        decrypted <- decrypt client (CacheManager cacheManager) (encrypted.ciphertext)
        decrypted.plaintext `shouldEqual` testData
