// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract test {
    uint256 public counter; //puede tener un getter
    address private owner; //esta variable no genera un getter

    //constructor que me permite mandarte ethers y establece como owner
    constructor() payable {//la palabra reservada payable indica que el constructor es llam
        owner = msg.sender;
    }

    //función para ver los límites de un tipo
    function intLimits() external pure returns (int8,int8){
        return (type(int8).min, type(int8).max);
    }

    //generacion de un underflow
    function underflow() external pure returns(int8){
        return (type(int8).min/(-1));
    }

    //estudio de side effects
    function Counter() external {
        if (1 == 0 && count()){}
    } 
    function count () internal returns (bool) {
        counter++;
        return (true);
    }

    function overflow2() external pure returns (uint16){
        uint16 a = 255 + (true ? 1:0);
        return a;
    }

    //Cualquiera saca los Ethers
    function transferEtherAny() external {
        address payable _to;
        _to = payable (msg.sender);
        _to.transfer(address(this).balance);
    }

    //Solo el owner saca los ethers
    modifier onlyOwner(){
        require(owner==msg.sender, "No eres el owner");
        _;
    }

    function transferEtherOwner() external onlyOwner {
        address payable _to;
        _to = payable (msg.sender);
        if (_to.send(address(this).balance)==false){
            revert("Fallo el envio");
        }
    }
}