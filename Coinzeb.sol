/**
 *Submitted for verification at polygonscan.com on 2024-08-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Coinzeb is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public blockedAccounts;
    mapping(address => bool) public exchangeAccounts;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    bool private _isTransferAllowed;

    uint256 public transferLimit;
    uint256 public maxWalletLimit;
    uint256 public minWalletLimit;
    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;

    constructor() {
        _name = "Coinzeb";
        _symbol = "CZB";
        _decimals = 18;
        _totalSupply = 100000000 * 10 ** _decimals;
        transferLimit = _totalSupply * 10 ** _decimals;
        maxWalletLimit = _totalSupply * 10 ** _decimals;
        minWalletLimit = 0 * 10 ** _decimals;

        maxBuyLimit = _totalSupply * 10 ** _decimals;
        maxSellLimit = _totalSupply * 10 ** _decimals;

        _isTransferAllowed = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function changeTransferFlag(bool _flag) external {
        _isTransferAllowed = _flag;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function setMaxBuyLimit(uint256 _limit) external onlyOwner returns (bool) {
        maxBuyLimit = _limit * 10 ** _decimals;
        return true;
    }

    function setMaxSellLimit(uint256 _limit) external onlyOwner returns (bool) {
        maxSellLimit = _limit * 10 ** _decimals;
        return true;
    }

    function blockAccount(address _address) external onlyOwner returns (bool) {
        blockedAccounts[_address] = true;
        return true;
    }

    function unBlockAccount(
        address _address
    ) external onlyOwner returns (bool) {
        blockedAccounts[_address] = false;
        return true;
    }

    function setExchangeAccount(
        address _address
    ) external onlyOwner returns (bool) {
        exchangeAccounts[_address] = true;
        return true;
    }

    function unsetExchangeAccount(
        address _address
    ) external onlyOwner returns (bool) {
        exchangeAccounts[_address] = false;
        return true;
    }

    function setMaxWalletLimit(
        uint256 _limit
    ) external onlyOwner returns (bool) {
        maxWalletLimit = _limit * 10 ** _decimals;
        return true;
    }

    function setMinWalletLimit(
        uint256 _limit
    ) external onlyOwner returns (bool) {
        minWalletLimit = _limit * 10 ** _decimals;
        return true;
    }

    function setTransferLimit(
        uint256 _limit
    ) external onlyOwner returns (bool) {
        transferLimit = _limit * 10 ** _decimals;
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            _isTransferAllowed || owner() == _msgSender(),
            "Transfer is disabled."
        );
        require(!blockedAccounts[sender], "Sender account is blocked.");
        require(!blockedAccounts[recipient], "Recipient account is blocked.");
        require(
            amount <= transferLimit || owner() == _msgSender(),
            "Transfer amount exceeds the transfer limit."
        );
        require(
            _balances[recipient].add(amount) <= maxWalletLimit,
            "Recipient balance exceeds maximum wallet limit."
        );
        require(
            _balances[sender].sub(amount) >= minWalletLimit,
            "Sender balance falls below minimum wallet limit."
        );
        require(
            !exchangeAccounts[sender] || amount <= maxBuyLimit,
            "Buy amount exceeds the buy limit."
        );
        require(
            !exchangeAccounts[recipient] || amount <= maxSellLimit,
            "Sell amount exceeds the sell limit."
        );
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            amount <= _allowances[sender][_msgSender()],
            "Transfer amount exceeds allowance"
        );

        _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]
            .sub(amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "Insufficient BNB balance");
        payable(_msgSender()).transfer(weiAmount);
    }

    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }
}
