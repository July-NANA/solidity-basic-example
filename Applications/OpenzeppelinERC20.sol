// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract GLDToken is ERC20 {
    constructor(uint256 initialSupply,string memory name,string memory symbol ) ERC20(name,symbol) {
        _mint(msg.sender, initialSupply);
    }
}