// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RemoveFromArray{
    uint[] public s_nums;
    function setNums(uint[] calldata newNums) public returns(uint[] memory) {
        s_nums=newNums;
        return s_nums;
    }

    function removeByIndex(uint index) public returns(uint[] memory) {
        uint length=s_nums.length;
        for (uint i=index;i<length-1;++i){
            s_nums[i]=s_nums[i+1];
        }
        s_nums.pop();
        return s_nums;
    }

    function replaceByIndex(uint index) public returns (uint[] memory) {
        s_nums[index]=s_nums[s_nums.length-1];
        s_nums.pop();
        return s_nums;
    }
    
}