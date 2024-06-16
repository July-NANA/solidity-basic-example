// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ArrayTest{
    uint[] s_nums=[1,2,3];
    function setArray() public view{
        // uint[] calldata nums=new uint[](3);
        uint a=s_nums[0];
        uint[5] memory fixedNums;
        // uint[] storage nums1=[1,2,3];
    }
}