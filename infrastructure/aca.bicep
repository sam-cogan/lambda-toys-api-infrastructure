param location string
param prefix string
param vNetId string
param containerRegistryName string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string
param containerVersion string
param cosmosAccountName string
param cosmosDbName string
param cosmosContainerName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${prefix}-la-workspace'
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
  }
}
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' existing ={
  name: cosmosAccountName
  
}
var cosmosDbKey = cosmosDbAccount.listKeys().primaryMasterKey

resource env 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: '${prefix}-container-env'
  location: location
  properties:{
    appLogsConfiguration:{
      destination: 'log-analytics'
      logAnalyticsConfiguration:{
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
   vnetConfiguration:{
     runtimeSubnetId:'${vNetId}/subnets/acaAppSubnet'
     infrastructureSubnetId:'${vNetId}/subnets/acaControlPlaneSubnet'
    }
  }
  resource daprStateStore 'daprComponents@2022-01-01-preview' = {
      name: 'statestore'
      properties:{
        componentType: 'state.azure.cosmosdb'
        version: 'v1'
        scopes: [
          'lambdaapi'
        ]
        metadata: [
          {
            name: 'url'
            value: 'https://${cosmosAccountName}.documents.azure.com:443/'
          }
          {
            name: 'database'
            value: cosmosDbName
          }
          {
            name: 'collection'
            value: cosmosContainerName
          }
          {
            name: 'masterKey'
            value: cosmosDbKey
          }
        ]
      }
    }
  }

resource apiApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name:'${prefix}-api-container'
  location: location
  properties:{
    managedEnvironmentId: env.id
    configuration: {
      secrets:[
        {
          name: 'container-registry-password'
          value: containerRegistryPassword
        }
      ]
      registries:[
        {
          server: '${containerRegistryName}.azurecr.io'
          username: containerRegistryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress:{ 
        external: true
        targetPort: 3000
      }
      dapr: {
        enabled: true
        appPort: 3000
        appId: 'lambdaapi'
      }
    }
    template: {
      containers:[
        {
          image: '${containerRegistryName}.azurecr.io/hello-k8s-node:${containerVersion}'
          name: 'lambdaapi'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }

        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }

}

output apiUrl string = apiApp.properties.configuration.ingress.fqdn
