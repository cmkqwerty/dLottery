// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Lottery {
    mapping (address => uint256) public weiValues;
    mapping (address => uint256) public blockHashesToBeUsed;

    function playGame() external payable {
        if (blockHashesToBeUsed[msg.sender] == 0) {
            blockHashesToBeUsed[msg.sender] = block.number + 2;
            
            weiValues[msg.sender] = msg.value;

            return;
        }

        require(msg.value == 0, "Lottery: First, finish the game.");
        require(blockhash(blockHashesToBeUsed[msg.sender]) != 0, "Lottery: Not mined.");

        uint256 randomNumber = uint256(blockhash(blockHashesToBeUsed[msg.sender]));
        if (randomNumber != 0 && randomNumber % 2 == 0) {
            uint256 winningAmount = weiValues[msg.sender] * 2;

            (bool sent,) = msg.sender.call{value: winningAmount}("");
            require(sent, "Lottery: Failed to send Ether.");
        }

        blockHashesToBeUsed[msg.sender] = 0;
        weiValues[msg.sender] = 0;
    }
}