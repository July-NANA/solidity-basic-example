// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
在使用create2部署合约之前，提前计算部署地址
*/

contract TestContract {
    address public owner;
    uint256 public foo;

    constructor(address _owner, uint256 _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}



contract Factory{
    function deploy(address _owner, uint256 _foo, bytes32 _salt) public payable returns (address) {
        TestContract newContract= new TestContract{salt:_salt}(_owner,_foo);
        address addr=address(newContract);
        return addr;
    }
}

contract FactoryAssembly {
    event Deployed(address addr, uint256 salt);

    // 1. 获取要部署的合约的字节码
    function getBytecode(address _owner, uint256 _foo) public pure returns (bytes memory)
    {
        /*
        使用type(TestContract).creationCode，
        这段代码获取了TestContract合约的创建代码（即部署该合约所需的字节码）。
        创建代码包含了合约的初始化代码和构造函数。
        */
        bytes memory creationCode=type(TestContract).creationCode;

        /*
        将创建代码和编码后的构造函数参数合并在一起，形成完整的合约部署字节码。
        */
        bytes memory byteCode=abi.encodePacked(creationCode,abi.encode(_owner,_foo));
        return byteCode;
    }

    // 2. 计算要部署合约的地址
    function getAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    // 3. 部署合约
    function deploy(bytes memory bytecode, uint256 _salt) public payable {
        address addr;
        assembly {
            addr := create2(
            callvalue(),        // 当前调用发送的以太币数量
            add(bytecode, 0x20),// 跳过前32字节，获取实际的字节码位置
            mload(bytecode),    // 获取字节码的长度
            _salt               // 盐值，用于生成合约地址
        )

        // 如果合约部署失败，则撤销交易
        if iszero(extcodesize(addr)) { revert(0, 0) }
    }

        emit Deployed(addr, _salt);
    }
}
