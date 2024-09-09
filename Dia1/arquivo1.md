## NFTs Bootcamp - 01
Solange Gueiros
NFT Brasil - Set/2024

https://pad.riseup.net/p/nftbrasil-01


Inscreva-se no Hackathon
https://taikai.network/NFTBrasil/hackathons/hackathoNFBrasil/overview

Slides
https://docs.google.com/presentation/d/1SktvN7CX7IZVAgK7iT2M8Z5pJHngvIousgPewbU8G7A/pub?start=false&loop=false&delayms=3000

Aula 01
https://www.youtube.com/watch?v=KTOxNw65wBU

Nome - Cidade/Estado
Sol - Sao Paulo
Silvio Freitas - São Paulo/SP
Guilherme Giorgi - Nova Mutum/MT
MArina Wentzel (de Porto Alegre) 
Jeff Souza - São Paulo - SP
Eulália Albuquerque - Recife - PE
Emilly Dias - São Paulo
Achiles Luciano - São Paulo
Tiago Cavazin - Rondônia
Priscila Canoas/RS
Manu Borges - Rio de Janeiro
Carol Santos - Rio de Janeiro
Alexandre Eduardo - São Paulo
Donjorge Almeida - Salvador - BA
MAIKAO - São Paulo - SP
Jana Beltrão - Salvador - BA
Igor Walter (aka RaspC) - Brasília /DF 
CRISTIANE OLIVEIRA DE SOUSA - SÃO PAULO
Edvam Filho - Recife PE 
Filipe Machado - Teresina - PI
José Aldo Teixeira - Correntes - PE
Sonia Batista - São Paulo -SP
Raphael Carvalho - São Paulo - SP
Marcos Lustosa - São Paulo - SP
Pedr0x - Carrancas - MG
Lucas Negrelli - São Paulo/SP
Paulo Mussolini - São Paulo;SP
Katia Suzue -São Paulo SP
Cristiane Rodrigues da Silva - SP

**********************************************

https://ethereum.org/en/developers/docs/standards/tokens/erc-721/

Crie uma conta em 
https://app.pinata.cloud/

https://docs.opensea.io/docs/metadata-standards

```Json
{  
    "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.",
    "external_url": "https://openseacreatures.io/3",
    "image": "https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png",
    "name": "Dave Starbelly",
    "attributes": [ ... ] 
}
```

#### Mas vamos as devidas modificações no arquivo JSON:

```Json
{
  "name": "nome escolhido para o NFT",
  "description": "descrição do NFT",
  "image": "https://ipfs.io/ipfs/...",
  "attributes": [
      {
        "trait-type": "Type",
        "value": "nome dado ao NFT"        
      },
      {
        "trait-type": "Location",
        "value": "local da preferência"
      }
  ]
}
```

Carteira no Metamask para TESTES

https://metamask.io/download/

Nome - Endereço da carteira
Sol - 0x12Fbc10072650d844492De4bcCd0298eaE07dB96

Emilly - 0x76d93541B0a88beEA9eBDd6baC182877318ea184
Jeff Souza - 0x84fFeaF1F46A4c53Bb8a9943FC82D1d5BA66Cf5b
Marina Wentzel - 0xBd161EAaAdd3efe4f912F0aeC1190AEbb7A1CBaF
Silvio Freitas - 0xbAcEE6380b260d4a6399e43D201F2175BBC728dc
Filipe Machado - 0x0F98feB968D2b719F6acEE841a362dAC385c1de2
Donjorge Almeida - 0x32F0DF7aC918b4eaFfdE97ecb3823E5F1002bf6a
Achiles Luciano - 0x35c348b6D97048e545041Df9707de106E4da2451
Alexandre Eduardo - 0x43725b338e44949948D9Dfe6eCd655c1eC18F94d
RaspC - 0xBe4FFDA2b229F6f0e99a01Cf189E4d40FC623B23
Guilherme Giorgi - 0xffe0e276C001327904A8CCb10500A8D015694ABB
MAIKAO - 0x9B21Feb8a8574861EDEE63Fb649BeEA373e32C0f
José Aldo - 0x1c36946Da1F42105452966BdC6FE0C92a5927F6C
Sonia Batista - 0xBDb1384ba2BA275f220af23A6D09088d7004D7b0
Raphael Carvalho - 0x89dc9E309b4C16ECe63266C256d6b41132cBD971
Pedr0x - 0x5833869fdEB4D371b854D7474F5F84B43320FD05
Paulo Mussolini - 0xfE05bdebAc36c7db517782ed9F074df8368ce3a7
Katia Suzue 0x48b41b1D02A30554bB8A121A9E11c52b62dc72f3
Marcos - 0x1746e83b1A9c3C51fa3afA9958F0d3165ECEba9e

*******************************************

Network Ethereum Sepolia

No Metamask
Show test networks
Selecionar Sepolia

https://sepolia.etherscan.io/

Faucet
https://faucets.chain.link/sepolia

https://workshop-faucet.vercel.app/faucets
BigMac777

Selecionar rede Sepolia, ETH

Remix
https://remix.ethereum.org/

Icon 4 - SOLIDITY COMPILER
Enable Auto compile

Icon 5 - DEPLOY & RUN TRANSACTIONS
ENVIRONMENT
Injected provider - Metamask
Check the Sepolia (11155111) network


Icon 2 - FILE EXPLORER

Criar o arquivo
MyNFT.sol

Copiar entre o inicio e o fim

****************************** Inicia o código ***********************************

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract MyNFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 
   // Metadata information for each stage of the NFT on IPFS.
    string[] public MetadataUriList;

    constructor() ERC721("NFT Brasil Bootcamp 2024", "BRBO") {
    }

    function safeMint(address to, string memory metadataUri ) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        MetadataUriList.push (metadataUri);
        _setTokenURI(tokenId, metadataUri);
    }

    function updateTokenURI(uint256 tokenId, string memory metadataUri) public {
        _setTokenURI(tokenId, metadataUri);
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // The following function is an override required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}
```

******************************* Acaba o código *********************************

#### Explicando o código MyNFT:

1. Declarações iniciais:
- SPDX-License-Identifier: MIT: Define a licença MIT para o código.
- pragma solidity 0.8.19: Indica a versão do Solidity utilizada (0.8.19).

2. Importações:
- @openzeppelin/contracts/…: Importa bibliotecas do OpenZeppelin para funcionalidades de NFT (ERC721 e ERC721URIStorage) e utilitários (Counters).

3. Contrato MyNFT:
- contract MyNFT is ERC721, ERC721URIStorage: Declara o contrato MyNFT que herda das classes ERC721 e ERC721URIStorage. Isso significa que o contrato terá todas as funcionalidades básicas de um NFT e também poderá armazenar URIs de metadados para cada token.

4. Contador de Tokens:
- using Counters for Counters.Counter: Utiliza a biblioteca Counters para criar um contador de tokens (tokenIdCounter). Esse contador será usado para atribuir IDs únicos aos NFTs.
- Counters.Counter public tokenIdCounter: 

5. Lista de URIs de Metadados:
- string[] public MetadataUriList: Cria um array público de strings para armazenar as URIs dos metadados de cada NFT.

6. Construtor:
- constructor() ERC721("NFT Brasil Bootcamp 2024", "BRBO"): O construtor é chamado quando o contrato é implantado. Ele define o nome e o símbolo do NFT.

7. Função safeMint:
- function safeMint(address to, string memory metadataUri): Esta função é usada para criar um novo NFT.
    - tokenIdCounter.increment(): Ela incrementa o contador de tokens.
    - _safeMint(to, tokenId): herdada do ERC721 para criar o NFT e atribuí-lo ao endereço to.
    - MetadataUriList.push (metadataUri): Adiciona o URI do metadado à lista de URIs.
    - Utiliza a função _setTokenURI herdada do ERC721URIStorage para associar o URI do metadado ao NFT.

8. Função updateTokenURI:
- Esta função permite atualizar o URI do metadado de um NFT existente.

9. Função tokenURI:
- Esta função é usada para obter o URI do metadado de um NFT específico. Ela é uma sobrecarga da função tokenURI herdada do ERC721URIStorage.

10. Função _burn:
- Esta função é uma sobrecarga necessária do método _burn herdado do ERC721URIStorage. Ela é usada para queimar um NFT (removê-lo da circulação). 

https://wizard.openzeppelin.com/#erc721

Icon 5 - DEPLOY & RUN TRANSACTIONS

Deploy

Em Deployed/Unpinned Contracts
Copie o endereço da coleção NFT

Nome - Endereço da coleção NFT
Sol - 0xbFC4d5a75A92dDedF17f683c5c57D2Cba7C2ec92
Jeff Souza - 0x4EB51c2E8E5d929960B7DD23583af6C5939210CA
Guilherme Giorgi - 0x2bCBeBd2D4628820548899B39beb8a651C482088
MArina Wentzel - 0x58D21d4ce5cc1F0A53c8751e46AAcDA841944509
RaspC - 0x63d55A728a40453559C85c413903917274462E35
MAIKAO - 0x2C9530E46966FC3973c5C5Cc92cbfCBD8995CDa0
José Aldo - 0x6200304310a2dEe5aD8227433E767423b0289b14
Raphael Carvalho - 0x843e99AC43C96Da53856322b0a3B349b1f76B92e
Alexandre Eduardo - 0x47b423a3a0EAD547f2f3312fCFE6307666cC64AA
Pedr0x - 0x5B567a9F9c7202FC72c2b735206B48ee9948B75a



https://ipfs.io/ipfs/QmcusKgN4XKSLcJjHD9WF7WAuww6mmcGUkUWKgQsXhW7vA/photo01.json
https://ipfs.io/ipfs/QmcusKgN4XKSLcJjHD9WF7WAuww6mmcGUkUWKgQsXhW7vA/photo02.json
https://ipfs.io/ipfs/QmcusKgN4XKSLcJjHD9WF7WAuww6mmcGUkUWKgQsXhW7vA/photo03.json

No Remix
Expandir o NFT

Expandir safeMint
to - endereço da sua carteira
metadataUri - link do json 

Exemplo:
to - 0x12Fbc10072650d844492De4bcCd0298eaE07dB96
metadataUri - https://ipfs.io/ipfs/QmcusKgN4XKSLcJjHD9WF7WAuww6mmcGUkUWKgQsXhW7vA/photo01.json
Clicar em transact 


https://testnets.opensea.io/

Copie e cole o endereço do seu smart contract no OpenSea

Nome - link da coleção
Sol - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-1

RaspC - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024
Guilherme Giorgi - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-3
Jeff Souza - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-2
MAIKAO - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-5
José Aldo - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-6
Raphael Carvalho - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-8
Alexandre Eduardo - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-9
Pedr0x - https://testnets.opensea.io/collection/nft-brasil-bootcamp-2024-11


Crie outro sozinho
1- Upload da imagem 
2- Copiar o link da imagem
3- Criar o json e atualzar os dados, incluindo o link da imagem

no

Trocar o link do pinata pelo do IPFS

Usar este:
https://ipfs.io/...

Sol - exemplo
Original
https://aqua-golden-piranha-514.mypinata.cloud/ipfs/QmcAAVYLyVUV3VpPLYTyPU3KUvauVrHFR7fAufUdDoRogT

Trocar por
https://ipfs.io/ipfs/QmcAAVYLyVUV3VpPLYTyPU3KUvauVrHFR7fAufUdDoRogT

https://ipfs.io/ipfs/QmVNakEKMfyCKFE6qiWbCmya5T1MJJUwrJkvwPd5kRzwAu/Tigers-01.jpg

Nome - URL da sua nova imagem
Sol - https://ipfs.io/ipfs/QmcAAVYLyVUV3VpPLYTyPU3KUvauVrHFR7fAufUdDoRogT
Guilherme Giorgi -https://ipfs.io/ipfs/QmVFvD798YU8cDrR5zmcp63xW2j75zvEXvhauoQXPSUp7o/capybara.jpeg
RaspC - https://ipfs.io/ipfs/QmYat6HYnpmnH8JnTVQRiEPFec5VghhF3NPAvYy6yt97TU
Marina - Imagem https://ipfs.io/ipfs/QmRFVy9V68A83yWdxDP2sDNdstsSuXEZ8cNaZKzf1U9Tut
Marina - Json https://ipfs.io/ipfs/QmdxHTR38Wd3YtgXD5QZui72rXAVsPijtmrZswrQVTSg7A
José Aldo - https://ipfs.io/ipfs/QmZue7aTGr4zXWHgidcfYgC5YvN4N5sBiYuCP9ji3gCaQv
Jeff Souza - https://ipfs.io/ipfs/QmTAMKXzzsUfKDhD4NEFi96vPM1wH4vX8mkfnTSp3oQaMy
Alexandre Eduardo - https://ipfs.io/ipfs/QmXZdPvbbuN6Wd87he2urEDBa7YrC6JbT8uaDYHDvLsHvD
Raphael Carvalho - https://ipfs.io/ipfs/QmPtADo5YEpZ1iewtxDxLoHZUXRxwC96u8ZTKdJUziUUuX
Pedr0x - https://ipfs.io/ipfs/QmNNxSMXrXvZwMvS2ryfEnoFDt4iFiCqmErjKCRxdysw5y




Atualizar o Json no notepad 
Salvar no seu computador
Fazer upload no Pinata

Exemplo Sol
https://aqua-golden-piranha-514.mypinata.cloud/ipfs/Qma2wd6KzKzNMCoQSYwBhXSyMhssb4u5XbPk2yZTpgJxdP
https://aqua-golden-piranha-514.mypinata.cloud/ipfs/QmNgyyhaUircHm6ABjKcMDF8rYj7CPoC883T88JyGTYGDk/tigres-01.json

Usar este:
https://ipfs.io/...

https://ipfs.io/ipfs/QmNgyyhaUircHm6ABjKcMDF8rYj7CPoC883T88JyGTYGDk/tigres-01.json

Pedr0x: https://ipfs.io/ipfs/QmYtw3CPwQTw2QjDNALrBbtHAoUGHH7yCuEaK8tf8vGb9K/Jimmy.jason

No Remix, 
Mint

2 NFTS com a mesma imagem, porem unicos
https://testnets.opensea.io/assets/sepolia/0xbfc4d5a75a92ddedf17f683c5c57d2cba7c2ec92/2
https://testnets.opensea.io/assets/sepolia/0xbfc4d5a75a92ddedf17f683c5c57d2cba7c2ec92/3