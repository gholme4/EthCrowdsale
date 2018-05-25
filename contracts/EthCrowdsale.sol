pragma solidity ^0.4.0;


import "./ERC223ReceivingContract.sol";
import "./SafeMath.sol";
import "./EthToken.sol";

contract EthCrowdsale is ERC223ReceivingContract {

	using SafeMath for uint;

	EthToken private _token;

	uint private _available;
	uint private _price;
  	uint private _limit;
  	uint private _isActive;
	address private _creator;

	event Buy(address beneficiary, uint amount);

	modifier available() {
		require(_available > 0);
  	}

  	modifier available() {
		require(_creator == msg.sender);
  	}

  	modifier isActive() {
		require(_isActive == true);
  	}

  	modifier valid(address to, uint amount) {
		assert(amount > 0);
		amount = amount.div(_price);
		assert(_limit >= amount);
		assert(_limit >= _limits[to].add(amount));
		_;
	}

	constructor(address token, uint price, uint limit) {
		_token = EthToken(token);
		_price = price;
		_limit = limit;
		_creator = msg.sender;
	}

	function active (bool activeStatus) public available {
		_isActive = activeStatus;
	}

	function () payable {
		// Not enough gas for the transaction so prevent users from sending ether
		revert();
	}

	function buy() isActive external payable {
		return buyFor(msg.sender);
  	}

  	function buyFor(address beneficiary) 
  		public
		available
		isActive
		valid(beneficiary, msg.value)
		payable {

			uint amount = msg.value.div(_price);
			_token.transfer(beneficiary, amount);
			_available = _available.sub(amount);
			_limits[beneficiary] = _limits[beneficiary].add(amount);
			emit Buy(beneficiary, amount);
	}

	function tokenFallback(address, uint value, bytes) isToken public {
		
		_available = _available.add(value);
  	}

  	function availableBalance() external view returns (uint) {
		return _available;
  	}
}