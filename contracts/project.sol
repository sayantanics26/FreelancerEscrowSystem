// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelancerEscrow {
    struct Escrow {
        uint256 id;
        address client;
        address payable freelancer;
        uint256 amount;
        bool isFunded;
        bool isReleased;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public nextEscrowId;

    event EscrowCreated(uint256 id, address client, address freelancer, uint256 amount);
    event FundsReleased(uint256 id, address freelancer, uint256 amount);

    function createEscrow(address payable freelancer) public payable {
        require(msg.value > 0, "Escrow amount must be greater than zero");

        escrows[nextEscrowId] = Escrow(nextEscrowId, msg.sender, freelancer, msg.value, true, false);
        emit EscrowCreated(nextEscrowId, msg.sender, freelancer, msg.value);
        nextEscrowId++;
    }

    function releaseFunds(uint256 escrowId) public {
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == escrow.client, "Only client can release funds");
        require(escrow.isFunded, "Escrow is not funded");
        require(!escrow.isReleased, "Funds already released");

        escrow.freelancer.transfer(escrow.amount);
        escrow.isReleased = true;
        emit FundsReleased(escrowId, escrow.freelancer, escrow.amount);
    }
}
