// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Ownable{
    error NotOwner(address caller);
    error InvalidOwner();


    address private s_owner;
    
    constructor(){
        s_owner=msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender!=s_owner){
            revert NotOwner(msg.sender);
        }
        _;
    }

    function getOwner() view public returns (address){
        return s_owner;
    }

    function setOwner(address _newOwner) public onlyOwner{
        if (_newOwner==address(0)){
            revert InvalidOwner();
        }
        s_owner=_newOwner;
    }
}