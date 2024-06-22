// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external 
        view 
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target length != data length");

        bytes[] memory results = new bytes[](data.length);

        for (uint256 i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }

    TestMultiCall[]  tests;
    bytes[]  datas;
    address[] testAddrs;
    
    function test() public returns(uint[] memory){
        
        for (uint i=0;i<10;++i){
            TestMultiCall newTest= new TestMultiCall();
            tests.push(newTest);
            datas.push(newTest.getData(i));
            testAddrs.push(address(newTest));
        }
        bytes[] memory byteDatas=callMultiCall(testAddrs,datas);
        uint[] memory nums=new uint[](10);
         for (uint i=0;i<10;++i){
            nums[i]=abi.decode(byteDatas[i], (uint));
         }
        return nums;
    }

    function callMultiCall(address[] memory targets, bytes[] memory data)
        internal
        view
        returns (bytes[] memory)
    {
        // 转换 memory 到 calldata
        return this.multiCall(targets, data);
    }
}


contract TestMultiCall {
    function test(uint256 _i) external pure returns (uint256) {
        return _i;
    }

    function getData(uint256 _i) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.test.selector, _i);
    }
}

