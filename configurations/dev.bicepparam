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

