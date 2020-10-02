 
/**
   Tis contract based on:

   Fork of OpenZeppelin's contracts

   @title ERC-1620 Money Streaming Standard
   @author Paul Razvan Berg - <paul@sablier.app>
   @dev See https://eips.ethereum.org/EIPS/eip-1620

   Fork https://github.com/sablierhq/sablier
**/

pragma solidity 0.5.11;

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


contract MyStream is SafeMath{
    
    
     constructor() public {
        //require(cTokenManagerAddress != address(0x00), "cTokenManager contract is the zero address");
        //OwnableWithoutRenounce.initialize(msg.sender);
        //PausableWithoutRenounce.initialize(msg.sender);
        //cTokenManager = ICTokenManager(cTokenManagerAddress);
        fee = 5;
        nextStreamId = 1;
    }
    
    // Variables
    
    uint256 public nextStreamId;
    uint256 public fee = 5;
    address public companyAccount = 0x4a701E81c114c9885EE814a41EabBBE6B02D3440;
    
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
    
    event FeeFromStream(
        uint256 indexed streamId, 
        address indexed companyAccount, 
        uint256 companyAmout
    );
    
    // Functions public TODO add pause
    
    function createStream(address recipient, uint256 deposit, address tokenAddress, uint256 startTime, uint256 stopTime) public  returns (uint256){
        
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
        //whenNotPaused
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
        
        //uint256 companyAmout  = div(mul(amount, fee), 100);
        
        //uint256 clientAmout  = sub(amount, companyAmout);
        
    
        require(IERC20(stream.tokenAddress).transfer(stream.recipient, amount), "token transfer failure");
       // require(IERC20(stream.tokenAddress).transfer(companyAccount, companyAmout), "fee transfer failure");
        
        emit WithdrawFromStream(streamId, stream.recipient, amount);
       // emit FeeFromStream(streamId, companyAccount, companyAmout);
    }
    // TODO onlyOwner Events
    function changeFee(uint _fee) public {
        require(_fee <= 50, "fee percentage higher than 50%");
        fee = _fee;
    }
    
    function changeCompanyAccount(address _companyAccount) public {
        require(_companyAccount != address(0x00), "companyAccount is zero address");
        companyAccount = _companyAccount;
    }
}