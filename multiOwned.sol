pragma solidity 0.5.11;

contract SimpleMultisig {

  address public one;
  address public two;
  address public three;
  address public resone;
  address public restwo;
  address public resthree;


  mapping(address => bool) internal signed;

  constructor() public {
    require (one != address(0) && resone != address(0));
    require (two != address(0) && restwo != address(0));
    require (three != address(0) && resthree != address(0));
    
    one = 0x0000000000000000000000000000000000000001;
    two = 0x0000000000000000000000000000000000000002;
    three = 0x0000000000000000000000000000000000000002;

    resone = 0x0000000000000000000000000000000000000011;
    restwo = 0x0000000000000000000000000000000000000022;
    resthree = 0x0000000000000000000000000000000000000033;  
  }

  function Sign1() public {
    require (msg.sender == one || msg.sender == resone);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }

  function Sign2() public {
    require (msg.sender == two || msg.sender == restwo);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }

  function Sign3() public {
    require (msg.sender == three || msg.sender == resthree);
    require (signed[msg.sender] == false);
    signed[msg.sender] = true;
  }
  
  function CheckSign(address _user) external view returns (bool){
      return signed[_user];
  }

  modifier MultiOwners {
    require (signed[one] == true || signed[resone] == true);
    require (signed[two] == true || signed[restwo] == true);
    require (signed[three] == true || signed[resthree] == true);
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