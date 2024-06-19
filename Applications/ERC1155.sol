// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "Applications/IERC1155.sol";

contract ERC1155 is IERC1155{

    // owner => id => balance 
    // 记录每个地址每种代币的余额
    mapping(address => mapping(uint256 => uint256)) public balanceOf;
    // owner => operator => approved
    // 记录每个地址的操作员授权情况
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    // 查询相同index的address 对应的 代币 的余额
    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "owners length != ids length");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < owners.length; i++) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "not approved"
        );
        require(to != address(0), "to = 0 address");

        balanceOf[from][id] -= value;
        balanceOf[to][id] += value;

        emit TransferSingle(msg.sender, from, to, id, value);

        if (to.code.length > 0) {
            require(
                IERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender, from, id, value, data
                ) == IERC1155TokenReceiver.onERC1155Received.selector,
                "unsafe transfer"
            );
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "not approved"
        );
        require(to != address(0), "to = 0 address");
        require(ids.length == values.length, "ids length != values length");

        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[from][ids[i]] -= values[i];
            balanceOf[to][ids[i]] += values[i];
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        if (to.code.length > 0) {
            require(
                IERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender, from, ids, values, data
                ) == IERC1155TokenReceiver.onERC1155BatchReceived.selector,
                "unsafe transfer"
            );
        }
    }

    // ERC165
    function supportsInterface(bytes4 interfaceId)
        external
        pure 
        returns (bool)
    {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0xd9b67a26 // ERC165 Interface ID for ERC1155
            || interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    // ERC1155 Metadata URI
    function uri(uint256 id) public view virtual returns (string memory) {}


// Internal functions
    function _mint(address to, uint256 id, uint256 value, bytes memory data)
        internal
    {
        require(to != address(0), "to = 0 address");

        balanceOf[to][id] += value;

        emit TransferSingle(msg.sender, address(0), to, id, value);

        if (to.code.length > 0) {
            require(
                IERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender, address(0), id, value, data
                ) == IERC1155TokenReceiver.onERC1155Received.selector,
                "unsafe transfer"
            );
        }
    }

    function _batchMint(
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) internal {
        require(to != address(0), "to = 0 address");
        require(ids.length == values.length, "ids length != values length");

        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[to][ids[i]] += values[i];
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        if (to.code.length > 0) {
            require(
                IERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender, address(0), ids, values, data
                ) == IERC1155TokenReceiver.onERC1155BatchReceived.selector,
                "unsafe transfer"
            );
        }
    }

    function _burn(address from, uint256 id, uint256 value) internal {
        require(from != address(0), "from = 0 address");
        balanceOf[from][id] -= value;
        emit TransferSingle(msg.sender, from, address(0), id, value);
    }

    function _batchBurn(
        address from,
        uint256[] calldata ids,
        uint256[] calldata values
    ) internal {
        require(from != address(0), "from = 0 address");
        require(ids.length == values.length, "ids length != values length");

        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[from][ids[i]] -= values[i];
        }

        emit TransferBatch(msg.sender, from, address(0), ids, values);
    }
}

contract MyMultiToken is ERC1155{
    function mint(address to, uint256 id, uint256 value, bytes memory data) public {
        _mint(to, id, value, data);
    }

    function batchMint(address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) public {
        _batchMint(to, ids, values, data);
    }
    function burn(address from, uint256 id, uint256 value) public {
        _burn(from, id, value);
    }
    function batchBurn(uint256[] calldata ids, uint256[] calldata values)
        external
    {
        _batchBurn(msg.sender, ids, values);
    }
}