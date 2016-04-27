contract TokenInterface {

  struct User {
    bool locked;
    uint256 balance;
    uint256 badges;
    mapping (address => uint256) allowed;
  }

  mapping (address => User) users;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;

  address config;
  address owner;
  address dao;
  bool locked;

  /// @return total amount of tokens
  uint256 public totalSupply;
  uint256 public totalBadges;

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) constant returns (uint256 balance);

  /// @param _owner The address from which the badge count will be retrieved
  /// @return The badges count
  function badgesOf(address _owner) constant returns (uint256 badge);

  /// @notice send `_value` tokens to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) returns (bool success);

  /// @notice send `_value` badges to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function sendBadge(address _to, uint256 _value) returns (bool success);

  /// @notice send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens on its behalf
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens of _owner that _spender is allowed to spend
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  /// @notice mint `_amount` of tokens to `_owner`
  /// @param _owner The address of the account receiving the tokens
  /// @param _amount The amount of tokens to mint
  /// @return Whether or not minting was successful
  function mint(address _owner, uint256 _amount) returns (bool success);

  /// @notice mintBadge Mint `_amount` badges to `_owner`
  /// @param _owner The address of the account receiving the tokens
  /// @param _amount The amount of tokens to mint
  /// @return Whether or not minting was successful
  function mintBadge(address _owner, uint256 _amount) returns (bool success);

  function registerDao(address _dao) returns (bool success);

  function registerSeller(address _tokensales) returns (bool success);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event SendBadge(address indexed _from, address indexed _to, uint256 _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract swap{
    address public beneficiary;
    TokenInterface public tokenReward;
    uint public price_tokens;
    uint public amountRaised;
    mapping (address => uint) public contributions;
    uint256 public WEI_PER_ETH = 1000000000000000000;
    uint public expiryDate;
    
    // Constructor function for this contract. Called during contract creation
    function swap(address _tokenAddress, address _beneficiary, uint _price, uint _durationInDays){
        amountRaised = msg.value;
        beneficiary = _beneficiary;
        tokenReward = TokenInterface(_tokenAddress);
        price_tokens = _price * WEI_PER_ETH;
        expiryDate = now + _durationInDays * 1 days;
    }
    
    // This function is called every time some one sends ether to this contract
    function(){
        if (now >= expiryDate) throw;
        var tokens_to_send = msg.value/price_tokens;
        uint balance = tokenReward.balanceOf(this);
        address payee = msg.sender;
        if (balance >= tokens_to_send){
            tokenReward.transfer(msg.sender, tokens_to_send);
            beneficiary.send(msg.value);    
        } else {
            tokenReward.transfer(msg.sender, balance);
            var amountReturned = (tokens_to_send - balance) * price_tokens;
            payee.send(amountReturned);
            beneficiary.send(msg.value - amountReturned);
        }
    }
    
    modifier afterExpiry() { if (now >= expiryDate) _ }
    
    function checkExpiry() afterExpiry{
        uint balance = tokenReward.balanceOf(this);
        tokenReward.transfer(beneficiary, balance);
    }
}

