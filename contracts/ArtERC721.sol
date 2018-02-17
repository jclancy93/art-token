pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ArtERC721 is ERC721Token, Ownable {

  struct Art {
    uint64 createdAt;
    string title;
    address originalCreator;
    uint256 price;
    string url;
    bool forSale;
  }

  Art[] public artworks;

  mapping(uint => address) public artworkToOwner;
  mapping(address => uint) public ownerArtworkCount;


  //gets metadata for a given piece of art
  function getArtwork(uint256 _id)
    external 
    view
    returns (
      uint64 createdAt,
      string title,
      address originalCreator,
      uint256 price,
      string url,
      bool forSale
	) {
      Art storage artwork = artworks[_id];

      createdAt = uint64(artwork.createdAt);
      title = string(artwork.title);
      originalCreator = address(artwork.originalCreator);
      price = uint256(artwork.price);
      url = string(artwork.url);
      forSale = bool(artwork.forSale);
	}

  // minting of new artwork tokens
  function createArtwork(
  	string _title,
  	string _url,
  	uint256 _price,
  	bool _forSale
  ) 
    public
    returns (uint256)
 {

  	Art memory _artwork = Art({
 	  createdAt: uint64(now),
 	  title: string(_title),
 	  originalCreator: address(msg.sender),
 	  price: uint256(_price),
 	  url: string(_url),
 	  forSale: bool(_forSale)
 	});

  	address originalCreator = msg.sender;
  	uint256 id = artworks.push(_artwork);
  	artworkToOwner[id - 1] = originalCreator;
  	ownerArtworkCount[msg.sender]++;
  	_mint(msg.sender, id);
  	return id - 1;
  }

  function checkOwner(uint256 _artworkId) external view returns (address) {
  	return artworkToOwner[_artworkId];
  }

  // checks if the claimant owns the token
  function _owns(address _claimant, uint256 _artworkId) internal view returns (bool) {
    return artworkToOwner[_artworkId] == _claimant;
  }

  // checks if artwork is marked for sale
  function _forSale(uint256 _artworkId) internal view returns (bool) {
  	return artworks[_artworkId].forSale;
  }

  // allows owner of artwork to update the sale price
  function updateArtworkPrice(uint256 _artworkId, uint256 _newPrice) {
  	require(msg.sender == artworkToOwner[_artworkId]);
  	artworks[_artworkId].price = _newPrice;
  }

  // allows owner of artwork to change the sale status
  function updateSaleStatus(bool _saleStatus, uint256 _artworkId) {
  	require(msg.sender == artworkToOwner[_artworkId]);
  	require(_saleStatus != artworks[_artworkId].forSale);
  	artworks[_artworkId].forSale = _saleStatus;
  }

  // transfer token to a new address 
  function _transfer(address _from, address _to, uint256 _artworkId) internal {
  	// Safety check to prevent against unexpected 0x0 default
  	require(_to != address(0));

  	// make sure only owner calls this function
  	// require(_owns(msg.sender, _artworkId));

  	// always mark a newly transferred artwork as not for sale
  	artworks[_artworkId].forSale = false;

  	// transfer ownership 
  	artworkToOwner[_artworkId] = _to;

  	// increment/decrement owner count
  	ownerArtworkCount[_to]++;
  	ownerArtworkCount[msg.sender]--;

    Transfer(_from, _to, _artworkId);
  }

  // function purchase(uint256 _artworkId) external payable {
  // 	require
  // }


}