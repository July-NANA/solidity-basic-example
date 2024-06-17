// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
1. submit a transaction
2. approve and revoke approval of pending transactions
3. anyone can execute a transaction after enough owners has approved it.
*/
contract MultiSigWallet{
    /*
    1. 定义一个交易（struct），包含已批准人的数量，交易金额，
    2. 定义该钱包所有者的列表（list）
    3. 批准和撤销批准
    4. 执行交易
    5. 定义需要多少人签名才可以执行
    6. 发起一个交易
    */

    error NoOwners();
    error InvalidConfirmationNum();
    error UniqueOwner(string);
    error NotOwner();
    error Confirmed(string);

    event ExecuteTransaction(address indexed owner, uint256 value,bool indexed success);

    struct Transaction{
        uint256 approveCount;
        uint256 value;
        bool executed;
        address _to;
    }

    address[] private s_owners;

    uint256 public  immutable i_numConfirmations;

    Transaction private transaction;

    mapping(address => bool) public isOwner;
    mapping(address=> bool) public isConfirmed;

    constructor(address[] memory _owners,uint256 _numConfirmations) payable {
        uint length=_owners.length;
        if(length<=0){
            revert NoOwners();
        }
        
        for (uint i=0;i<length;++i){
            address t_owner=_owners[i];
            if(isOwner[t_owner]){
                revert UniqueOwner("owner not unique");
            }
            isOwner[t_owner]=true;
            s_owners.push(t_owner);
        }

        if(_numConfirmations<=0 || _numConfirmations>=length){
            revert InvalidConfirmationNum();
        }
        i_numConfirmations=_numConfirmations;

    }

    receive() external payable { } 

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getOwners() public view returns(address[] memory) {
        return s_owners;
    }

    function getTransaction() public view returns (
        uint256 approveCount,
        uint256 value,
        bool executed,
        address _to){
        return (
        transaction.approveCount,
        transaction.value,
        transaction.executed,
        transaction._to);
    }

    function submitTransaction(
        uint256 value,
        address _to) public {
        Transaction memory newTransaction=Transaction(0,value,false,_to);
        transaction=newTransaction;
    }

    modifier onlyOwner(){
        if(!isOwner[msg.sender]){
            revert NotOwner();
        }
        _;
    }

    function confirmTransaction() public onlyOwner{
        if(isConfirmed[msg.sender]){
            revert Confirmed("AlreadyConfirmed");
        }

        transaction.approveCount++;
        isConfirmed[msg.sender]=true;

    }

    function revokeConfirmation() public onlyOwner{
        if(!isConfirmed[msg.sender]){
            revert Confirmed("NotConfirmed");
        }

        transaction.approveCount--;
        isConfirmed[msg.sender]=false;
    }

    function executeTransaction() public onlyOwner {
        if(transaction.approveCount<i_numConfirmations){
            revert Confirmed("require confirmed");
        }
        address to=transaction._to;
        (bool success,)=payable(to).call{value:transaction.value}("");
        transaction.executed=true;
        
        emit ExecuteTransaction(msg.sender,transaction.value,success);
    }
}
//[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,0x617F2E2fD72FD9D5503197092aC168c91465E7f2]
