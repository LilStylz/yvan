// Définition des paramètres pour la configuration de la VM
param location string = resourceGroup().location // Localisation de la ressource
param vmName string = 'myVirtualMachine' // Nom de la machine virtuelle
param adminUsername string = 'azureUser' // Nom d'utilisateur administrateur
param adminPassword string // Mot de passe administrateur (doit être sécurisé)
param vmSize string = 'Standard_DS1_v2' // Taille de la machine virtuelle
param subnetName string = 'default' // Nom du sous-réseau
param vnetName string = 'myVnet' // Nom du réseau virtuel
param addressPrefix string = '10.0.0.0/16' // Plage d'adresses du réseau virtuel
param subnetPrefix string = '10.0.0.0/24' // Plage d'adresses du sous-réseau

// Création du réseau virtuel
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                addressPrefix
            ]
        }
        subnets: [
            {
                name: subnetName
                properties: {
                    addressPrefix: subnetPrefix
                }
            }
        ]
    }
}

// Création de l'adresse IP publique
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
    name: '${vmName}-ip'
    location: location
    properties: {
        publicIPAllocationMethod: 'Dynamic'
    }
}

// Création de la carte réseau
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
    name: '${vmName}-nic'
    location: location
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    subnet: {
                        id: virtualNetwork.properties.subnets[0].id
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: publicIp.id
                    }
                }
            }
        ]
    }
}

// Création de la machine virtuelle
resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
    name: vmName
    location: location
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        osProfile: {
            computerName: vmName
            adminUsername: adminUsername
            adminPassword: adminPassword
        }
        storageProfile: {
            imageReference: {
                publisher: 'Canonical'
                offer: 'UbuntuServer'
                sku: '18.04-LTS'
                version: 'latest'
            }
            osDisk: {
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: 'Standard_LRS'
                }
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: networkInterface.id
                }
            ]
        }
    }
}
