param location string
param prefix string
param tier string = 'Consumption'
param capacity int = 0
param externalResourcesRg string
param certKeyVaultName string
param certKeyVaultUrl string

resource apimUserIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}-apim0-mi'
  location: location
}

module apimExternalResources 'externalResources.bicep' ={
  name:'${prefix}-apim-external'
  scope: resourceGroup(externalResourcesRg)
  params:{
    zoneName:'lambdatoys.com'
    recordName: '${prefix}-apim'
    cName: '${prefix}-apim.azure-api.net'
    managedIdentityId: apimUserIdentity.properties.principalId
    keyVaultName: certKeyVaultName
  }
}

resource apiManagementInstance 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: '${prefix}-apim'
  location: location
  dependsOn:[
    apimExternalResources
  ]
  sku:{
    capacity: capacity
    name: tier
  }
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities:{
      '${apimUserIdentity.id}' : {}
    }
  }
  properties:{
    virtualNetworkType: 'None'
    publisherEmail: 'support@lambdatoys.com'
    publisherName: 'Lambda Toys'
    hostnameConfigurations:[
      {
        hostName: '${prefix}-apim.lambdatoys.com'
        type: 'Proxy'
        certificateSource: 'KeyVault'
        keyVaultId: certKeyVaultUrl
        identityClientId: apimUserIdentity.properties.clientId
      }
    ]
  }
}

var base64_api=loadFileAsBase64('../resources/lambdaStoreSwagger.json')

resource lambdaStoreApi 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  parent: apiManagementInstance
  name:'LambdaStore'
  properties:{
    format: 'swagger-json'
    value: base64ToString(base64_api)
    path: 'lambdaToyStore'
  }
}

resource toyProduct 'Microsoft.ApiManagement/service/products@2020-12-01' = {
  parent: apiManagementInstance
  name: 'toyProduct'
  properties: {
    displayName: 'Toy product'
    description: 'Lambda Toys Ordering Product'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'

  }
}

resource toyProductPolicies 'Microsoft.ApiManagement/service/products/policies@2020-12-01' = {
  name: 'policy'
  parent: toyProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource toyProductApiLink 'Microsoft.ApiManagement/service/products/apis@2020-12-01' = {
  name: 'LambdaStore'
  parent: toyProduct
  dependsOn:[
    lambdaStoreApi
  ]
}
