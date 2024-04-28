param name string
param location string
param virtualNetworkId string
param subnetId string
param resourceId string
param subResourceTypes array
param zoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName 
  location: 'global'
}

resource privateDnsNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${name}-dns-link'
  location: 'global'
  parent: privateDnsZone
  properties:{
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01'  = {
  name: '${name}-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${name}-pe'
        properties: {
          privateLinkServiceId: resourceId
          groupIds: subResourceTypes
        }
      }
    ]
    subnet: {
      
      id: subnetId
    }
  
  }
}

resource privateEndpointDnsLink 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name:'${name}-pe-dns'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: zoneName 
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = privateDnsZone.id
