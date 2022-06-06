// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";
    import "./CasesAndKeys.sol";
    import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
    import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
    
    contract Weapons is ERC721, VRFConsumerBaseV2, Ownable  {

    using Strings for uint256;

    /*
        Variables
    */

    CasesAndKeys public _CasesAndKeys;

    /*
        Chainlink VRF Setup
        Current Setup: Polygon Test
    */

    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  2;
    uint256 public s_requestId;

    /*
        Constructors
    */

    constructor (address CasesAndKeys_, uint64 subscriptionId) ERC721 ("PolyStrike Weapons: Series 1", "PolyStrike Weapons: Series 1") VRFConsumerBaseV2(vrfCoordinator) {
        _CasesAndKeys = CasesAndKeys(CasesAndKeys_);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    } 

    /*
        Mint
    */

    struct userInfo {
        address caller;
        uint256 caseId;
    }

    event minted (uint256 tokenId, uint256 float, address caller);

    mapping(uint256 => userInfo) public requestToUser;

    function OpenCase (uint256 _caseId) public {
        require (_CasesAndKeys.balanceOf(msg.sender, _caseId) > 0);
        require (_CasesAndKeys.balanceOf(msg.sender, _caseId + 1) > 0);
        requestRandomWords(msg.sender, _caseId);
    }

    function _handleCase (address _caller, uint256 _caseId, uint256[] memory randomNums) internal {
        require (_CasesAndKeys.balanceOf(msg.sender, _caseId) > 0);
        require (_CasesAndKeys.balanceOf(msg.sender, _caseId + 1) > 0);
        _CasesAndKeys.whitelistTransfer(_caller, address(this), _caseId, 1, '');
        _CasesAndKeys.whitelistTransfer(_caller, address(this), _caseId + 1, 1, '');
        uint256 itemId = randomIndex(randomNums[0]);
        uint256 float = (randomNums[0] % (10 ** 23)) + 1;
        _safeMint(msg.sender, itemId);
        itemFloat[itemId] = float;
        numTokens++;
        emit minted(_caseId, float, _caller);
    }

        uint public constant TOKEN_LIMIT = 10000000;

        uint numTokens = 0;

        uint[TOKEN_LIMIT] internal indices;

        uint nonce = 0;

    function randomIndex(uint256 num) public returns (uint) {

        uint totalSize = TOKEN_LIMIT - numTokens;
        uint index = num % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }

        // Move last value to selected position
        if (indices[totalSize - 1] == 0) {
            // Array position not initialized, so use position
            indices[index] = totalSize - 1;
        } else {
            // Array position holds a value so use that
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        numTokens ++;

        // Don't allow a zero index, start counting at 1
        return value + 1;

    }





    function requestRandomWords(address _caller, uint256 _caseId) internal  {
    uint256 requestId = COORDINATOR.requestRandomWords(
    keyHash,
    s_subscriptionId,
    requestConfirmations,
    callbackGasLimit,
    numWords
    );
    requestToUser[requestId] = userInfo(_caller, _caseId);
    }

    function fulfillRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
    ) internal override {
  // Assuming only one random word was requested.
    //s_randomRange = (randomWords[0] % 50) + 1;
    }

    /*
        Token Uri
    */

    string public baseUri;

    mapping(uint256 => uint256) public itemFloat; //divide by 10 ** 23 for true float

    function tokenURI(uint256 _tokenId) public virtual override view returns (string memory) {
        return string(abi.encodePacked(baseUri, Strings.toString(_tokenId)));
    }

    function setUri (string memory newUri) public onlyOwner {
        baseUri = newUri;
    }

    }