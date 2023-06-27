// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Lottery {
    mapping (address => uint256) public weiValues;
    mapping (address => uint256) public blockHashesToBeUsed;
    mapping (address => bytes32) public commitments;

    function playGame(bytes32 commitment) external payable {
        require(commitments[msg.sender] == 0, "Lottery: You have already committed.");

        if (blockHashesToBeUsed[msg.sender] == 0) {
            blockHashesToBeUsed[msg.sender] = block.number + 2;
            commitments[msg.sender] = commitment;
            weiValues[msg.sender] = msg.value;
            return;
        }

        require(msg.value == 0, "Lottery: First, finish the game.");
        require(blockhash(blockHashesToBeUsed[msg.sender]) != 0, "Lottery: Not mined.");

        bytes32 revealedNumber = keccak256(abi.encodePacked(msg.sender, commitment));
        require(revealedNumber == blockhash(blockHashesToBeUsed[msg.sender]), "Lottery: Incorrect revealed number.");

        if (uint256(revealedNumber) % 2 == 0) {
            uint256 winningAmount = weiValues[msg.sender] * 2;
            (bool sent,) = msg.sender.call{value: winningAmount}("");
            require(sent, "Lottery: Failed to send Ether.");
        }

        blockHashesToBeUsed[msg.sender] = 0;
        weiValues[msg.sender] = 0;
        commitments[msg.sender] = 0;
    }
}