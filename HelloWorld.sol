// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract HelloWorld {
    string public saludo; //Saludo = Variable de storage

    function getSaludo() view external returns (string memory){
        return saludo;
    }
    function setSaludo(string calldata _saludo) external {
         saludo = _saludo; //_saludo = Parametro de la funcion
    }
}