const ArtERC721 = artifacts.require("./ArtERC721.sol");

module.exports = function(deployer) {
  deployer.deploy(ArtERC721);
};
