NFTs Bootcamp - 02
Solange Gueiros
NFT Brasil - Set/2024

https://pad.riseup.net/p/nftbrasil-03

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

Nome - Rede social (se quiser)
Sol - solangegueiros
MAIKAO - @maikao_official
Jeff Souza - instagram.com/j3ffsouza
Marina Wentzel - marinawentzel@gmail.com
Raphael - @raphaelrcarvalho
Alexandre Eduardo - @aleedu_avelino
José Aldo Teixeira
Pedr0x - https://warpcast.com/pedr0x.eth


**********************************

https://remix.ethereum.org/
Icone 5 - DEPLOY & RUN TRANSACTIONS
ENVIRONMENT
Injected provider - Metamask
Check the Sepolia (11155111) network

Icone 2 - FILE EXPLORER
Criar o arquivo
CrossChainPriceNFT.sol

********************************* Início do código *********************************
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

// Importing OpenZeppelin contracts
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

// Importing Chainlink contracts
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CrossChainPriceNFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter public tokenIdCounter;

    // Create price feed
    AggregatorV3Interface internal priceFeed;
    uint256 public lastPrice = 0;

    string priceIndicatorUp = unicode"😀";
    string priceIndicatorDown = unicode"😔";
    string priceIndicatorFlat = unicode"😑";
    string public priceIndicator;

    struct ChainStruct {
        uint64 code;
        string name;
        string color;
    }
    mapping (uint256 => ChainStruct) chain;

    //https://docs.chain.link/ccip/supported-networks/testnet
    constructor() ERC721("CrossChain Price", "CCPrice") {
        chain[0] = ChainStruct ({
            code: 16015286601757825753,
            name: "Sepolia",
            color: "#0000ff" //blue
        });
        chain[1] = ChainStruct ({
            code: 14767482510784806043,
            name: "Fuji",
            color: "#ff0000" //red
        });
        chain[2] = ChainStruct ({
            code: 12532609583862916517,
            name: "Mumbai",
            color: "#4b006e" //purple
        });

        // https://docs.chain.link/data-feeds/price-feeds/addresses        
        priceFeed = AggregatorV3Interface(
            // Sepolia BTC/USD
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43            
        );

        // Mint an NFT
        mint(msg.sender);
    }

    function mint(address to) public {
        // Mint from Sepolia network = chain[0]
        mintFrom(to, 0);
    }

    function mintFrom(address to, uint256 sourceId) public {
        // sourceId 0 Sepolia, 1 Fuji, 2 Mumbai
        uint256 tokenId = tokenIdCounter.current();
        _safeMint(to, tokenId);
        updateMetaData(tokenId, sourceId);    
        tokenIdCounter.increment();
    }

    // Update MetaData
    function updateMetaData(uint256 tokenId, uint256 sourceId) public {
        // Create the SVG string
        string memory finalSVG = buildSVG(sourceId);
           
        // Base64 encode the SVG
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Cross-chain Price SVG",',
                        '"description": "SVG NFTs in different chains",',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSVG)), '",',
                        '"attributes": [',
                            '{"trait_type": "source",',
                            '"value": "', chain[sourceId].name ,'"},',
                            '{"trait_type": "price",',
                            '"value": "', lastPrice.toString() ,'"}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        // Set token URI
        _setTokenURI(tokenId, finalTokenURI);
    }

    // Build the SVG string
    function buildSVG(uint256 sourceId) internal returns (string memory) {

        // Create SVG rectangle with random color
        string memory headSVG = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:svgjs='http://svgjs.com/svgjs' width='500' height='500' preserveAspectRatio='none' viewBox='0 0 500 500'> <rect width='100%' height='100%' fill='",
                chain[sourceId].color,
                "' />"
            )
        );
        // Update emoji based on price
        string memory bodySVG = string(
            abi.encodePacked(
                "<text x='50%' y='50%' font-size='128' dominant-baseline='middle' text-anchor='middle'>",
                comparePrice(),
                "</text>"
            )
        );
        // Close SVG
        string memory tailSVG = "</svg>";

        // Concatenate SVG strings
        string memory _finalSVG = string(
            abi.encodePacked(headSVG, bodySVG, tailSVG)
        );
        return _finalSVG;
    }

    // Compare new price to previous price
    function comparePrice() public returns (string memory) {
        uint256 currentPrice = getChainlinkDataFeedLatestAnswer();
        if (currentPrice > lastPrice) {
            priceIndicator = priceIndicatorUp;
        } else if (currentPrice < lastPrice) {
            priceIndicator = priceIndicatorDown;
        } else {
            priceIndicator = priceIndicatorFlat;
        }
        lastPrice = currentPrice;
        return priceIndicator;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
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
****************************** Fim do código *************************************************

#### Explicando o contrato CrossChainPriceNFT.sol

1. Licença, Pragma e Comentário de Deploy:
- // SPDX-License-Identifier: MIT: Esta linha especifica a licença MIT usada pelo contrato.
- pragma solidity 0.8.19;: Define a versão Solidity utilizada para compilar o contrato (versão 0.8.19).
- // Deploy this contract on Sepolia: Um comentário lembrando que o contrato deve ser implantado na rede de teste Sepolia.

2. Importações de Bibliotecas
- Estas linhas importam bibliotecas necessárias para o funcionamento do contrato:
    - @openzeppelin/contracts/…: Importa funcionalidades para tokens ERC721 (ERC721URIStorage) e utilitários como contador (Counters) e codificação base64 (Base64).
    - @chainlink/contracts/…: Importa interfaces para interagir com o serviço de oráculo de preços Chainlink (AggregatorV3Interface).

3. Definição do Contrato e Contador
- contract CrossChainPriceNFT is ERC721, ERC721URIStorage: Esta linha define o contrato CrossChainPriceNFT que herda funcionalidades de ambos os padrões ERC721 (NFT básico) e ERC721URIStorage (permite armazenar a URI do token na blockchain).
- using Counters for Counters.Counter;: Habilita o uso de funções de contador para o tokenIdCounter.
- using Strings for uint256;: Permite converter valores inteiros em strings (necessário para criar JSON).

4. Preço do Oráculo e Emojis
- Counters.Counter public tokenIdCounter;: Declara um contador público para atribuir IDs únicos a cada NFT cunhado.
- AggregatorV3Interface internal priceFeed;: Esta linha declara uma variável interna do tipo AggregatorV3Interface para interagir com o contrato Chainlink que fornece o preço do ativo.
- uint256 public lastPrice = 0;: Armazena o último preço obtido do feed de dados.
- Três variáveis string definem emojis indicadores para variação de preço (priceIndicatorUp, priceIndicatorDown, e priceIndicatorFlat).

5. Estrutura ChainStruct e Construtor
- struct ChainStruct { ... }: Define uma estrutura nomeada ChainStruct para armazenar informações sobre as blockchains suportadas:
    - uint64 code: Código único da blockchain.
    - string name: Nome da blockchain.
    - string color: Cor que representa a blockchain em formato HTML.
- O construtor constructor() executa as seguintes ações:
    - Inicializa o padrão ERC721 com um nome ("CrossChain Price") e símbolo ("CCPrice").
    - Cria entradas no mapeamento chain para três redes de teste (Sepolia, Fuji, Mumbai) com seus códigos, nomes e cores.
    - Define a variável priceFeed para o endereço do feed de preço BTC/USD da rede Sepolia.
    - Cria automaticamente um NFT inicial para o deployer do contrato (usando mint(msg.sender)).

6. Função mint
- function mint(address to) public { ... }: Esta função pública permite cunhar um novo NFT para um determinado endereço (to).
- Internamente, ela chama mintFrom(to, 0) que assume a criação do NFT na rede Sepolia (ID da rede 0).

7. Função mintFrom
- function mintFrom(address to, uint256 sourceId) public { ... }: Esta função pública permite cunhar um NFT especificando a ID da rede de origem (sourceId).
- Recupera a ID atual do token do contador.
- Cria um novo NFT com essa ID para o destinatário (to).
- Chama a função updateMetaData para gerar e definir a URI inicial do token com base na rede de origem.
Incrementa o contador de ID do token.

8. Função updateMetaData
- function updateMetaData(uint256 tokenId, uint256 sourceId) public { ... }: Esta função pública atualiza os metadados de um NFT existente.
    - Chama a função interna buildSVG para gerar uma string SVG representando o NFT.
    - Codifica a string SVG em base64 usando a biblioteca Base64.
    - Cria uma string JSON contendo os metadados do NFT, incluindo nome, descrição, imagem (SVG codificado) e atributos (rede de origem e preço).
    - Combina a string JSON com um prefixo para criar o URI final do token.
    - Define o URI final do token usando _setTokenURI.

9. Função buildSVG
- function buildSVG(uint256 sourceId) internal returns (string memory) { ... }: Esta função interna cria a string SVG que representa o NFT.
    - Gera o código SVG para um retângulo com a cor correspondente à rede de origem.
    - Gera o código SVG para um texto que exibe o emoji indicando a variação de preço.
    - Combina os códigos SVG do retângulo e do texto para criar o SVG final.

10. Função comparePrice
- function comparePrice() public returns (string memory) { ... }: Esta função pública compara o preço atual com o preço anterior e retorna o emoji correspondente.
    - Obtém o preço atual usando getChainlinkDataFeedLatestAnswer.
    - Compara o preço atual com o preço anterior e atualiza a variável priceIndicator com o emoji adequado.
    - Retorna o emoji indicando a variação de preço.

11. Função getChainlinkDataFeedLatestAnswer
- function getChainlinkDataFeedLatestAnswer() public view returns (uint256) { ... }: Esta função pública obtém o último preço do feed de dados Chainlink.
    - Utiliza a função latestRoundData do contrato AggregatorV3Interface para obter os dados da última rodada.
    - Retorna o valor do preço como um uint256.

12. Funções tokenURI e _burn
- function tokenURI(uint256 tokenId) ...: Sobrescreve a função tokenURI para retornar o URI do token.
- function _burn(uint256 tokenId) internal override ...: Sobrescreve a função _burn para queimar um NFT.

----------------------------------------------------------------------------------------------------
Icone 5 - DEPLOY & RUN TRANSACTIONS
Deploy

Nome - CrossChainPriceNFT address
Sol - 0xa372c44DA07690E537e4fD0b8EA1b4b5ef50A956
MAIKAO - 0x097Ae1A53Dd12c056a1add95883E307ec23244d7
Jeff Souza - 0xeA6CB05A58214c45cCA9FB46666A89e681FdF922
Marina - 0xA90AaCB9F6C72139Cb29CbdD5e6C0bFDcdFc0ffF
Alexandre Eduardo - 0x59e595849D90c854638860ff93fC2099780ce491
Pedr0x - 0xD49CA935B6F7805bE5f3c8F04466526E0855E7C5
Raphael - 0x11429313030122cA0D00E54e926100845dF454b9



************************************
https://data.chain.link/
https://docs.chain.link/data-feeds/price-feeds/addresses

https://docs.chain.link/ccip/supported-networks/testnet

https://testnets.opensea.io/

Nome - Link da coleção
Sol - https://testnets.opensea.io/collection/crosschain-price-1705
Jeff Souza - https://testnets.opensea.io/collection/crosschain-price-1702
Pedr0x - https://testnets.opensea.io/collection/crosschain-price-1707
Alexandre - https://testnets.opensea.io/collection/crosschain-price-1706
Raphael - https://testnets.opensea.io/collection/crosschain-price-1708
José Aldo - https://testnets.opensea.io/collection/crosschain-price-1709



*****************************

No Remix
Mint - para sua carteira

Price
56103.42413254
56177.00000000


Criar
CrossDestinationMinter.sol

********************************* Início do código *********************************
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

interface InftMinter {
    function mintFrom(address account, uint256 sourceId) external;
}

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract CrossDestinationMinter is CCIPReceiver {
    InftMinter public nft;

    event MintCallSuccessfull();
    // https://docs.chain.link/ccip/supported-networks/testnet
    address routerSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;

    constructor(address nftAddress) CCIPReceiver(routerSepolia) {
        nft = InftMinter(nftAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (bool success, ) = address(nft).call(message.data);
        require(success);
        emit MintCallSuccessfull();
    }

    function testMint() external {
        // Mint from Sepolia
        nft.mintFrom(msg.sender, 0);
    }

    function testMessage() external {
        // Mint from Sepolia
        bytes memory message;
        message = abi.encodeWithSignature("mintFrom(address,uint256)", msg.sender, 0);

        (bool success, ) = address(nft).call(message);
        require(success);
        emit MintCallSuccessfull();
    }

    function updateNFT(address nftAddress) external {
        nft = InftMinter(nftAddress);
    }
}
```
********************************* Fim do código *********************************

#### Explicando o contrato CrossChainPriceNFT.sol

1. Licença e Pragma
- // SPDX-License-Identifier: MIT: Define a licença MIT usada pelo contrato.
- pragma solidity 0.8.19;: Especifica a versão Solidity utilizada para compilar o contrato (versão 0.8.19).

2. Importações
- import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";: Importa a funcionalidade CCIPReceiver da biblioteca Chainlink CCIP para receber mensagens entre blockchains.
- import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";: Importa a biblioteca Client da Chainlink CCIP para lidar com mensagens de forma mais genérica (não utilizada diretamente neste contrato).

3. Interface InftMinter
- Define uma interface InftMinter com a função mintFrom para abstrair a interação com o contrato de cunhagem de NFTs. Essa interface permite que qualquer contrato que implemente a função mintFrom seja utilizado pelo CrossDestinationMinter.

4. Contrato CrossDestinationMinter
- contract CrossDestinationMinter is CCIPReceiver**: Define o contrato CrossDestinationMinter que herda a funcionalidade CCIPReceiver para receber mensagens entre blockchains.

5. Variável nft
- InftMinter public nft;: Declara uma variável pública do tipo InftMinter para armazenar o endereço do contrato de cunhagem de NFT.

6. Evento MintCallSuccessfull
- event MintCallSuccessfull();: Define um evento para registrar quando uma chamada de cunhagem de NFT é bem-sucedida.

7. Endereço do Roteador Sepolia
- // https://docs.chain.link/ccip/supported-networks/testnet: Comentário com um link para a documentação sobre redes suportadas pelo CCIP (aqui indicando a rede de teste Sepolia).
- address routerSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;: Define o endereço do Roteador CCIP para a rede Sepolia (usado para validação de mensagens).

8. Construtor (constructor)
- constructor(address nftAddress) CCIPReceiver(routerSepolia) { ... }: O construtor recebe o endereço do contrato de cunhagem de NFT como argumento e:
    - Chama o construtor da classe base CCIPReceiver passando o endereço do roteador Sepolia.
    - Inicializa a variável nft com o endereço do contrato de cunhagem de NFT fornecido.

9. Função _ccipReceive
- function _ccipReceive(Client.Any2EVMMessage memory message) internal override { ... }: Esta função interna sobreescreve a função herdada _ccipReceive.
    - Ela é chamada automaticamente quando o contrato recebe uma mensagem CCIP.
    - A função verifica se a mensagem foi bem-sucedida e, em seguida, tenta executar os dados da mensagem (message.data) como uma chamada de função no contrato de cunhagem de NFT (address(nft))
    - Se a chamada for bem-sucedida, o evento MintCallSuccessfull é emitido.

10. Função testMint
- function testMint() external { ... }: Esta função pública simula uma chamada de cunhagem de NFT na rede Sepolia.
    - Ela chama diretamente a função mintFrom do contrato de cunhagem de NFT, passando o endereço do remetente da transação (msg.sender) e o ID da rede Sepolia (0).

11. Função testMessage
- function testMessage() external { ... }: Esta função pública demonstra como enviar uma mensagem CCIP para cunhar um NFT na rede Sepolia.
    - Ela codifica uma chamada à função mintFrom do contrato de cunhagem de NFT, passando o endereço do remetente e o ID da rede Sepolia.
    - Em seguida, ela tenta executar essa mensagem como uma chamada de função no contrato de cunhagem de NFT.
    - Se a chamada for bem-sucedida, o evento MintCallSuccessfull é emitido.

12. Função updateNFT
- function updateNFT(address nftAddress) external { ... }: Esta função pública permite atualizar o endereço do contrato de cunhagem de NFT.
    - Ela atribui o novo endereço à variável nft.

-------------------------------------------------------------------------------
Deploy
Parametro - Endereço do NFT

Nome - CrossDestinationMinter address
Sol - 0x33982428Be21eC88C45f48B7BEDE39bD5361E4D7
Pedr0x - 0x3640a0Cd803a2EcEC65f6E52EA3aC0D1eDc0D00e
Jeff Souza - 0xb1C8D12957fdc4219Bb732fd9dF30EA88f97ED5F
Marina - 0x054dD983Ad380B8A706Bf544cB07a4aD1e459e28
Raphael - 0x8147b60CF0424159bc099d53bEeAC3F314A171Cb
Alexandre Eduardo - 0x59e595849D90c854638860ff93fC2099780ce491
José Aldo - 0xB1A040A19ae367BDDF506Cdc34CcEca32cDdd551

***********************

testMint
testMessage


Origem
Avalanche Fuji

Destino
Ethereum Sepolia

Addicionar Fuji no Metamask
https://chainlist.org/chain/43113

Connect wallet
Avalanche Fuji Testnet - Add to Metamask

Add LINK on Fuji on Metamask
https://docs.chain.link/resources/link-token-contracts#fuji-testnet

https://faucets.chain.link/fuji
LINK e Avax Fuji

Nao conseguiu? Tenta aqui
Somente no workshop
https://workshop-faucet.vercel.app/faucets
BigMac777


consegui 2 AVAX no faucet: https://core.app/tools/testnet-faucet/?subnet=c&token=c não precisou de GitHub

Ah! eu vi que tinha o cupom opcional mas como funcionou sem eu nem li que tinha de ter na mainnet

No Remix
Icone 5 - DEPLOY & RUN TRANSACTIONS
ENVIRONMENT
Verifica a rede conectada
Tem que ser
Custom (43113) network

No Remix
Icon2 2 - FILE EXPLORER
Criar
CrossSourceMinter.sol

******************************* Início do código *******************************
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Fuji

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract CrossSourceMinter {

    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance to cover the fees.
    error NothingToWithdraw(); // Used when trying to withdraw but there's nothing to withdraw.

    IRouterClient public router;
    LinkTokenInterface public linkToken;
    uint64 public destinationChainSelector;
    address public owner;
    address public destinationMinter;

    event MessageSent(bytes32 messageId);

    constructor(address destMinterAddress) {
        owner = msg.sender;

        // https://docs.chain.link/ccip/supported-networks/testnet

        // from Fuji
        address routerAddressFuji = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
        router = IRouterClient(routerAddressFuji);
        linkToken = LinkTokenInterface(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
        linkToken.approve(routerAddressFuji, type(uint256).max);

        // to Sepolia
        destinationChainSelector = 16015286601757825753;
        destinationMinter = destMinterAddress;
    }

    function mintOnSepolia() external {
        // Mint from Fuji network = chain[1]
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(destinationMinter),
            data: abi.encodeWithSignature("mintFrom(address,uint256)", msg.sender, 1),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 980_000})
            ),
            feeToken: address(linkToken)
        });        

        // Get the fee required to send the message
        uint256 fees = router.getFee(destinationChainSelector, message);

        if (fees > linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(linkToken.balanceOf(address(this)), fees);

        bytes32 messageId;
        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend(destinationChainSelector, message);
        emit MessageSent(messageId);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function linkBalance (address account) public view returns (uint256) {
        return linkToken.balanceOf(account);
    }

    function withdrawLINK(
        address beneficiary
    ) public onlyOwner {
        uint256 amount = linkToken.balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        linkToken.transfer(beneficiary, amount);
    }
}
```
***************************** Fim do código *****************************

#### Explicando o contrato CrossChainPriceNFT.sol

1. Licença e Pragma
- // SPDX-License-Identifier: MIT: Define a licença MIT usada pelo contrato.
- pragma solidity 0.8.19;: Especifica a versão Solidity utilizada para compilar o contrato (versão 0.8.19).

2. Importações
- import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";: Importa a interface IRouterClient da biblioteca Chainlink CCIP para interagir com o roteador CCIP.
- import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";: Importa a biblioteca Client da Chainlink CCIP para auxiliar na construção e envio de mensagens CCIP.
- import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";: Importa a interface LinkTokenInterface para interagir com o contrato do token LINK da Chainlink.

3. Contrato CrossSourceMinter
- contract CrossSourceMinter { ... }: Define o contrato CrossSourceMinter responsável por enviar mensagens de cunhagem de NFT para outra blockchain.

4. Definição de Erros Personalizados
- Define dois erros personalizados para fornecer mensagens de reversão mais informativas:
    - NotEnoughBalance: Indica que o contrato não tem saldo suficiente para cobrir as taxas de envio da mensagem.
    - NothingToWithdraw: Indica que não há saldo de LINK para ser retirado. 

5. Variáveis de Estado
- IRouterClient public router;: Armazena o endereço do roteador CCIP com o qual o contrato se comunica.
LinkTokenInterface public linkToken;: Armazena o endereço do contrato do token LINK da Chainlink.
uint64 public destinationChainSelector;: Armazena o identificador da blockchain destino (Sepolia neste caso).
- address public owner;: Armazena o endereço do proprietário do contrato.
- address public destinationMinter;: Armazena o endereço do contrato de cunhagem de NFT na blockchain destino.

6. Evento MessageSent
- Define um evento para registrar o envio de uma mensagem CCIP e seu identificador.

7. Construtor (constructor)
- constructor(address destMinterAddress) { ... }: O construtor recebe o endereço do contrato de cunhagem de NFT na blockchain destino como argumento e:
    - Define o endereço do proprietário do contrato como o remetente da transação (msg.sender).
    - Carrega os endereços do roteador CCIP e do contrato LINK na rede Fuji a partir de valores codificados (não use em produção).
    - Aprova o gasto ilimitado de LINK para o roteador CCIP (somente para fins de demonstração).
    - Define o identificador da blockchain destino (Sepolia).
    - Define o endereço do contrato de cunhagem de NFT na blockchain destino. 

8. Função mintOnSepolia
- function mintOnSepolia() external { ... }: Esta função pública permite solicitar a cunhagem de um NFT na blockchain destino (Sepolia).
    - Constrói uma mensagem CCIP do tipo EVM2AnyMessage para solicitar a cunhagem:
    - Define o endereço do contrato de cunhagem de NFT na blockchain destino como receptor da mensagem.
    - Codifica a chamada à função mintFrom do contrato de cunhagem de NFT, passando o endereço do remetente da transação (msg.sender) e o ID da rede Fuji (1).
    - Define que não há tokens para enviar junto com a mensagem.
    - Define os argumentos extras da mensagem, incluindo o limite de gás desejado (980_000).
    - Define o token LINK como token de pagamento das taxas.
- Obtém a taxa necessária para enviar a mensagem usando router.getFee.
- Verifica se o contrato possui saldo suficiente de LINK para pagar as taxas.
- Envia a mensagem CCIP usando router.ccipSend e armazena o identificador da mensagem.
- Emite o evento MessageSent para indicar que a mensagem foi enviada com sucesso.

9. Modificador onlyOwner
- modifier onlyOwner() { ... }: Este modificador restringe a execução de uma função ao proprietário do contrato. 

10. Função linkBalance
- function linkBalance (address account) public view returns (uint256) { ... }: Esta função pública retorna o saldo de LINK de um determinado endereço.

11. Função withdrawLINK
- function withdrawLINK(address beneficiary) public onlyOwner { ... }: Esta função pública permite que o proprietário do contrato retire o saldo de LINK do contrato para um endereço especificado.
    - Verifica se há saldo de LINK para retirar.
    - Transfere o saldo de LINK para o endereço do beneficiário.

---------------------------------------------------------------------------------------
Deploy
Parametro: CrossDestinationMinter address
(contrato que voce publicou antes, na Sepolia)

Nome - CrossSourceMinter address
Sol - 0x08dFEBD8f2868cb724A578f8368F62678489d4Af
Pedr0x - 0x6e5FB12622F1B897ae14e702A88174C6aBd51676
Marina - 0x58D21d4ce5cc1F0A53c8751e46AAcDA841944509
Raphael - 0x72f541e792575EA506E3f698112CDA4d41df26Fa
Jeff Souza - 0x74B6C42ed5859A8d73A0D641090273841A276D06
José Aldo - 0xB1A040A19ae367BDDF506Cdc34CcEca32cDdd551
Alexandre Eduardo - 0x47b423a3a0EAD547f2f3312fCFE6307666cC64AA


Add LINK na Fuji - Metamask
0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846

No Metamask
Enviar 5 LINK para o endenreco do CrossSourceMinter 

No Remix
Executar
MintOnSepolia

No Metamask - copy transaction id
Nome - TX Id
Sol - 0x3f1f977382549bbf795941bb67e479a4090af18138196759f96ad64b17288be2
Raphael - 0xa83ddbfa9517e5012ebb5eac8e3ebc1ee1b5784e9b45850de3d36d996b72a712
Marina -
0xc17099b7ec1562070c35b0eeedbede3966313c87beb2cb7fe4963cebe7862ce5
0x013397aeedff03a240bf827914828855afb53c4d2159489d99d396d2d6dd6136
Jeff Souza - 0x279c7f7d072dac29e6759964c8c8965348111aee63bbeb541ce2009c392dbb03
Sol2 - 0x0d5fe63d8e495550415546104db3fd4d826d6fb4032c47bb903e6e6afe847e33
Alexandre Eduardo - 0x56d0a8b53c239783d9f55cb933f9c0620beb21c2e5bc15b7f45e945e7adc2679
Pedr0x - 0x6e2a9099c5f131586f2b400523e4cbe22db4180a623f1542095c5c238471ca2d
José Aldo - 0x33c2ce8abc6ea6da9a3986ced48bd3e8cceda277ceaa06e277591bab613ce712
*******************************************

https://ccip.chain.link/
Pesquisar o hash da transacao