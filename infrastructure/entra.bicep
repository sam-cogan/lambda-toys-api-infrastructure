param keyVaultName string
provider microsoftGraph

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
 }
 

resource lambdaSecretsApp 'Microsoft.Graph/applications@v1.0' ={
  displayName: 'lambdaSecretsApp'
  signInAudience: 'AzureADMyOrg'
  uniqueName: 'lambdaSecretsApp'
}

resource lambdaSecretsSP 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: lambdaSecretsApp.appId
  displayName: 'lambdaSecretsApp'
}

resource secretAccessGroup 'Microsoft.Graph/groups@v1.0' = {
  displayName: 'secretAccessGroup'
  mailEnabled: false
  mailNickname: 'secretAccessGroup'
  securityEnabled: true
  uniqueName: 'secretAccessGroup'
  members: [
    lambdaSecretsSP.id
  ]
  owners: [
    lambdaSecretsSP.id
  ]
  
}

resource secretReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' ={
  name: guid(resourceGroup().name, 'secretReaderRoleAssignment')
  properties:{
    principalId: secretAccessGroup.id
    principalType: 'Group'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
  }
  scope: kv
}

