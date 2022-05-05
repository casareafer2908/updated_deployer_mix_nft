// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBaseV2, Ownable {
    //vrf coordinator stuff
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    bytes32 internal keyHash;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    //Contract variables
    uint256 public tokenCounter;
    using Strings for uint256;
    enum Style {
        KATANA,
        SPARKS,
        SWORD,
        THUNDER,
        WATER
    }
    // add other things
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => string) public requestIdToTokenURI;
    mapping(uint256 => Style) public tokenIdToStyle;
    mapping(uint256 => uint256) public requestIdToTokenId;
    event RequestedCollectible(uint256 indexed requestId);
    // New event from the video!
    event ReturnedCollectible(
        uint256 indexed requestId,
        uint256[] randomNumber
    );
    string internal uriPrefix =
        "https://ipfs.io/ipfs/QmZZa5TP4MWw7inj2ZMqbz9yG8279ayMAa4gEbZq2Kycqg?filename=loading.gif";

    constructor(
        address vrfCoordinator,
        address _LinkToken,
        bytes32 _keyhash,
        uint64 subscriptionId
    )
        public
        VRFConsumerBaseV2(vrfCoordinator)
        ERC721("SecondCollection", "sex&thecity")
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        tokenCounter = 0;
        keyHash = _keyhash;
    }

    function createCollectible() public returns (bytes32) {
        //gets random number from chainlink oracle
        s_owner = msg.sender;
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        //maps the caller address with the randomness request
        requestIdToSender[s_requestId] = msg.sender;
        emit RequestedCollectible(s_requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomNumber
    ) internal override {
        //pulls the caller address from memory
        address tokenOwner = requestIdToSender[requestId];

        //gets the next token id
        uint256 newItemId = tokenCounter;
        //kaboooom
        _safeMint(tokenOwner, newItemId);
        //sets tokenuri
        string memory _tokenUri = tokenURI(newItemId);
        //maps the tokenUri to the requestID
        requestIdToTokenURI[requestId] = _tokenUri;
        //pics a style using the random number
        Style style = Style(randomNumber[0] % 5);
        //maps the style of the {tokenid}
        tokenIdToStyle[newItemId] = style;
        //maps the {tokenid} to the request
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(requestId, randomNumber);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return
            //base uri will never be under 0 lenght because I initialized it with the loading cat
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }
}
