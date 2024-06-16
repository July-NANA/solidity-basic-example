// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract A{
    uint public constant NUM=1;
    uint public immutable i_nums;
    constructor(){
        i_nums=1;
    }
    function foo() public pure virtual returns(string memory s){
        s="A";
    }
}

contract B is A{
    // uint public constant NUM=2;
    // uint public immutable i_nums;
    constructor(){
        i_nums=2;
    }
    function foo() public pure virtual  override  returns(string memory s){
        s="B";
    }
}

contract C is A{
    
    constructor(){
        i_nums=3;
    }
    function foo() public pure virtual override  returns(string memory s){
        s="C";
    }
}

contract D is C,B{
    
    constructor(){
        i_nums=4;
    }
    function foo() public pure override(C,B)  returns(string memory s){
        s= super.foo();
    }
}

contract E is B,C{
    
    constructor(){
        i_nums=5;
    }
    function foo() public pure override(C,B)  returns(string memory s){
        s= super.foo();
    }
}

// Inheritance must be ordered from “most base-like” to “most derived”.
// Swapping the order of A and B will throw a compilation error.
contract F is A,B{
    
    constructor(){
        i_nums=6;
    }
    function foo() public pure override(B,A)  returns(string memory s){
        s=super.foo();
    }

    function aFoo() public  pure returns (string memory s){
        s=A.foo();
    }
}