// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/*
荷兰拍卖
1. NFT 的卖方部署此合约，为 NFT 设定起始价格。
2. 拍卖持续7天。
3. NFT 的价格会随着时间的推移而下降。
4. 参与者可以通过存入高于智能合约计算的当前价格的 ETH 来购买。
5. 当买家购买 NFT 时，拍卖结束。
*/

contract DutchAuction {
uint256 private constant DURATION = 7 days;

    ERC721URIStorage public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;
    bool public isActive; //拍卖是否还在进行

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;

        require(
            _startingPrice >= _discountRate * DURATION, "starting price < min"
        );

        nft = ERC721URIStorage(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint256 refund = msg.value - price;
        //检查退款金额是否大于0，如果是，则通过 transfer 函数将退款金额发送给买家。
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // selfdestruct 即将发生变化，不再会删除账户关联的代码和数据，仅会将账户中的 Ether 转移给指定的受益人，
        // selfdestruct(seller);
        isActive=false;
        withDrowFund();
    }

    function withDrowFund() public  {
        require(!isActive, "contract is still active");
        (bool success,)=payable (msg.sender).call{value:address(this).balance}("");
        require(success,"withdrow failed");
    }
}