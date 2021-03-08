module AWS.Crypto.Crypto
  ( KmsKeyring
  , Arn(..)
  , Client
  , makeClient
  , makeKeyring
  , EncryptionResult
  , encrypt
  , DecryptionResult
  , decrypt
  ) where

import Prelude
import Control.Promise (Promise, toAffE)
import Data.Function.Uncurried (Fn2, Fn3, Fn4, runFn2, runFn3, runFn4)
import Data.Newtype (class Newtype, un)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Buffer (Buffer, toString, fromString)
import Node.Encoding (Encoding(..))

foreign import data KmsKeyring :: Type

newtype Arn
  = Arn String

derive instance ntArn :: Newtype Arn _

foreign import data Client :: Type

foreign import makeClient :: Effect Client

foreign import makeKeyringImpl :: Fn2 String (Array String) (Effect KmsKeyring)

makeKeyring :: Arn -> Array Arn -> Effect KmsKeyring
makeKeyring (Arn generatorKeyId) keyIds = runFn2 makeKeyringImpl generatorKeyId $ map (un Arn) keyIds

type InternalEncryptionResult
  = { result :: Buffer }

foreign import encryptImpl :: forall a. Fn4 Client KmsKeyring a String (Effect (Promise InternalEncryptionResult))

type EncryptionResult
  = { ciphertext :: String }

encrypt :: forall a. Client -> KmsKeyring -> a -> String -> Aff EncryptionResult
encrypt client keyring context plaintext = runFn4 encryptImpl client keyring context plaintext # toAffE >>= convert
  where
  convert :: InternalEncryptionResult -> Aff EncryptionResult
  convert ir = liftEffect $ toString Base64 ir.result <#> { ciphertext: _ }

type InternalDecryptionResult a
  = { plaintext :: Buffer, messageHeader :: { encryptionContext :: a } }

foreign import decryptImpl :: forall a. Fn3 Client KmsKeyring Buffer (Effect (Promise (InternalDecryptionResult a)))

type DecryptionResult a
  = { plaintext :: String, encryptionContext :: a }

decrypt :: forall a. Client -> KmsKeyring -> String -> Aff (DecryptionResult a)
decrypt client keyring ciphertext = (convertIn >>= runFn3 decryptImpl client keyring) # toAffE >>= convertOut
  where
  convertIn :: Effect Buffer
  convertIn = fromString ciphertext Base64

  convertOut :: InternalDecryptionResult a -> Aff (DecryptionResult a)
  convertOut ir = liftEffect $ toString UTF8 ir.plaintext <#> { plaintext: _, encryptionContext: ir.messageHeader.encryptionContext }
