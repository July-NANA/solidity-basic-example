// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Receiver{
    event Received(address caller,uint amount,string message);
    fallback() external payable { 
        emit Received(msg.sender,msg.value,"Fallback was called");
    }
    receive() external payable { 
        emit Received(msg.sender,msg.value,"Receive was called");
    }
    function foo(string calldata message,uint _x)public payable returns(uint) {
        emit Received(msg.sender, msg.value, message);
        return _x+1;
    }
}

contract Caller {
    event Response(bool success,bytes data);

    function testCallFoo(address _addr) public payable returns (string memory) {
        (bool success,bytes memory data)=_addr.call{value: msg.value,gas:5000}(
            //注意要声明uint是多少位的
            abi.encodeWithSignature("foo(string,uint256)", "call foo",123)
        );
        emit Response(success, data);
        // return abi.decode(data, (string));
        return "data";
    }

    function testNotExist(address _addr) public payable returns (string memory) {
        (bool success,bytes memory data)=_addr.call{value: msg.value,gas:5000}(
            abi.encodeWithSignature("fdoesNotExist()", "call foo",123)
        );
        emit Response(success, data);
        // return abi.decode(data, (string));
        return "data";

    }

    function testCallByEncodeCall(address _addr) public payable returns (string memory)   {
       bytes memory callData =  abi.encodeCall(Receiver.foo, ("call foo",123));
        (bool success ,bytes memory data)=_addr.call{value: msg.value,gas:5000}( callData);
        emit Response(success, data);
        // return abi.decode(data, (string));
        return "data";

    }
}

