// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VerifySignature{
    function verify(address _addr,string calldata _message,bytes calldata _signature) public pure returns(bool){
        bytes32 messageHash=getMessageHash(_message);
        bytes32 ethHashMessage=getEthSignedMessageHash(messageHash);
        return recover(ethHashMessage, _signature)==_addr;
    }


    function getMessageHash(
        string memory _message    ) 
        public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash));
    }

    function recover(bytes32 _ethMessage,bytes memory _signature) public pure returns(address){
        (bytes32 r,bytes32 s,uint8 v)=splitSignature(_signature);
        return ecrecover(_ethMessage, v, r, s);
    }

    function splitSignature(bytes memory _signature) public pure returns(bytes32 r,bytes32 s,uint8 v){
        require(_signature.length == 65, "invalid signature length");
        assembly{
            r:=mload(add(_signature,32))
            s:=mload(add(_signature,64))
            v:=byte(0,mload(add(_signature,96)))
        }

    }
}