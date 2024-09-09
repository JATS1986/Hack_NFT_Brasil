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

// Inicio

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

// Fim

#### Explicando o contrato CrossChainPriceNFT.sol

1. 

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

// Inicio

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

// Fim

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

// Inicio

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

// Fim

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