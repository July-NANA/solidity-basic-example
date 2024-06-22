// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import  "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
/*
双向支付通道
*/

contract BiDirectionalPaymentChannel{
    using ECDSA for bytes32;

    event ChallengeExit(address indexed sender, uint256 nonce);
    event Withdraw(address indexed to, uint256 amount);

    address payable[2] public users; // 支付通道的两个用户的地址
    mapping(address => bool) public isUser; // 检查某个地址是否是用户
    mapping(address => uint256) public balances; // 每个用户的余额。

    uint256 public challengePeriod; // 挑战持续时间
    uint256 public expiresAt; // 支付通道的过期时间。
    uint256 public nonce; // 用于防止重放攻击的计数器。

    modifier checkBalances(uint256[2] memory _balances) {
        require(
            address(this).balance >= _balances[0] + _balances[1],
            "balance of contract must be >= to the total balance of users"
        );
        _;
    }

    modifier checkSignatures(
        bytes[2] memory _signatures,
        uint256[2] memory _balances,
        uint256 _nonce
    ) {
        // Note: copy storage array to memory
        address[2] memory signers;
        for (uint256 i = 0; i < users.length; i++) {
            signers[i] = users[i];
        }

        require(
            verify(_signatures, address(this), signers, _balances, _nonce),
            "Invalid signature"
        );

        _;
    }

    modifier onlyUser() {
        require(isUser[msg.sender], "Not user");
        _;
    }

    // 初始化时由用户或一个多签钱包（multi-sig wallet）提供
    constructor(address payable[2] memory _users,uint256[2] memory _balances,uint256 _expiresAt,uint256 _challengePeriod
    ) payable checkBalances(_balances) {
        require(_expiresAt > block.timestamp, "Expiration must be > now");
        require(_challengePeriod > 0, "Challenge period must be > 0");

        for (uint256 i = 0; i < _users.length; i++) {
            address payable user = _users[i];

            require(!isUser[user], "user must be unique");
            users[i] = user;
            isUser[user] = true;

            balances[user] = _balances[i];
        }

        expiresAt = _expiresAt;
        challengePeriod = _challengePeriod;
    }

    function verify(bytes[2] memory _signatures,address _contract,address[2] memory _signers,uint256[2] memory _balances,uint256 _nonce)
     public pure returns (bool) {
        for (uint256 i = 0; i < _signatures.length; i++) {
            /*
            NOTE: sign with address of this contract to protect
                  agains replay attack on other contracts
            */
            
            bool valid= _signers[i]== MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_contract, _balances, _nonce))).recover(_signatures[i]);
            
            if (!valid) {
                return false;
            }
        }

        return true;
    }
    
    function challengeExit(uint256[2] memory _balances,uint256 _nonce,bytes[2] memory _signatures)
        public
        onlyUser
        checkSignatures(_signatures, _balances, _nonce)
        checkBalances(_balances)
    {
        require(block.timestamp < expiresAt, "Expired challenge period");
        require(_nonce > nonce, "Nonce must be greater than the current nonce");

        for (uint256 i = 0; i < _balances.length; i++) {
            balances[users[i]] = _balances[i];
        }

        nonce = _nonce;
        expiresAt = block.timestamp + challengePeriod;

        emit ChallengeExit(msg.sender, nonce);
    }

    function withdraw() public onlyUser {
        require(
            block.timestamp >= expiresAt, "Challenge period has not expired yet"
        );

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, amount);
    }
}