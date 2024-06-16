// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}

contract CarFactory{
    Car[] cars;

    function create(address _owner,string memory model) public {
        Car newCar=new Car(_owner,model);
        cars.push(newCar);
    }

    function createAndSendEth(address _owner,string memory model) public payable {
        Car newCar=new Car{value:msg.value}(_owner,model);
        cars.push(newCar);
    }

    function create2(address _owner,string memory model,bytes32 _salt) public {
        Car newCar=new Car{salt:_salt}(_owner,model);
        cars.push(newCar);
    }

    function create2AndSendEth(address _owner,string memory model,bytes32 _salt) public payable {
        Car newCar=new Car{salt:_salt,value:msg.value}(_owner,model);
        cars.push(newCar);
    }

    function getCar(uint256 _index)
        public
        view
        returns (
            address owner,
            string memory model,
            address carAddr,
            uint256 balance
        )
    {
        Car car = cars[_index];

        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }
}