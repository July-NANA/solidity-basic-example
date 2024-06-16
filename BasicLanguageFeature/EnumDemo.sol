// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Enum{
    error InvalidEnum();
    enum Shot{
        Ready,
        Fire,
        Cancel
    }

    modifier shotStatus(uint status){
        if(status>uint(type(Shot).max)){
            revert InvalidEnum();
        }
        _;
    }
    Shot shot;

    function get()public view returns(Shot){
        return shot;
    }

    function set(uint num) public shotStatus(num) {
        shot=Shot(num);
    }

    function setWithEnum(Shot _shot) public shotStatus(uint(_shot)){
        shot=_shot;
    }

    function ready() public {
        shot=Shot.Ready;
    }

    function fire() public {
        shot=Shot.Fire;
    }
}