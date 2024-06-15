using '../infrastructure/main.bicep'

param location = 'westeurope'
param prefix = 'lmbd-dev01'
param containerVersion = '1.7.0'
param certKeyVaultName = 'deploymentkvsc01'
param externalResourcesRg = 'samcogancore'
param certKeyVaultUrl = 'https://deploymentkvsc01.vault.azure.net/secrets/lambdatoys'
param containerRegistryName = 'lambdatoysdev'
param containerRegistryUsername = 'lambdatoysdev'
param existingKeyVaultId = '/subscriptions/469048f1-92af-4c71-a63b-330ec31d2b82/resourceGroups/samcogancore/providers/Microsoft.KeyVault/vaults/deploymentkvsc01'
param secretName = 'lambdaAcrDev'
param vnetSettings = {
  addressPrefixes: [
    '10.0.0.0/19'
  ]
  subnets: [
    { 
      name: 'subnet1'
      addressPrefix: '10.0.0.0/21'
    }
    { 
      name: 'acaAppSubnet'
      addressPrefix: '10.0.8.0/21'
    }
    { 
      name: 'acaControlPlaneSubnet'
      addressPrefix: '10.0.16.0/21'
    }
  ]
}
