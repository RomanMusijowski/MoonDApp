// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MoonFarmToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Moon farm token", "MFT") {
        _mint(msg.sender, initialSupply);
    }
}
