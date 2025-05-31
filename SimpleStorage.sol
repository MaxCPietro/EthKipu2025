// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    int256 private storageData;

    constructor() {
        storageData =-11;
    }

    modifier onlyPositive(int256 _checkingValue){
        require(_checkingValue >= 0, "Usted es negativo");
        _;
    }
    
    //modifier onlyPositive
    function setData(int256 _storeData) external onlyPositive(_storeData){
        storageData = _storeData;
    }

    function getData() external view returns (int256) {
        return storageData;
    }    
}