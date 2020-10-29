pragma solidity 0.5.11;

// contract addrees in Rinkeby 0xCD8AC5fAE0Fdc49DDC12d60511A86DD41CcAa654 
// интерфейс

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// библиотека ролей подключена к PauserRole
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   
   

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// инициализация
// contract Initializable {

//   /**
//    * @dev Indicates that the contract has been initialized.
//    */
//   bool private initialized;

//   /**
//    * @dev Indicates that the contract is in the process of being initialized.
//    */
//   bool private initializing;

//   /**
//    * @dev Modifier to use in the initializer function of a contract.
//    */
//   modifier initializer() {
//     require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

//     bool isTopLevelCall = !initializing;
//     if (isTopLevelCall) {
//       initializing = true;
//       initialized = true;
//     }

//     _;

//     if (isTopLevelCall) {
//       initializing = false;
//     }
//   }

//   /// @dev Returns true if and only if the function is running in the constructor
//   function isConstructor() private view returns (bool) {
//     // extcodesize checks the size of the code stored in an address, and
//     // address returns the current address. Since the code is still not
//     // deployed when running a constructor, any checks on its code size will
//     // yield zero, making it an effective way to detect if a contract is
//     // under construction or not.
//     uint256 cs;
//     assembly { cs := extcodesize(address) }
//     return cs == 0;
//   }


// }
contract Emergency is Ownable{

  address public one;
  address public two;
  address public three;
  address public resone;
  address public restwo;
  address public resthree;


  mapping(address => bool) internal signed;

  constructor() public {
    
    
    one = 0x67FeE44bD5dbBAC0A9e04CcB9665077ef86303fC;
    two = 0xfdDA5b712Ae3431E0342c7686100dCF8BeE601E9;
    three = 0x7c484df5B910FE40473529F44C078aA41d794bb6;
    
    require (one != address(0));
    require (two != address(0));
    require (three != address(0));
  }

  function Sign60() public {
    require (msg.sender == one);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }

  function Sign45() public {
    require (msg.sender == two);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }

  function Sign15() public {
    require (msg.sender == three);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }
  
  function CheckSign(address _user) external view returns (bool){
      return signed[_user];
  }

  modifier MultiOwners {
    require (signed[one] == true);
    require (signed[two] == true);
    require (signed[three] == true);
    _;  
  }

  function Back() internal{

    signed[one] = false;
    signed[two] = false;
    signed[three] = false;
    signed[resone] = false;
    signed[restwo] = false;
    signed[resthree] = false;
  }
}

// пауза от ownable
contract PauserRole is Emergency {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () public  {
        if (!isPauser(msg.sender)) {
            _addPauser(msg.sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    
}
// пауза от паузаРоль
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    
    constructor() internal  {
        
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract SafeMath{
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    
}







contract MyStream is SafeMath, Pausable{
    // Variables
    
    uint256 public nextStreamId;
    uint256 public fee;
    
     constructor() public {
        //require(cTokenManagerAddress != address(0x00), "cTokenManager contract is the zero address");
       
        //cTokenManager = ICTokenManager(cTokenManagerAddress);
        fee = 5;
        nextStreamId = 1;
    }
    
    
    
    //Mappings
    
    mapping(uint256 => Stream) private streams; 
    
    
    //Modifiers
    
     
    modifier onlySenderOrRecipient(uint256 streamId) {
        require(
            msg.sender == streams[streamId].sender || msg.sender == streams[streamId].recipient,
            "caller is not the sender or the recipient of the stream"
        );
        _;
    }

   
    modifier streamExists(uint256 streamId) {
        require(streams[streamId].isEntity, "stream does not exist");
        _;
    }
    
    
    
    // Structs
    
    struct Stream {
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 remainingBalance;// остаток баланса
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        address tokenAddress;
        bool isEntity; // объект
    }
    
    struct CreateStreamLocalVars {
        
        uint256 duration;
        uint256 ratePerSecond;
    }
    
    struct BalanceOfLocalVars {
        
        uint256 recipientBalance;
        uint256 withdrawalAmount;
        uint256 senderBalance;
    }
    
    
    
    // Events
    
    event CreateStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    );
    
    event CancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );
    
    event WithdrawFromStream(
        uint256 indexed streamId, 
        address indexed recipient, 
        uint256 amount
    );
    
    event FeeFromStream60(
        uint256 indexed streamId, 
        address indexed companyAccount, 
        uint256 fee60
    );
    
    event FeeFromStream25(
        uint256 indexed streamId, 
        address indexed companyAccount, 
        uint256 fee25
    );
    
    event FeeFromStream15(
        uint256 indexed streamId, 
        address indexed companyAccount, 
        uint256 fee_5
    );

    event TranferRecipientFromCancelStream(
        uint256 indexed streamId, 
        address indexed recipient, 
        uint256 clientAmount
    );

    event TranferSenderFromCancelStream(
        uint256 indexed streamId, 
        address indexed sender, 
        uint256 senderBalance

    );
    
    event newFee(
        uint256 newFee
    );
    
    event newCompanyAccount(
        address companyAccount
    );
    
    // Functions public TODO add pause
    
    function createStream(address recipient, uint256 deposit, address tokenAddress, uint256 startTime, uint256 stopTime) public  whenNotPaused returns (uint256) {
        
        require(recipient != address(0x00), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(deposit > 0, "deposit is zero");
        require(startTime >= block.timestamp, "start time before block.timestamp");
        require(stopTime > startTime, "stop time before the start time");

        CreateStreamLocalVars memory vars;
        vars.duration = sub(stopTime, startTime);
        

        /* Without this, the rate per second would be zero. */
        require(deposit >= vars.duration, "deposit smaller than time delta");

        /* This condition avoids dealing with remainders */
        require(deposit % vars.duration == 0, "deposit not multiple of time delta");

        vars.ratePerSecond = div(deposit, vars.duration);
        

        /* Create and store the stream object. */
        uint256 streamId = nextStreamId;
        streams[streamId] = Stream({
            remainingBalance: deposit,
            deposit: deposit,
            isEntity: true,
            ratePerSecond: vars.ratePerSecond,
            recipient: recipient,
            sender: msg.sender,
            startTime: startTime,
            stopTime: stopTime,
            tokenAddress: tokenAddress
        });

        /* Increment the next stream id. */
        nextStreamId = add(nextStreamId, uint256(1));
        

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), deposit), "token transfer failure");
        emit CreateStream(streamId, msg.sender, recipient, deposit, tokenAddress, startTime, stopTime);
        return streamId;
    }
    
    
    function getStream(uint256 streamId) external view streamExists(streamId) returns (
            address sender,
            address recipient,
            uint256 deposit,
            address tokenAddress,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSecond
        )
    {
        sender = streams[streamId].sender;
        recipient = streams[streamId].recipient;
        deposit = streams[streamId].deposit;
        tokenAddress = streams[streamId].tokenAddress;
        startTime = streams[streamId].startTime;
        stopTime = streams[streamId].stopTime;
        remainingBalance = streams[streamId].remainingBalance;
        ratePerSecond = streams[streamId].ratePerSecond;
    }
    
    
    function cancelStream(uint256 streamId)
        external
        streamExists(streamId)
        onlySenderOrRecipient(streamId)
        returns (bool)
    {
        
        cancelStreamInternal(streamId);
        
        return true;
    }
    
    function cancelStreamInternal(uint256 streamId) internal {
        Stream memory stream = streams[streamId];
        uint256 senderBalance = balanceOf(streamId, stream.sender);
        uint256 recipientBalance = balanceOf(streamId, stream.recipient);

        delete streams[streamId];

        IERC20 token = IERC20(stream.tokenAddress);
        if (recipientBalance > 0)
            require(token.transfer(stream.recipient, recipientBalance), "recipient token transfer failure");
        if (senderBalance > 0) require(token.transfer(stream.sender, senderBalance), "sender token transfer failure");

        emit CancelStream(streamId, stream.sender, stream.recipient, senderBalance, recipientBalance);
    }
    
    
    function balanceOf(uint256 streamId, address who) public view streamExists(streamId) returns (uint256 balance) {
        Stream memory stream = streams[streamId];
        BalanceOfLocalVars memory vars;

        uint256 delta = deltaOf(streamId);
        vars.recipientBalance = mul(delta, stream.ratePerSecond);
       

        /*
         * If the stream `balance` does not equal `deposit`, it means there have been withdrawals.
         * We have to subtract the total amount withdrawn from the amount of money that has been
         * streamed until now.
         */
        if (stream.deposit > stream.remainingBalance) {
            vars.withdrawalAmount = sub(stream.deposit, stream.remainingBalance);
            
            vars.recipientBalance = sub(vars.recipientBalance, vars.withdrawalAmount);
            
        }

        if (who == stream.recipient) return vars.recipientBalance;
        if (who == stream.sender) {
            vars.senderBalance = sub(stream.remainingBalance, vars.recipientBalance);
            
            return vars.senderBalance;
        }
        return 0;
    }
    
    function deltaOf(uint256 streamId) public view streamExists(streamId) returns (uint256 delta) {
        Stream memory stream = streams[streamId];
        
        if (block.timestamp <= stream.startTime) return 0;
        
        if (block.timestamp < stream.stopTime) return block.timestamp - stream.startTime;
        
        return stream.stopTime - stream.startTime;
    }
    
    
    
    
    function withdrawFromStream(uint256 streamId, uint256 amount)
        external
        
        streamExists(streamId)
        onlySenderOrRecipient(streamId)
        returns (bool)
    {
        require(amount > 0, "amount is zero");
        Stream memory stream = streams[streamId];
        uint256 balance = balanceOf(streamId, stream.recipient);
        
        require(balance >= amount, "amount exceeds the available balance");

        withdrawFromStreamInternal(streamId, amount);
        
        return true;
    }
    
    function withdrawFromStreamInternal(uint256 streamId, uint256 amount) internal {
        Stream memory stream = streams[streamId];
        
        streams[streamId].remainingBalance = sub(stream.remainingBalance, amount);
        

        if (streams[streamId].remainingBalance == 0) delete streams[streamId];
        
        uint256 companyAmount  = div(mul(amount, fee), 100);
        
        uint256 clientAmount  = sub(amount, companyAmount);
        
        // distribution to the shareholders
        uint256 fee60 = div(mul(clientAmount, 60),100);
        uint256 fee25 = div(mul(clientAmount, 25),100);
        uint256 fee15 = div(mul(clientAmount, 15),100);
    
        require(IERC20(stream.tokenAddress).transfer(stream.recipient, clientAmount), "token transfer failure");
        require(IERC20(stream.tokenAddress).transfer(one, fee60), "fee60 transfer failure");
        require(IERC20(stream.tokenAddress).transfer(two, fee25), "fee25 transfer failure");
        require(IERC20(stream.tokenAddress).transfer(three, fee15), "fee15 transfer failure");
        
        
        
        emit WithdrawFromStream(streamId, stream.recipient, clientAmount);
        emit FeeFromStream60(streamId, one, fee60);
        emit FeeFromStream25(streamId, two, fee25);
        emit FeeFromStream15(streamId, three, fee15);
        
    }
    
    
    
    // TODO change address for second one
    function changeFee(uint256 _fee) external MultiOwners {
        require(_fee <= 50, "fee percentage higher than 50%");
        fee = _fee;
        Back();
        emit newFee(fee);
    }
    
    // function changeCompanyAccount(address _companyAccount) external MultiOwners{
    //     require(_companyAccount != address(0x00), "companyAccount is zero address");  // adress(0)
    //     companyAccount = _companyAccount;
    //     emit newCompanyAccount(companyAccount);
    // }
}