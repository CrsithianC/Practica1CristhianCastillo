## Objetivo de la practica
Los estudiantes desarrollarán una DApp en Solidity que implemente este flujo de trabajo, 
comprendiendo el impacto ambiental y la utilidad de los créditos de carbono, así como las 
posibilidades que ofrece la tecnología blockchain para mejorar la transparencia y eficiencia 
en el comercio de estos créditos.

## Detalles de implementacion

### 1. Inicialización y Despliegue del ERC-20 ClimateCoin
  - Crear un contrato inteligente para ClimateCoin siguiendo el estándar ERC-20.
  - En el constructor del contrato de gestión, se despliega el contrato ERC-20 ClimateCoin.

### 2 Funciones para mintear NFT ERC721
  - Función `mintNFT`: - Parámetros: `uint256 credits`, `string memory projectName`, `string memory projectURL`, `address developerAddress`.
  - Solo puede ser llamada por el creador del contrato.- Desplegar un ERC721 para crear el NFT con los datos proporcionados.
  - Asignar el NFT directamente a `developerAddress`.- Emitir un evento `NFTMinted` con detalles relevant

### 3 Función de Intercambio de NFT por ClimateCoins con Sistema de Fees
  - Variables de Fee:- Agregar `uint256 public feePercentage` para almacenar el porcentaje de la fee.- Agregar una función `setFeePercentage(uint256 newFeePercentage)` que permita al 
    propietario del contrato actualizar `feePercentage`.
  - Función `exchangeNFTForCC`:- Parámetros: `address nftAddress`, `uint256 nftId`.
  - El NFT se transfiere al contrato.
  - Transferir la cantidad final de ClimateCoins al msg.sender.
  - Enviar las fees al creador del contrato.
  - Emitir un evento `NFTExchanged` con detalles de la transacción.

### 4 Función de Quema de ClimateCoins y NFT
  - Función `burnCCAndNFT`:
    - Parámetros: `uint256 ccAmount`.
    - Elegir un NFT de la colección del contrato con valor equivalente a `ccAmount`.
    - Destruir el NFT seleccionado junto a los CC.- Emitir evento `CCBurn` con los det
