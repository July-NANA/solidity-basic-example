// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
1. Anyone can send ETH.
2. Only the owner can withdraw.
*/
contract EtherWallet{
    error NotOwner();
    error WithdrawFailde(bytes);

    address private immutable i_owner;

    constructor(){
        i_owner=msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner(){
        if(msg.sender!=i_owner){
            revert NotOwner();
        }
        _;
    }

    function withdraw() public onlyOwner{
        (bool success,bytes memory data)=payable(msg.sender).call{value:address(this).balance}("");
        if(!success){
            revert WithdrawFailde(data);
        }
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getOwner() public view returns(address){
        return i_owner;
    }
}