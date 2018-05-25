var EthToken = artifacts.require("./EthToken.sol");
var EthCrowdsale = artifacts.require("./EthCrowdsale.sol");

module.exports = function(deployer) {
	deployer.deploy(EthToken, "MVT", "My Valuable Token", 18, 10000, true, {gas: 4600000}).then(() => {
		return deployer.deploy(
			EthCrowdsale,
			EthToken.address,
			web3.eth.blockNumber,
			web3.eth.blockNumber+1000,
			web3.toWei(1, 'ether'),
			1
		).then(() => {});
		
	});
};
