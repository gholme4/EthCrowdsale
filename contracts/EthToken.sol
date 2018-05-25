pragma solidity ^0.4.0;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./ERC223.sol";
import "./ERC223ReceivingContract.sol";

contract EthToken is ERC20, ERC223  {
	using SafeMath for uint;

    address private _owner;

    string internal _symbol;
    string internal _name;
    uint8 internal  _decimals;
    uint internal _totalSupply;
    bool internal _canMint; 
    
    mapping (address => uint) private _balanceOf;
    mapping (address => mapping (address => uint)) private _allowances;

    /**
    * Only creator of contract has access
    */
    modifier isOwner() {
        require(_owner == msg.sender);
        _;
    }

    /**
    * Only owner can create more token
    */
    modifier ownerCanMint() {
        require(_owner == msg.sender);
        require(_canMint == true);
        _;
    }
    
    constructor(string symbol, string name, uint8 decimals, uint totalSupply, bool canMint)  {
		_symbol = symbol;
		_name = name;
		_decimals = decimals;
		_totalSupply = totalSupply;
		_canMint = canMint;

		_balanceOf[msg.sender] = _totalSupply;
		_owner = msg.sender;
    }

    /**
    *	Create more tokens
    */
    function mint(uint amount) public ownerCanMint {

    	_totalSupply = _totalSupply.add(amount);
    	_balanceOf[_owner] = _balanceOf[_owner].add(amount);

    }
    
    /**
    * Get total supply of tokens in circulation
    */
    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }
    
    /**
    * Get token balance of address
    */
    function balanceOf(address addr) external view returns (uint) {
        return _balanceOf[addr];
    }
	
	/**
    * Transfer tokens to address (ERC20)
    */    
    function transfer(address to, uint value) external returns (bool) {
        if (value > 0 && 
            value <= _balanceOf[msg.sender] && 
            !isContract(to)) {

            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
            _balanceOf[to] = _balanceOf[to].add(value);
            
            emit Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }
    
    /**
    * Transfer tokens to address (ERC223)
    */  
    function transfer(address to, uint value, bytes data) external returns (bool) {
        if (value > 0 && 
            value <= _balanceOf[msg.sender] && 
            isContract(to)) {

            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
            _balanceOf[to] = _balanceOf[to].add(value);

            ERC223ReceivingContract _contract = ERC223ReceivingContract(to);
            _contract.tokenFallback(msg.sender, value, data);

            emit Transfer(msg.sender, to, value, data);

            return true;
        }
        return false;
    }

    /**
    * Determine if address is a contract
    */  
    function isContract(address addr) internal view returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        
        return codeSize > 0;
    }
    
    /**
    * Transfer tokens to address on behalf of another address
    */
    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (_allowances[from][msg.sender] > 0 &&
            value > 0 &&
            _allowances[from][msg.sender] >= value && 
            _balanceOf[from] >= value) {

            _balanceOf[from] =  _balanceOf[from].sub(value);
            _balanceOf[to] = _balanceOf[to].add(value);
            
            _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
            return true;
        }

        return false;
    }
    
    /**
    * Approve the transfor of tokens by another address
    */
    function approve(address spender, uint value) external returns (bool) {
        if (_balanceOf[msg.sender] >= value) {

            _allowances[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;
        }

        return false;
    }
    
    /**
    * Check allowance of address that can transfer tokens on behalf of an address
    */
    function allowance(address owner, address spender) external view returns (uint) {
        if (_allowances[owner][spender] < _balanceOf[owner]) {
            return _allowances[owner][spender];
        }

        return _balanceOf[owner];

    }
   
}