param(
[Parameter(Mandatory)]
[string] $resourceGroup,

[Parameter(Mandatory)]
[string] $prefix
)


Describe "Infrastructure Tests" {
    Context "Resource Group Tests" {
        It "has created the specific resource group" {
            Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue | Should -Not -be $null
        }
    }

    Context "Virtual Network" {

        BeforeAll {
        $vnet = Get-AzVirtualNetwork -Name "$prefix-vnet" -ResourceGroupName $resourceGroup 
        }

        it "Checks vNet Exists" {
            $vnet | Should -Not -be $null
        }

        it "Checks that the correct subnets have been created" {
            $vnet.subnets.count | Should -be 3
            $vnet.subnets.name | Should -be @("subnet1", "acaAppSubnet", "acaControlPlaneSubnet")
        }
         
        it "Checks that the subnets are the correct size" {
            $($vnet.Subnets | Where-Object { $_.Name -eq "subnet1"}).AddressPrefix.split('/')[-1] | Should -be "21"
            $($vnet.Subnets | Where-Object { $_.Name -eq "acaAppSubnet"}).AddressPrefix.split('/')[-1] | Should -be "21"
            $($vnet.Subnets | Where-Object { $_.Name -eq "acaControlPlaneSubnet"}).AddressPrefix.split('/')[-1] | Should -be "21"
        }
    }

    Context "Cosmos DB" {

        BeforeAll {
        $account =  Get-AzCosmosDBAccount -Name "$prefix-cosmos-account" -ResourceGroupName $resourceGroup 
        }

        it "Checks Cosmos Account Exists" {
            $account | Should -Not -be $null
        }

        it "Checks private endpoint enabled" {
            $account.PrivateEndpointConnections.count | Should -BeGreaterThan 0
        }

          it "Checks public network access is disabled" {
            $account.PublicNetworkAccess | Should -be "disabled"
        }
         
      
    }
}