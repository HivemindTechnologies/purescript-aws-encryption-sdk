module AWS.Crypto.Crypto
  ( KmsKeyring
  , NodeMaterialsManager
  , CryptographicMaterialsCache
  , KeyProvider(..)
  , Arn(..)
  , Client
  , makeClient
  , makeCache
  , makeKeyring
  , getCachingManager
  , EncryptionResult
  , encrypt
  , DecryptionResult
  , decrypt
  ) where

import Prelude
import Control.Promise (Promise, toAffE)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, Fn6, runFn1, runFn2, runFn3, runFn4, runFn6)
import Data.Newtype (class Newtype, un)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Buffer (Buffer, toString, fromString)
import Node.Encoding (Encoding(..))

foreign import data KmsKeyring :: Type
foreign import data NodeMaterialsManager :: Type

data KeyProvider = CacheManager NodeMaterialsManager | Keyring KmsKeyring

newtype Arn
  = Arn String

derive instance ntArn :: Newtype Arn _

foreign import data Client :: Type

foreign import makeClient :: Effect Client

foreign import makeKeyringImpl :: Fn1 String (Effect KmsKeyring)

makeKeyring :: Arn -> Effect KmsKeyring
makeKeyring (Arn generatorKeyId) = runFn1 makeKeyringImpl generatorKeyId

type InternalEncryptionResult
  = { result :: Buffer }

foreign import encryptImpl :: forall a. Fn4 Client KeyProvider a String (Effect (Promise InternalEncryptionResult))

type EncryptionResult
  = { ciphertext :: String }

encrypt :: forall a. Client -> KeyProvider -> a -> String -> Aff EncryptionResult
encrypt client keyProvider context plaintext = runFn4 encryptImpl client keyProvider context plaintext # toAffE >>= convert
  where
  convert :: InternalEncryptionResult -> Aff EncryptionResult
  convert ir = liftEffect $ toString Base64 ir.result <#> { ciphertext: _ }

type InternalDecryptionResult a
  = { plaintext :: Buffer, messageHeader :: { encryptionContext :: a } }

foreign import decryptImpl :: forall a. Fn3 Client KeyProvider Buffer (Effect (Promise (InternalDecryptionResult a)))

type DecryptionResult a
  = { plaintext :: String, encryptionContext :: a }

decrypt :: forall a. Client -> KeyProvider -> String -> Aff (DecryptionResult a)
decrypt client keyProvider ciphertext = (convertIn >>= runFn3 decryptImpl client keyProvider) # toAffE >>= convertOut
  where
  convertIn :: Effect Buffer
  convertIn = fromString ciphertext Base64

  convertOut :: InternalDecryptionResult a -> Aff (DecryptionResult a)
  convertOut ir = liftEffect $ toString UTF8 ir.plaintext <#> { plaintext: _, encryptionContext: ir.messageHeader.encryptionContext }


-- Caching
type CacheCapacity = Int
foreign import data CryptographicMaterialsCache :: Type
foreign import makeCacheImpl :: Fn1 CacheCapacity (Effect CryptographicMaterialsCache)

makeCache :: CacheCapacity -> Effect CryptographicMaterialsCache
makeCache capacity = runFn1 makeCacheImpl capacity

type Age = Int

foreign import getCachingManagerImpl :: Fn3 KmsKeyring CryptographicMaterialsCache Age (Effect NodeMaterialsManager) 

getCachingManager :: KmsKeyring -> CryptographicMaterialsCache -> Age -> Effect NodeMaterialsManager
getCachingManager keyring cache maxAge = runFn3 getCachingManagerImpl keyring cache maxAge