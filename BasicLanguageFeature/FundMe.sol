// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "/PriceConverter.sol";
error NotOwner();
contract FundMe{
    using PriceConverter for uint256;
    uint public balance=address(this).balance;
    uint public constant MINIMUM_USD=5e18;
    address[] funders;
    mapping (address funder => uint amountFunded) addressToAmount;
    address public immutable i_owner;
    constructor(){
        i_owner=msg.sender;
    }
    function fund()public payable { 
        require(msg.value.getConversionRate()>MINIMUM_USD,"don't send enough");
        funders.push(msg.sender);
        addressToAmount[msg.sender]=addressToAmount[msg.sender]+msg.value;
    }
    function withdrow() public {
        for(uint funderIndex=0;funderIndex<funders.length;funderIndex++){
            address funder=funders[funderIndex];
            addressToAmount[funder]=0;
        }
        funders=new address[](0);

        payable(msg.sender).transfer(address(this).balance);

        // bool sendSuccess=payable (msg.sender).send(address(this).balance);
        // require(sendSuccess,"sneFailed");

        // (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        // require(callSuccess,"call Failed");
    }
    modifier onlyOwner(){
        if(msg.sender!=i_owner){
            revert NotOwner();
        }
        _;
    }
    receive() external payable { fund();}
    fallback() external payable { fund();}
}