// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Math{
    //Newton’s Method
    function sqrt(uint256 y) public  pure returns(uint256 z){
        z=y;
        uint x=z/2+1;
        if(y>3){
            while (x<z){
            z=x;
            x=(x+y/x)/2;
            }
        }else if(y!=0){
            z=1;
        }
    }
}

contract TestMath{
    using Math for uint256;
    function testSqrt(uint256 num) public pure  returns(uint256 answer){
       answer= num.sqrt();
       answer=Math.sqrt(num);
    }
}

library Array{
    error EmptyArray();
    function remove(uint256[] storage nums,uint256 index)public returns(uint256[] memory){
        if (nums.length==0){
            revert EmptyArray();
        }
        nums[index]=nums[nums.length-1];
        nums.pop();
        return nums;
    }
}

contract TestArray {
    using Array for uint256[];

    uint256[] public arr;

    function testArrayRemove() public {
        for (uint256 i = 0; i < 3; i++) {
            arr.push(i);
        }

        arr.remove(1);
        Array.remove(arr,1);

        assert(arr.length == 2);
        assert(arr[0] == 0);
        assert(arr[1] == 2);
    }
}