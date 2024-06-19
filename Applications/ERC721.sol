// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "Applications/IERC721.sol";

contract ERC721 is IERC721{

    // Mapping from token ID to owner address
    mapping (uint ntfID=> address owner) internal _ownerOf;

    // Mapping owner address to token count
    mapping (address owner => uint balance) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint256 ntfID => address approval) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(bytes4 interfaceId) external pure  returns (bool){
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC165).interfaceId;
        // return interfaceId == type(IERC721).interfaceId || type(IERC165).interfaceId;
    }

    function balanceOf(address _owner) external view returns (uint256){
        require(_owner != address(0), "owner = zero address");
        return _balanceOf[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        address owner= _ownerOf[_tokenId];
        require(owner != address(0), "token doesn't exist");
        return owner;
    }

    function _isApprovedOrOwner(address owner, address spender, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return (
            spender == owner || isApprovedForAll[owner][spender]
                || spender == _approvals[_tokenId]
        );
    }

    
    function transferFrom(address _from, address _to, uint256 _tokenId) public  payable{
        require(_from == _ownerOf[_tokenId], "from != owner");
        require(_to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(_from, msg.sender, _tokenId), "not authorized");

        _balanceOf[_from]--;
        _balanceOf[_to]++;
        _ownerOf[_tokenId] = _to;

        delete _approvals[_tokenId];

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable{
        transferFrom(_from,_to,_tokenId);
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        transferFrom(_from,_to,_tokenId);
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    
    function approve(address _approved, uint256 _tokenId) external payable{
        address owner = _ownerOf[_tokenId];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[_tokenId] = _approved;

        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external{
        isApprovedForAll[msg.sender][_operator]=_approved;
        emit ApprovalForAll(msg.sender,_operator,_approved);
    }

  
    function getApproved(uint256 _tokenId) external view returns (address){
        require(_ownerOf[_tokenId] != address(0), "token doesn't exist");
        return _approvals[_tokenId];
    }

    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }

}

contract MyNFT is ERC721 {
    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}