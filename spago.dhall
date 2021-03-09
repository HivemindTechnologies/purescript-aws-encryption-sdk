{ name = "aws-encryption-sdk"
, dependencies =
  [ "aff-promise"
  , "console"
  , "debug"
  , "effect"
  , "node-buffer"
  , "psci-support"
  , "spec"
  , "spec-discovery"
  ]
, packages = ./packages.dhall
, license = "Apache-2.0"
, repository = "https://github.com/HivemindTechnologies/purescript-aws-encryption-sdk.git"
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
