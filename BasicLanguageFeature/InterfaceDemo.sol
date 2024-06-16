// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    uint256 public count;

    function increment() external {
        count += 1;
    }
}
interface ICounter {
    function count() external view returns (uint);

    function increment() external ;

}

contract MyCounter{
    function incrementCounter(address _counter) public {
        ICounter counter=ICounter(_counter);
        counter.increment();
    }

    function getCount(address _counter)public view returns(uint){
        ICounter counter=ICounter(_counter);
        
        return counter.count();
    }
}