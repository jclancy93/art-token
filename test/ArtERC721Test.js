const tokenContract = artifacts.require('./ArtERC721.sol');
const BigNumber = web3.BigNumber;

contract('ArtERC721', accounts => {
	console.log(accounts)
	let owner = accounts[0];
	let artworks;
	let price = new web3.BigNumber(10000000000000000)

	beforeEach(async function() {
		artworks = await tokenContract.new({ from : owner });
	});

	it('has correct owner', async function() {
		const actualOwner = await artworks.owner()
		assert.equal(actualOwner, owner)
	});

	describe('can create new artworks', () => {
		let url = "test.com";
		let title = "test art";
		let price = new web3.BigNumber(10);
		let forSale = false;
		let tx; 

		beforeEach(async function() {
		  tx = await artworks.createArtwork(title, url, price, forSale, {from:owner, gas: "300000"})
		});

		it('can mint new artwork', async function() {
		  assert(artworks.ownerOf(1), owner)
		  console.log(tx.logs)
		  assert.equal(tx.logs[0].event, 'Transfer')
		})

	    it('can retrieve art tokens for the owner', async function() { 
	      let tokens = await artworks.tokensOf(owner)
	      assert.equal(tokens.length, 1)
	    })

	    it('can retrieve artwork metadata', async function() { 
	      let artwork = await artworks.getArtwork(0);
	      assert.equal(artwork[4], url)
	    })
	});

	describe('can update artwork values', () => {
		let title = "test art";
		let price = new web3.BigNumber(10);
		let url = "ethereum.com";
		let newPrice = new web3.BigNumber(100);
		let forSale = false;
		let newForSale = true;
		let tx; 

		beforeEach(async function() {
		  tx = await artworks.createArtwork(title, url, price, forSale, {from:owner, gas: "300000"})
		});

		it('can update artwork price', async function() {
			let update = await artworks.updateArtworkPrice(0, newPrice)
	        let artwork = await artworks.getArtwork(0);
	        assert.equal(artwork[3], 100)
		})

		it('can update artwork sale status', async function() {
			let update = await artworks.updateSaleStatus(newForSale, 0);
			let artwork = await artworks.getArtwork(0);
			assert.equal(artwork[5], newForSale)
		})
	})
})