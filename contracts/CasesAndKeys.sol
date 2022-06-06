// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
    import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
    import "@openzeppelin/contracts/utils/Strings.sol";
    
    contract CasesAndKeys is ERC1155, ReentrancyGuard, Ownable  {

    using Strings for uint256;

    /*
        Variables
    */

    uint256 public mintPrice = 25 * 10 ** 17;
    bool public isSaleStarted = false;
    uint256 public rate = 43200;

    /*
        Mappings
    */

    mapping(uint256 => bool) public isCaseOffered;
    mapping(address => uint256) public nextClaim;
    mapping (address => bool) public isAdressWhitelisted;

    /*
        Constructors
    */

    constructor () ERC1155 ("uri") {} 

    /*
        Claim and Mint
    */

    function claimCase (uint256 _caseId) public nonReentrant () {
        require (isSaleStarted);
        require (isCaseOffered[_caseId]);
        require (block.number >= nextClaim[msg.sender]);
        _mint(msg.sender, _caseId, 1, '');
        nextClaim[msg.sender] += rate;
    }

    function mintKey (uint256 _keyId, uint256 _amount) public payable {
        require (isSaleStarted);
        require (msg.value == _amount * mintPrice);
         _mint(msg.sender, _keyId, _amount, '');
    }

    /*
        whitelist transfer
    */

    function whitelistAddress (address _newAddress) public onlyOwner {
        isAdressWhitelisted[_newAddress] = true;
    }

    function whitelistTransfer (address from, address to, uint256 id, uint256 amount, bytes memory data) external {
        require ( isAdressWhitelisted[msg.sender]);
         _safeTransferFrom(from, to, id, amount, data);
    }

    /*
        Uri
    */

    string public _baseURI;

    function uri(uint256 _id)  public view virtual override returns (string memory) {
        string memory base = baseURI();
        return string(abi.encodePacked(base, Strings.toString(_id)));
    }

    function _setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }
    
    function baseURI() internal virtual view returns (string memory) {
        return _baseURI;
    }

    /*
        Setters
    */

    function setPrice (uint256 _newPrice) public onlyOwner {
        mintPrice = _newPrice;
    }

    function setRate (uint256 _newRate) public onlyOwner {
        rate = _newRate;
    }

    function setRate (bool _newStatus) public onlyOwner {
        isSaleStarted = _newStatus;
    }

    function setCaseOffered (uint256 _caseId, bool _newStatus) public onlyOwner {
        isCaseOffered[_caseId] = _newStatus;
    }

    /*
        Withdraw
    */

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    }