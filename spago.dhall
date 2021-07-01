{ name = "aws-encryption-sdk"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "effect"
  , "functions"
  , "newtype"
  , "node-buffer"
  , "prelude"
  , "psci-support"
  , "spec"
  , "spec-discovery"
  ]
, packages = ./packages.dhall
, license = "Apache-2.0"
, repository =
    "https://github.com/HivemindTechnologies/purescript-aws-encryption-sdk.git"
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
