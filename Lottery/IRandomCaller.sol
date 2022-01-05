// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomCaller{
    function randomCallback(uint256 roundNumber) external;

    event CallBack(address caller,uint256 roundNumber);
}