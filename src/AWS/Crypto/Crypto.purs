module AWS.Crypto.Crypto where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Data.Newtype (class Newtype, un)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import data KmsKeyring :: Type 

newtype Arn = Arn String 
derive instance ntArn :: Newtype Arn _


foreign import makeKeyringImpl :: Fn2 String (Array String) (Effect KmsKeyring)

makeKeyring :: Arn -> Array Arn -> Effect KmsKeyring
makeKeyring (Arn generatorKeyId) keyIds = runFn2 makeKeyringImpl generatorKeyId $ map (un Arn) keyIds 


type InternalEncryptionResult = { result :: String }

foreign import encryptImpl :: forall a. Fn3 KmsKeyring String a (Effect (Promise InternalEncryptionResult))

type EncryptionResult = { ciphertext :: String }

encrypt :: forall a. KmsKeyring -> String -> a -> Aff EncryptionResult 
encrypt keyring plaintext context = runFn3 encryptImpl keyring plaintext context # toAffE <#> 
    \ir -> { ciphertext : ir.result } 


type InternalDecryptionResult a = { plaintext :: String, messageHeader :: { encryptionContext :: a }  }

foreign import decryptImpl :: forall a. Fn2 KmsKeyring String (Effect (Promise (InternalDecryptionResult a)))

type DecryptionResult a = { plaintext :: String, encryptionContext :: a }

decrypt :: forall a. KmsKeyring -> String -> Aff (DecryptionResult a) 
decrypt keyring ciphertext = runFn2 decryptImpl keyring ciphertext # toAffE <#> 
    \ir -> { plaintext : ir.plaintext, encryptionContext : ir.messageHeader.encryptionContext }
