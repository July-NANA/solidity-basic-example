// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StructDemo{
    struct Demo{
        address owner;
        uint num;
        string text;
    }
    Demo[] public demos;
    function create1(uint160 addr,uint num,string calldata text) public{
        Demo memory d1= Demo(address(addr),num,text);
        demos.push(d1);
    } 
    function create2(uint160 addr,uint num,string calldata text) public{
        Demo memory d1= Demo({num: num,owner: address(addr),text: text});
        demos.push(d1);
    } 
    function create3(uint160 addr,uint num,string calldata text) public{
        Demo memory d1;
        d1.num=num;
        d1.owner=address(addr);
        d1.text=text;
        demos.push(d1);
    } 
    function deleteOwner(uint index) public {
        Demo storage d1=demos[index];
        delete d1.owner;
    }
    function getOwner(uint index) view  public returns(address ){
        return demos[index].owner;
    }
}