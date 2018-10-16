pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract <#__project_name#>  is StandardToken {
    string public name = "<#Token Name#>";
    string public symbol = "<#Token Symbol#>";
    uint8 public decimals = <#Decimals#>;
    uint public INITIAL_SUPPLY = <#Initial Supply#>;


    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
