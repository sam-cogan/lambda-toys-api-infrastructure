@export()
type subnets = {
  name: string
  addressPrefix: string
}

@export()
type vnetSettings = {
  addressPrefixes: string[]
  subnets: subnets[]
}
