## NFTs Bootcamp - 02
Solange Gueiros
NFT Brasil - Set/2024

https://pad.riseup.net/p/nftbrasil-02

Inscricoes no Hackathon
https://taikai.network/NFTBrasil/hackathons/hackathoNFBrasil/

Slides
https://docs.google.com/presentation/d/1SktvN7CX7IZVAgK7iT2M8Z5pJHngvIousgPewbU8G7A/pub?start=false&loop=false&delayms=3000

Aula 01
https://www.youtube.com/watch?v=KTOxNw65wBU

Aula 02
https://www.youtube.com/watch?v=FekcGFHMPK4

Aula 03
https://www.youtube.com/watch?v=XJ3FjuDLPAQ


Nome - Profissao
Sol - Educadora Blockchain, Desenvolvedora
Sonia Batista - Desenvolvedora Blockchain
Katia Suzue - Artista
Pedr0x - Artesão de Comunidades :) e empreendedor
Alexandre Eduardo - Programador de computador e Artista
José Aldo Teixeira - Funcionário Público
Thiago Pereira - Embaixador Projetos.
MAIKAO - Artista e web3 builder
Igor Walter - engenheiro de computação
Raphael Carvalho - Programador
Marina Wentzel - jornalista
Guilherme Giorgi - Engenheiro Agrônomo
Jeff Souza - Analista de Sistemas


*******************************************

Network Ethereum Sepolia

No Metamask
Show test networks
Selecionar Sepolia

Acrescentar LINK no Metamask

Va em 
https://docs.chain.link/resources/link-token-contracts/#sepolia-testnet
Add to wallet


Faucet
https://faucets.chain.link/sepolia

Escolher apenas LINK


Somente no workshop
https://workshop-faucet.vercel.app/faucets
BigMac777

Selecionar rede Sepolia, LINK e ETH

https://remix.ethereum.org/
Icone 5 - DEPLOY & RUN TRANSACTIONS
ENVIRONMENT
Injected provider - Metamask
Check the Sepolia (11155111) network

Icone 2 - FILE EXPLORER
Criar o arquivo
Flower.sol

************************************** Início do código **************************************
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract Flower is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 
   // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmVCZ6hVENjkdCDLMoovNCR5S6bSisUQnBKPibb8XXSJqF/seed.json",
        "https://ipfs.io/ipfs/QmVCZ6hVENjkdCDLMoovNCR5S6bSisUQnBKPibb8XXSJqF/purple-sprout.json",
        "https://ipfs.io/ipfs/QmVCZ6hVENjkdCDLMoovNCR5S6bSisUQnBKPibb8XXSJqF/purple-blooms.json"
    ];

    uint public immutable interval;
    uint public lastTimeStamp;

    constructor(uint updateInterval) ERC721("Flower Bootcamp 2024", "FLO") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        safeMint(msg.sender);
    }

    function safeMint(address to) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    // determine the stage of the flower growth
    function flowerStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Seed
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Sprout
        if (
            compareStrings(_uri, IpfsUri[1])
        ) {
            return 1;
        }
        // Must be a Bloom
        return 2;
    }

    function growFlower(uint256 _tokenId) public {
        if(flowerStage(_tokenId) >= 2){return;}
        // Get the current stage of the flower and add 1
        uint256 newVal = flowerStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = IpfsUri[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    // helper function to compare strings
    function compareStrings(string memory a, string memory b)
        public pure returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        if ((block.timestamp - lastTimeStamp) > interval ) {
            uint256 tokenId = tokenIdCounter.current() - 1;
            if (flowerStage(tokenId) < 2) {
                upkeepNeeded = true;
            }
        }
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            uint256 tokenId = tokenIdCounter.current() - 1;
            if (flowerStage(tokenId) < 2) {
                lastTimeStamp = block.timestamp;            
                growFlower(tokenId);
            }
        }
        // We don't use the performData in this example. The performData is generated by the Automation's call to your checkUpkeep function
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
******************************* Fim do código **********************************************

#### Explicando o código Flower:

1. Declarações iniciais:
- SPDX-License-Identifier: MIT: Define a licença MIT para o código.
- pragma solidity 0.8.19: Indica a versão do Solidity utilizada (0.8.19).

2. Importações:
- import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol": Interface da Chainlink Automation para contratos automatizados.
- @openzeppelin/contracts/…: Importa bibliotecas do OpenZeppelin para funcionalidades de NFT (ERC721 e ERC721URIStorage) e utilitários (Counters - para contagem de tokens).


3. Contrato Flower:
- contract Flower is ERC721, ERC721URIStorage, AutomationCompatibleInterface: Ele herda ERC721, ERC721URIStorage e AutomationCompatibleInterface:
    - ERC721: Padrão básico de tokens não fungíveis (NFTs).
    - ERC721URIStorage: Extensão do ERC721 que permite armazenar o URI do token no próprio contrato.
    - AutomationCompatibleInterface: para contratos automatizados.

4. Usando bibliotecas:
- using Counters for Counters.Counter: Habilita o uso de funções de contagem para o contador de tokens (tokenIdCounter).
- using Strings for uint256: Habilita a conversão de números inteiros para strings (necessário para gerar o JSON do token).

5. URIs de Metadados:
- IpfsUri: Array contendo os links IPFS para os metadados de cada estágio da flor (semente, broto e flor).

6. Intervalo e Registro de Tempo:
- interval: Intervalo de tempo (em segundos) para a atualização automática da arte do NFT.
- lastTimeStamp: Timestamp do último update automático.

7. Construtor: 
- constructor(uint updateInterval) ERC721("Flower Bootcamp 2024", "FLO"):
    - Define o nome e o símbolo do NFT.
    - Armazena o intervalo de atualização.
    - Inicializa o registro de tempo.
    - Cria automaticamente um NFT para o remetente da transação.

8. Função safeMint:
- Cria um novo NFT e associa o URI da "semente" ao token.

9. Função flowerStage:
- Verifica o estágio atual da flor com base no URI do token.

10. Função growFlower:
- Permite o crescimento da flor (mudança de arte) se ela ainda não estiver totalmente florida.
- Atualiza o URI do token para o próximo estágio de crescimento.

11. Função compareStrings: 
- Função auxiliar para comparar strings de forma segura.

12. Função checkUpkeep (Chainlink Automation):
- Verifica se a atualização automática é necessária:
    - Compara o tempo atual com o registro de tempo da última atualização.
    - Verifica se a flor ainda não atingiu o estágio final.
    - Se a atualização for necessária, retorna true.

13. Função performUpkeep (Chainlink Automation):
- Executada automaticamente pela Chainlink Automation quando a atualização é necessária.
    - Atualiza o registro de tempo.
    - Chama a função growFlower para mudar a arte do NFT.

14. Função tokenURI:
- Override da função herdada para priorizar a implementação do ERC721URIStorage.

15. Função _burn:
- Override necessária do método _burn herdado do ERC721URIStorage para queima de NFTs.

-----------------------------------------------------------------------------------------

Icone 5 - DEPLOY & RUN TRANSACTIONS
Parametro: intervalo em segundos
120
Deploy

Depois
Deployed/Unpinned Contracts
Copia o endereco de Flower

Nome - Flower address
Sol - 0x3df50771D98283c21693a3cae2f0C049b6DE01bE

Pedr0x: 0x0dD63C78829374081c5e429f9101e6c8d493f832

Sonia - 0xEdC20E39A2560f713fB64b3663e5B6aA3E4C82EF

MArina - 0x9930BB708E7FD3f2b1b7852fDaBE1Cc373142e5F

Raphael - 0x124d63dFF3D36cB5A83b6059a7DC15EEac345AC9

José Aldo - 0x16718279206E1E46a8FEA76Dc5AAAFaF4e8B14a3

Alexandre Eduardo - 0x0606FA594dd8F9A2fe84B1891f7432db3e128E7d

Igor - 0x66De0d9c38990A128BD3eb4f192193E578ffb109 

MAIKAO - 0x097Ae1A53Dd12c056a1add95883E307ec23244d7

Thiago Pereira - 0xA1F475b8B5b7ECA09e07C5e8EE38a2Eb4717B9A3

Jeff Souza - 0xC849e77E72dBb140C55e6ac1d21A8cA202B86106


*********************************

https://testnets.opensea.io/

Sol - https://testnets.opensea.io/collection/flower-bootcamp-2024-958
Sonia - https://testnets.opensea.io/collection/flower-bootcamp-2024-970
José Aldo - https://testnets.opensea.io/collection/flower-bootcamp-2024-963
Marina - 
https://testnets.opensea.io/assets/sepolia/0x9930bb708e7fd3f2b1b7852fdabe1cc373142e5f/0
https://testnets.opensea.io/assets/sepolia/0x9930BB708E7FD3f2b1b7852fDaBE1Cc373142e5F/1
https://testnets.opensea.io/assets/sepolia/0x9930BB708E7FD3f2b1b7852fDaBE1Cc373142e5F/2
Pedr0x: https://testnets.opensea.io/collection/flower-bootcamp-2024-959
Alexandre - https://testnets.opensea.io/collection/flower-bootcamp-2024-964
Igor - https://testnets.opensea.io/collection/flower-bootcamp-2024-967 
MAIKAO - https://testnets.opensea.io/collection/flower-bootcamp-2024-971
Jeff Souza - https://testnets.opensea.io/collection/flower-bootcamp-2024-973


Novo item na colecao
SafeMint

Executar
growFlower
_tokenId: 0

flowerStage
_tokenId: 0
Resultado: 1 

No OpenSea
Abre flor 1
...
Refresh Metadata
Atualiza a pagina

Novo item na colecao (item 2)
SafeMint


https://automation.chain.link/
Connect wallet
I accept the Chainlink Foundation Terms of Service
Metamask

Register new Upkeep
Custom logic

Target contract address
Flower Address

Upkeep name
Flower Automation

Starting balance
5 LINK

Register Upkeep

https://docs.chain.link/chainlink-automation
https://docs.chain.link/chainlink-automation/overview/supported-networks

Nome - Upkeep link
Sol - https://automation.chain.link/sepolia/53851233278846340367491440516035499712022329790596356216217010492500035440419
Pedr0x - https://automation.chain.link/sepolia/101712270516450214031824754123665419070032483124608995761178696115232875130212
Marina -
https://automation.chain.link/sepolia/78254973600269118934600774970258922323174346764736686684862421064486189567816
Raphael -
https://automation.chain.link/sepolia/107043039903947189663829061944552133289906022373326401668036524776988076551501
Sonia
https://automation.chain.link/sepolia/39204767810775306782079478019880583977161614658050156986372908256698882203113
José Aldo - https://automation.chain.link/sepolia/3173439793261021531461732617692390603475478387052218843325868992090027237705
Alexandre - https://automation.chain.link/sepolia/24191746981593372955731123154500113760010743883299063382826698472047581682160
MAIKAO - https://automation.chain.link/sepolia/38448210265576605393133029530411429822690637781644181799032494447946263077663
Jeff Souza - https://automation.chain.link/sepolia/48992081194064071002280309814155912342648165063973592479700924168848102355808

Novo item na colecao (item 3)
SafeMint

***********************************************

Icon 2 - FILE EXPLORER
Create file
Runners.sol

Copiar entre o inicio e o fim

***************************************** Começa o Codigo *****************************************
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract Runners is ERC721, ERC721URIStorage, VRFConsumerBaseV2Plus  {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // VRF
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */          

    // Sepolia coordinator
    // https://docs.chain.link/vrf/v2-5/supported-networks#sepolia-testnet
    IVRFCoordinatorV2Plus COORDINATOR;
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;

    // past requests Ids.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256[] public lastRandomWords;

    // Your subscription ID.
    uint256 public s_subscriptionId;

    //Runners NFT
    Counters.Counter public tokenIdCounter;
    string[] characters_image = [
        "https://ipfs.io/ipfs/QmTgqnhFBMkfT9s8PHKcdXBn1f5bG3Q5hmBaR4U6hoTvb1?filename=Chainlink_Elf.png",
        "https://ipfs.io/ipfs/QmZGQA92ri1jfzSu61JRaNQXYg1bLuM7p8YT83DzFA2KLH?filename=Chainlink_Knight.png",
        "https://ipfs.io/ipfs/QmW1toapYs7M29rzLXTENn3pbvwe8ioikX1PwzACzjfdHP?filename=Chainlink_Orc.png",
        "https://ipfs.io/ipfs/QmPMwQtFpEdKrUjpQJfoTeZS1aVSeuJT6Mof7uV29AcUpF?filename=Chainlink_Witch.png"
    ];
    string[] characters_name = [
        "Elf",
        "Knight",
        "Orc",
        "Witch"
    ];

    struct Runner {
        string name;
        string image;
        uint256 distance;
        uint256 round;
    }
    Runner[] public runners;
    mapping(uint256 => uint256) public request_runner; /* requestId --> tokenId*/


    constructor(uint256 subscriptionId) ERC721("Runners", "RUN")
        VRFConsumerBaseV2Plus(vrfCoordinator)        
    {
        COORDINATOR = IVRFCoordinatorV2Plus(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        safeMint(msg.sender,0);
    }

    function safeMint(address to, uint256 charId) public {
        uint8 aux = uint8 (charId);
        require( (aux >= 0) && (aux <= 3), "invalid charId");
        string memory yourCharacterImage = characters_image[charId];

        runners.push(Runner(characters_name[charId], yourCharacterImage, 0, 0));

        uint256 tokenId = tokenIdCounter.current();
        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', runners[tokenId].name, '",'
                        '"description": "Chainlink runner",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                            '{"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),'}',
                            ',{"trait_type": "round",',
                            '"value": ', runners[tokenId].round.toString(),'}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, finalTokenURI);
    }


    function run(uint256 tokenId) external returns (uint256 requestId) {

        require (tokenId < tokenIdCounter.current(), "tokenId not exists");

        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        request_runner[requestId] = tokenId;
        return requestId;      
    }


    function fulfillRandomWords(uint256 _requestId, uint256[] calldata _randomWords) internal override {
        require (tokenIdCounter.current() >= 0, "You must mint a NFT");
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        lastRandomWords = _randomWords;

        uint aux = (lastRandomWords[0] % 10 + 1) * 10;
        uint256 tokenId = request_runner[_requestId];
        runners[tokenId].distance += aux;
        runners[tokenId].round ++;

        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', runners[tokenId].name, '",'
                        '"description": "Chainlink runner",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                            '{"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),'}',
                            ',{"trait_type": "round",',
                            '"value": ', runners[tokenId].round.toString(),'}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        _setTokenURI(tokenId, finalTokenURI);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {

    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}
```
************************************* Acaba o código *************************************

#### Explicando o código Runners:

1. Declarações iniciais:
- SPDX-License-Identifier: MIT: Define a licença MIT para o código.
- pragma solidity 0.8.19: Indica a versão do Solidity utilizada (0.8.19).
- // Deploy this contract on Sepolia: Comentário informando que o contrato deve ser implantado na rede Sepolia de teste.

2. Importações:
- @openzeppelin/contracts/…: Importa bibliotecas do OpenZeppelin para funcionalidades de NFT (ERC721 e ERC721URIStorage) e utilitários (Counters e Base64).
- @chainlink/contracts/…: Importa interfaces e bibliotecas Chainlink VRF para geração de números aleatórios verificáveis.

3. Contrato Runners:
- contract Runners is ERC721, ERC721URIStorage, VRFConsumerBaseV2Plus: Declara o contrato Runners que herda funcionalidades de três contratos:
    - ERC721: Padrão básico de tokens não fungíveis (NFTs).
    - ERC721URIStorage: Extensão do ERC721 que permite armazenar o URI do token no próprio contrato.
    - VRFConsumerBaseV2Plus: Base para contratos que utilizam a funcionalidade Chainlink VRF.

4. Usando bibliotecas:
- using Counters for Counters.Counter: Habilita o uso de funções de contagem para o contador de tokens (tokenIdCounter).
- using Strings for uint256: Habilita a conversão de números inteiros para strings (necessário para gerar o JSON do token).

5. VRF (Verifiable Random Function):
- event RequestSent(uint256 requestId, uint32 numWords): Define um evento emitido quando uma solicitação de número aleatório é enviada, informando o ID da solicitação e o número de palavras requisitadas.
- event RequestFulfilled(uint256 requestId, uint256[] randomWords): Define um evento emitido quando a solicitação de número aleatório é atendida, informando o ID da solicitação e o array de números aleatórios recebidos.
- struct RequestStatus: Define uma estrutura para armazenar informações sobre o status de uma solicitação de número aleatório:
    - fulfilled: Indica se a solicitação foi atendida.
    - exists: Indica se a solicitação existe.
    - randomWords: Array para armazenar os números aleatórios recebidos.
- mapping(uint256 => RequestStatus) public s_requests: Define um mapeamento público que relaciona o ID da solicitação (requestId) com a sua estrutura de status (RequestStatus).

6. Configurações Chainlink VRF:
- IVRFCoordinatorV2Plus COORDINATOR: Declara uma variável do tipo IVRFCoordinatorV2Plus para interagir com o contrato Chainlink VRF.
- address vrfCoordinator: Endereço do contrato Chainlink VRF na rede Sepolia de teste.
- bytes32 keyHash: Identificador único do serviço VRF na rede Sepolia.
- uint32 callbackGasLimit: Limite de gás para a função fulfillRandomWords (callback) do contrato.
- uint16 requestConfirmations: Número mínimo de confirmações de blocos exigidas para a solicitação.
- uint32 numWords: Número de números aleatórios solicitados (sempre 1 neste caso).
- uint256[] public requestIds: Array público para armazenar os IDs das solicitações pendentes.
- uint256 public lastRequestId: Armazena o ID da última solicitação enviada.
- uint256[] public lastRandomWords: Armazena o último array de números aleatórios recebidos.
- uint256 public s_subscriptionId: Armazena o ID da subscrição Chainlink VRF utilizada.

7. NFT Runners:
- Counters.Counter public tokenIdCounter: Define um contador público para atribuir IDs exclusivos aos NFTs cunhados.
- string[] characters_image: Array contendo os links IPFS para as imagens dos corredores.
- string[] characters_name: Array contendo os nomes dos corredores.
- struct Runner: Define uma estrutura para armazenar informações de cada corredor no NFT:
    - name: Nome do corredor.
    - image: Link IPFS da imagem do corredor.
    - distance: Distância percorrida pelo corredor inicialmente.

https://vrf.chain.link/
Connect wallet
I accept the Chainlink Foundation Terms of Service
Metamask

Create Subscription

Add Funds
5 LINK
Fund subscription

Add consumers - depois!

Nome - Subscription ID
Sol - 2309504704269749448514256531842344682368386173705962919185509499528914367068
Raphael - 30582285959920219308848656303197773189741932611299810408747189911977548833706
Marina - 82573466152423343406916320336389715132524489647633399132962094225018153470329
Sonia - 28894382064482813958929934534190828710986666494525575001951101189619440958289
Pedr0x - 20234841903330253266143974519469613882391383871639658264175244362896066129680
José Aldo- 31103327403151436813894659311978141112213541363203985799903120156399144029299
Alexandre - 59873766851347333035358873788173895957090135304143616266799221232299943183156 
Jeff Souza - 56349304608104921160549273217871971967593417092295662927333855929299171737596

*******************************
Remix
Deploy
Parametro: Subscription ID

Nome - Runners address
Sol - 0xaBEE94ef87f4C8e0de5D171d8361402F4ee6D344
Sonia - 0xDB25a490Bce3282eF49d3ba992cef2a8E6C3884c
Marina - 0xeb8426a8858207398c07260a7C541c842644cB72
Pedr0x - 0x3356028cc3cf0b4865f1a751a1e7eadae5dd8128
José Aldo - 0xAFF6d4E7A4a09f3F7C17297Fb61E19Bfe72fF4E3
Raphael - 0x3750a961dbf957F31bcBc442753f2a8F3780A285
Alexandre Eduardo - 0xa38Ea65eB10BB6993B0a3fF5DAFCa52A75533D37
Jeff Souza - 0x73EBad4Cd6bD470916d60411066682d22f58E5ed

********************************************

https://testnets.opensea.io/

Sol - https://testnets.opensea.io/collection/runners-1507
Sonia - https://testnets.opensea.io/collection/runners-1508
Pedr0x - https://testnets.opensea.io/collection/runners-1509
Marina - https://testnets.opensea.io/collection/runners-1510
José Aldo - https://testnets.opensea.io/collection/runners-1515
Raphael - https://testnets.opensea.io/collection/runners-1514
Alexandre Eduardo - https://testnets.opensea.io/collection/runners-1516
Jeff Souza - https://testnets.opensea.io/collection/runners-1517

No VRF - Add Consumer - Endereço do Runner

No Remix
Executar Run
tokenId: 0