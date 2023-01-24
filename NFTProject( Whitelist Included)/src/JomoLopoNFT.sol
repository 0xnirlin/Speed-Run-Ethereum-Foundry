// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

//custome errors as these are more efficient than the revert strings
error AlreadyMinted();
error MintLimitReached();
error NotEnoughEthSent();
error NotWhitelisted();
error PublicMintDisabled();
error PrivateMintDisabled();
error DevMintDisabled();
error withdrawError();

contract JomoLopoNft is ERC721, Ownable {
    //enumerable for the mint state
    enum MintState {
        PrivateMint,
        PublicMint,
        DevMint,
        Paused
    }
    //variables to keep track of everything
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public tokenId = 0;
    string private baseTokenURI;
    MintState public mintState;

    //mappings

    //mapping for the list of white list addressses.
    mapping(address => bool) public whitelistAddresses;
    //created a mapping of address to the uint256 for the tokens minted
    mapping(address => bool) public tokenMinted;

    constructor(string memory _baseTokenUri) ERC721("JomoLopoNFT", "JL") {
        baseTokenURI = _baseTokenUri;
    }

    //first override the token uri function
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    //set the whitelist addresses. This can be also done more gas efficiently and cryptographically.
    function seedWhitelists(address[] memory _addresses) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelistAddresses[_addresses[i]] = true;
        }
    }

    //function that allow the deployer to mint 25 at once for the dev team
    function devMint(uint256 _amount) public payable onlyOwner {
        // uint256 localtokenId = tokenId;
        if (mintState != MintState.DevMint) {
            revert DevMintDisabled();
        }
        require(_amount <= 25, "You can mint 25 at a time");
        require(totalSupply() + _amount <= MAX_SUPPLY, "Exceeds MAX_SUPPLY");
        for (uint256 i = 0; i < _amount; i++) {
            tokenId++;
            _safeMint(msg.sender, totalSupply());
        }
        //withdraw all the eth to msg.sender using call
        // tokenId = localtokenId;
    }

    function mint() external payable {
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }

    //function that allow the public to mint the nft.
    function publicMint() public payable {
        if (mintState != MintState.PublicMint) {
            revert PublicMintDisabled();
        }
        if (tokenMinted[msg.sender] == true) {
            revert AlreadyMinted();
        }
        if (totalSupply() + 1 > MAX_SUPPLY) {
            revert MintLimitReached();
        }
        if (msg.value < 0.01 ether) {
            revert NotEnoughEthSent();
        }

        tokenMinted[msg.sender] = true;
        tokenId++;
        _safeMint(msg.sender, totalSupply());
    }

    // function to allow the whitelisted addresses to mint the nft
    function whitelistMint() public payable {
        if (mintState != MintState.PrivateMint) {
            revert PrivateMintDisabled();
        }
        if (whitelistAddresses[msg.sender] == false) {
            revert NotWhitelisted();
        }
        if (tokenMinted[msg.sender] == true) {
            revert AlreadyMinted();
        }
        if (totalSupply() + 1 > MAX_SUPPLY) {
            revert MintLimitReached();
        }
        if (msg.value < 0.01 ether) {
            revert NotEnoughEthSent();
        }
        tokenMinted[msg.sender] = true;
        whitelistAddresses[msg.sender] = false; //remove from whitelist
        _safeMint(msg.sender, totalSupply());
        tokenId++;
    }

    // function that get the current total supply aka. Total minted.
    function totalSupply() public view returns (uint256) {
        return tokenId;
    }

    //function that set the mintState as publicMint, private-mint or dev-mint. If one is disabled respective function for minting cannot be called.
    function setMintState(MintState _mintState) public onlyOwner {
        mintState = _mintState;
    }

    //setter getter
    function getBaseTokenURI() public view returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public {
        baseTokenURI = _baseTokenURI;
    }

    //necessary functions

    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert withdrawError();
    }

    fallback() external payable {}

    receive() external payable {}

    //use the slither to detect the vulnerabilities
}


